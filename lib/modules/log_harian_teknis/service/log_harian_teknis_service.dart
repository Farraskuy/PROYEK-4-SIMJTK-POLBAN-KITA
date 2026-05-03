import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:proyek_4_poki_polban_kita/modules/log_harian_teknis/model/log_harian_teknis_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

class LogHarianTeknisService {
  static const String collectionName = 'log_harian_teknis';

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

  Future<LogHarianTeknisModel> create(LogHarianTeknisModel log) async {
    final data = log.toJson();
    final override = insertOverride;
    if (override != null) {
      await override(collectionName, data);
      return log;
    }

    await MonggoDBServices().insertData(collectionName, data);
    return log;
  }

  Future<List<LogHarianTeknisModel>> getAll() async {
    final override = fetchOverride;
    final rows = override != null
        ? await override(collectionName, where.exists('_id'))
        : await MonggoDBServices().fetch(collectionName, where.exists('_id'));

    return rows.map(LogHarianTeknisModel.fromJson).toList();
  }

  Future<LogHarianTeknisModel?> getById(String id) async {
    final rows = await _fetchByFilter(where.eq('_id', id));
    if (rows.isEmpty) {
      return null;
    }

    return LogHarianTeknisModel.fromJson(rows.first);
  }

  Future<LogHarianTeknisModel> update(LogHarianTeknisModel log) async {
    final override = updateOverride;
    final data = log.toJson();
    if (override != null) {
      await override(collectionName, where.eq('_id', log.id), data);
      return log;
    }

    await MonggoDBServices().updateOneByFilter(
      collectionName,
      where.eq('_id', log.id),
      data,
    );
    return log;
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