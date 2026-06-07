import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:proyek_4_poki_polban_kita/modules/kategori_fasilitas/model/kategori_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

class KategoriFasilitasService {
  static const String collectionName = 'kategori_fasilitas';

  Future<KategoriFasilitasModel> create(KategoriFasilitasModel kategori) async {
    final data = kategori.toJson();
    await MonggoDBServices().insertData(collectionName, data);
    return kategori;
  }

  Future<List<KategoriFasilitasModel>> getAll() async {
    final rows = await MonggoDBServices().fetch(collectionName, where.exists('_id'));
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
    final data = kategori.toJson();
    await MonggoDBServices().updateOneByFilter(
      collectionName,
      where.eq('_id', kategori.id),
      data,
    );
    return kategori;
  }

  Future<void> delete(String id) async {
    await MonggoDBServices().deleteData(collectionName, id);
  }

  Future<List<Map<String, dynamic>>> _fetchByFilter(SelectorBuilder filter) async {
    return MonggoDBServices().fetch(collectionName, filter);
  }
}