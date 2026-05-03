import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:proyek_4_poki_polban_kita/modules/kategori_fasilitas/model/kategori_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

class KategoriFasilitasService {
  static const String collectionName = 'kategori_fasilitas';

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

  Future<KategoriFasilitasModel> create(KategoriFasilitasModel kategori) async {
    final data = kategori.toJson();
    final override = insertOverride;
    if (override != null) {
      await override(collectionName, data);
      return kategori;
    }

    await MonggoDBServices().insertData(collectionName, data);
    return kategori;
  }

  Future<List<KategoriFasilitasModel>> getAll() async {
    final override = fetchOverride;
    final rows = override != null
        ? await override(collectionName, where.exists('_id'))
        : await MonggoDBServices().fetch(collectionName, where.exists('_id'));

    return rows.map(KategoriFasilitasModel.fromJson).toList();
  }

  Future<KategoriFasilitasModel?> getById(String id) async {
    final rows = await _fetchByFilter(where.eq('_id', id));
    if (rows.isEmpty) {
      return null;
    }

    return KategoriFasilitasModel.fromJson(rows.first);
  }

  Future<KategoriFasilitasModel> update(KategoriFasilitasModel kategori) async {
    final override = updateOverride;
    final data = kategori.toJson();
    if (override != null) {
      await override(collectionName, where.eq('_id', kategori.id), data);
      return kategori;
    }

    await MonggoDBServices().updateOneByFilter(
      collectionName,
      where.eq('_id', kategori.id),
      data,
    );
    return kategori;
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