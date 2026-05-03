import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

class UserService {
  static const String collectionName = 'users';

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

  Future<UserModel> create(UserModel user) async {
    final data = user.toJson();
    final override = insertOverride;
    if (override != null) {
      await override(collectionName, data);
      return user;
    }

    await MonggoDBServices().insertData(collectionName, data);
    return user;
  }

  Future<List<UserModel>> getAll() async {
    final override = fetchOverride;
    final rows = override != null
        ? await override(collectionName, where.exists('_id'))
        : await MonggoDBServices().fetch(collectionName, where.exists('_id'));

    return rows.map(UserModel.fromJson).toList();
  }

  Future<UserModel?> getById(String id) async {
    final rows = await _fetchByFilter(where.eq('_id', id));
    if (rows.isEmpty) {
      return null;
    }

    return UserModel.fromJson(rows.first);
  }

  Future<UserModel> update(UserModel user) async {
    final override = updateOverride;
    final data = user.toJson();
    if (override != null) {
      await override(collectionName, where.eq('_id', user.id), data);
      return user;
    }

    await MonggoDBServices().updateOneByFilter(
      collectionName,
      where.eq('_id', user.id),
      data,
    );
    return user;
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