import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

class LaporanFasilitasService {
  static const String collectionName = 'laporan_fasilitas';

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
    SelectorBuilder filter,
    Map<String, dynamic> data,
  )? updateOverride;

  @visibleForTesting
  static Future<void> Function(String collection, String id)? deleteOverride;

  Future<LaporanFasilitasModel> create(LaporanFasilitasModel laporan) async {
    final data = laporan.toJson();
    final override = insertOverride;
    if (override != null) {
      await override(collectionName, data);
      return laporan;
    }

    await MonggoDBServices().insertData(collectionName, data);
    return laporan;
  }

  Future<List<LaporanFasilitasModel>> getAll() async {
    final override = fetchOverride;
    final rows = override != null
        ? await override(collectionName, where.exists('_id'))
        : await MonggoDBServices().fetch(collectionName, where.exists('_id'));

    return rows.map(LaporanFasilitasModel.fromJson).toList();
  }

  Future<LaporanFasilitasModel?> getById(String id) async {
    final rows = await _fetchByFilter(where.eq('_id', id));
    if (rows.isEmpty) {
      return null;
    }

    return LaporanFasilitasModel.fromJson(rows.first);
  }

  Future<LaporanFasilitasModel> update(LaporanFasilitasModel laporan) async {
    final override = updateOverride;
    final data = laporan.toJson();
    if (override != null) {
      await override(collectionName, where.eq('_id', laporan.id), data);
      return laporan;
    }

    await MonggoDBServices().updateOneByFilter(
      collectionName,
      where.eq('_id', laporan.id),
      data,
    );
    return laporan;
  }

  Future<void> delete(String id) async {
    final override = deleteOverride;
    if (override != null) {
      await override(collectionName, id);
      return;
    }

    await MonggoDBServices().deleteData(collectionName, id);
  }

  Future<List<Map<String, dynamic>>> _fetchByFilter(SelectorBuilder filter) async {
    final override = fetchOverride;
    if (override != null) {
      return override(collectionName, filter);
    }

    return MonggoDBServices().fetch(collectionName, filter);
  }
}