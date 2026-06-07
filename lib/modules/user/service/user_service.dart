import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

class UserService {
  static const String collectionName = 'users';

  Future<UserModel> create(UserModel user) async {
    final data = user.toJson();
    await MonggoDBServices().insertData(collectionName, data);
    return user;
  }

  Future<List<UserModel>> getAll() async {
    final rows = await MonggoDBServices().fetch(collectionName, where.exists('_id'));
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
    final data = user.toJson();
    await MonggoDBServices().updateOneByFilter(
      collectionName,
      where.eq('_id', user.id),
      data,
    );
    return user;
  }

  Future<void> delete(String id) async {
    await MonggoDBServices().deleteData(collectionName, id);
  }

  Future<List<Map<String, dynamic>>> _fetchByFilter(SelectorBuilder filter) async {
    return MonggoDBServices().fetch(collectionName, filter);
  }
}