// ============================================================
// FILE: modules/aspirasi/service/aspirasi_service.dart
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import '../model/aspirasi_model.dart';
import 'package:mongo_dart/mongo_dart.dart';

class AspirasiService {
  static const String _collectionName = 'aspirasi';
  final MonggoDBServices _db = MonggoDBServices();

  @visibleForTesting
  static Future<List<Map<String, dynamic>>> Function(
    String collection,
    SelectorBuilder filter,
  )? fetchOverride;

  @visibleForTesting
  static Future<void> Function(String collection, Map<String, dynamic> data)?
      insertOverride;

  @visibleForTesting
  static Future<void> Function(
    String collection,
    dynamic id,
    Map<String, dynamic> data,
  )? updateOverride;

  @visibleForTesting
  static Future<void> Function(String collection, String id)? deleteOverride;

  /// Mengambil semua data aspirasi dari MongoDB
  Future<List<AspirasiModel>> fetchAllAspirasi() async {
    try {
      final override = fetchOverride;
      final data = override != null
          ? await override(_collectionName, where)
          : await _db.fetch(_collectionName, where);
      
      return data.map((e) => AspirasiModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Gagal memuat aspirasi: $e');
    }
  }

  /// Menyimpan aspirasi baru ke MongoDB
  Future<void> createAspirasi(AspirasiModel aspirasi) async {
    try {
      final override = insertOverride;
      if (override != null) {
        await override(_collectionName, aspirasi.toJson());
        return;
      }
      await _db.insertData(_collectionName, aspirasi.toJson());
    } catch (e) {
      throw Exception('Gagal menyimpan aspirasi: $e');
    }
  }

  /// Memperbarui aspirasi yang ada (contoh: untuk sistem vote nanti)
  Future<void> updateAspirasi(AspirasiModel aspirasi) async {
    try {
      final override = updateOverride;
      if (override != null) {
        await override(_collectionName, aspirasi.id, aspirasi.toJson());
        return;
      }
      await _db.updateData(_collectionName, aspirasi.id, aspirasi.toJson());
    } catch (e) {
      throw Exception('Gagal memperbarui aspirasi: $e');
    }
  }
}