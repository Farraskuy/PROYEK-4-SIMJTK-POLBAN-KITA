import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/cloudinary_service.dart';

void main() async {
  print('=== Menjalankan Tes Upload Cloudinary ===');

  var envFile = File('.env');
  if (!envFile.existsSync()) {
    print('Error: File .env tidak ditemukan.');
    return;
  }
  
  print('Membaca konfigurasi .env...');
  dotenv.loadFromString(envString: envFile.readAsStringSync());

  final cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'];
  final apiKey = dotenv.env['CLOUDINARY_API_KEY'];
  final apiSecret = dotenv.env['CLOUDINARY_API_SECRET'];
  
  print('Cloud Name: $cloudName');
  print('API Key: $apiKey');
  print('API Secret: ${apiSecret != null && apiSecret.isNotEmpty ? "Tersedia (Disamarkan)" : "Tidak ada"}');

  if (cloudName == null || apiKey == null || apiSecret == null) {
    print('Error: Kredensial tidak lengkap di .env');
    return;
  }

  // Buat file gambar dummy untuk tes
  final dummyFile = File('dummy_test_image.png');
  await dummyFile.writeAsBytes([137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0, 0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 10, 73, 68, 65, 84, 120, 156, 99, 0, 1, 0, 0, 0, 2, 0, 1, 230, 157, 10, 74, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130]);
  print('File dummy berhasil dibuat: ${dummyFile.path}');

  try {
    final service = CloudinaryService();
    print('Mencoba mengunggah gambar dummy menggunakan Signed Upload...');
    final secureUrl = await service.uploadImage(dummyFile.path, folder: 'simjtk/test');
    print('\n[SUKSES] Upload Berhasil!');
    print('URL Secure: $secureUrl');
  } catch (e) {
    print('\n[GAGAL] Terjadi kesalahan saat upload: $e');
  } finally {
    if (dummyFile.existsSync()) {
      await dummyFile.delete();
      print('File dummy dibersihkan.');
    }
  }
}
