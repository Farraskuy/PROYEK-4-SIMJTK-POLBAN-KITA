// ============================================================
// FILE: modules/aspirasi/service/aspirasi_service.dart
// ============================================================

import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import '../model/aspirasi_model.dart';
import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AspirasiService {
  static const String _collectionName = 'aspirasi';
  final MonggoDBServices _db = MonggoDBServices();

  /// Mengambil semua data aspirasi dari MongoDB
  Future<List<AspirasiModel>> fetchAllAspirasi() async {
      try {
        final data = await _db.fetch(_collectionName, where);
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
      await _db.updateData(_collectionName, aspirasi.id, aspirasi.toJson());
    } catch (e) {
      throw Exception('Gagal memperbarui aspirasi: $e');
    }
  }

  /// Menghapus aspirasi dari MongoDB
  Future<void> deleteAspirasi(String id) async {
    try {
      await _db.deleteData(_collectionName, id);
    } catch (e) {
      throw Exception('Gagal menghapus aspirasi: $e');
    }
  }
}
