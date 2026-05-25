// ============================================================
// FILE: modules/aspirasi/service/aspirasi_service.dart
// ============================================================

import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import '../model/aspirasi_model.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AspirasiService {
  static const String _collectionName = 'aspirasi';
  final MonggoDBServices _db = MonggoDBServices();

  /// Mengambil semua data aspirasi dari MongoDB
  Future<List<AspirasiModel>> fetchAllAspirasi() async {
      try {
        // Tambahkan 'where' sebagai argumen kedua untuk filter kosong
        final data = await _db.fetch(_collectionName, where);
        
        // ATAU, jika Anda ingin datanya langsung di-sort dari database berdasarkan waktu terbaru:
        // final data = await _db.fetch(_collectionName, where.sortBy('createdAt', descending: true));
        
        return data.map((e) => AspirasiModel.fromJson(e)).toList();
      } catch (e) {
        throw Exception('Gagal memuat aspirasi: $e');
      }
    }

  /// Menyimpan aspirasi baru ke MongoDB
  Future<void> createAspirasi(AspirasiModel aspirasi) async {
    try {
      await _db.insertData(_collectionName, aspirasi.toJson());
    } catch (e) {
      throw Exception('Gagal menyimpan aspirasi: $e');
    }
  }

  /// Memperbarui aspirasi yang ada (contoh: untuk sistem vote nanti)
  Future<void> updateAspirasi(AspirasiModel aspirasi) async {
    try {
      // Asumsi MonggoDBServices punya fungsi update. 
      // Sesuaikan parameter updatenya berdasarkan fungsi yang ada di layanan Anda.
      await _db.updateData(_collectionName, aspirasi.id, aspirasi.toJson());
    } catch (e) {
      throw Exception('Gagal memperbarui aspirasi: $e');
    }
  }
}