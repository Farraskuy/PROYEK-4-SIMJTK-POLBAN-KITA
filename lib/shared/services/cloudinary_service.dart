import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class CloudinaryService {
  @visibleForTesting
  static Future<String> Function(String path, {String folder})?
      uploadImageOverride;

  String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME']?.trim() ?? '';
  String get _uploadPreset => dotenv.env['CLOUDINARY_UPLOAD_PRESET']?.trim() ?? '';
  String get _apiKey => dotenv.env['CLOUDINARY_API_KEY']?.trim() ?? '';
  String get _apiSecret => dotenv.env['CLOUDINARY_API_SECRET']?.trim() ?? '';

  /// Generates SHA-1 signature for Cloudinary signed uploads.
  String _generateSignature(Map<String, String> params, String secret) {
    final sortedKeys = params.keys.toList()..sort();
    final parameterString = sortedKeys.map((key) => '$key=${params[key]}').join('&');
    final stringToSign = '$parameterString$secret';
    final bytes = utf8.encode(stringToSign);
    return sha1.convert(bytes).toString();
  }

  Future<String> uploadImage(
    String path, {
    String folder = 'simjtk',
  }) async {
    final override = uploadImageOverride;
    if (override != null) {
      return override(path, folder: folder);
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }

    if (_cloudName.isEmpty) {
      throw Exception('Konfigurasi CLOUDINARY_CLOUD_NAME belum diisi.');
    }

    if (!await File(path).exists()) {
      throw Exception('File foto tidak ditemukan: $path');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'),
    );

    // If an upload preset is configured, perform secure Unsigned Upload
    if (_uploadPreset.isNotEmpty) {
      request.fields['upload_preset'] = _uploadPreset;
      request.fields['folder'] = folder;
    } 
    // Otherwise, perform Signed Upload using API Key and Secret
    else if (_apiKey.isNotEmpty && _apiSecret.isNotEmpty) {
      final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000).toString();
      final paramsToSign = {
        'folder': folder,
        'timestamp': timestamp,
      };
      
      final signature = _generateSignature(paramsToSign, _apiSecret);
      
      request.fields['api_key'] = _apiKey;
      request.fields['timestamp'] = timestamp;
      request.fields['signature'] = signature;
      request.fields['folder'] = folder;
    } 
    // If neither is properly configured, throw a clear error
    else {
      throw Exception(
        'Konfigurasi Cloudinary tidak lengkap. Harap isi CLOUDINARY_UPLOAD_PRESET '
        'untuk Unsigned Upload, atau isi CLOUDINARY_API_KEY dan CLOUDINARY_API_SECRET '
        'untuk Signed Upload.',
      );
    }

    request.files.add(await http.MultipartFile.fromPath('file', path));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final errorMsg = _tryParseErrorMessage(response.body);
      throw Exception('Upload Cloudinary gagal (${response.statusCode}): $errorMsg');
    }

    final body = jsonDecode(response.body);
    final secureUrl = body is Map ? body['secure_url']?.toString() : null;
    if (secureUrl == null || secureUrl.isEmpty) {
      throw Exception('Cloudinary tidak mengembalikan URL foto.');
    }
    return secureUrl;
  }

  Future<List<String>> uploadImages(
    Iterable<String> paths, {
    String folder = 'simjtk',
  }) async {
    final urls = <String>[];
    for (final path in paths.where((item) => item.trim().isNotEmpty)) {
      urls.add(await uploadImage(path, folder: folder));
    }
    return urls;
  }

  String _tryParseErrorMessage(String responseBody) {
    try {
      final parsed = jsonDecode(responseBody);
      if (parsed is Map && parsed['error'] is Map && parsed['error']['message'] != null) {
        return parsed['error']['message'].toString();
      }
    } catch (_) {}
    return responseBody;
  }
}
