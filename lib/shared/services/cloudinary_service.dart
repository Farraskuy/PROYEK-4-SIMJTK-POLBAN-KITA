import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CloudinaryService {
  String get _cloudName => dotenv.env['CLOUDINARY_CLOUD_NAME']?.trim() ?? '';
  String get _uploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET']?.trim() ?? '';

  Future<String> uploadImage(
    String path, {
    String folder = 'simjtk',
  }) async {
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
      throw Exception(
        'Konfigurasi CLOUDINARY_CLOUD_NAME dan CLOUDINARY_UPLOAD_PRESET belum diisi.',
      );
    }
    if (!await File(path).exists()) {
      throw Exception('File foto tidak ditemukan.');
    }

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload'),
    )
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', path));

    final response = await http.Response.fromStream(await request.send());
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Upload Cloudinary gagal (${response.statusCode}).');
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
}
