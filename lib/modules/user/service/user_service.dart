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
    final rows = await MonggoDBServices().fetchAll(collectionName);
    return rows.map(UserModel.fromJson).toList();
  }

  Future<UserModel?> getById(String id) async {
    final rows = await MonggoDBServices().fetchByField(
      collectionName,
      '_id',
      id,
    );
    if (rows.isEmpty) {
      return null;
    }

    return UserModel.fromJson(rows.first);
  }

  Future<UserModel> update(UserModel user) async {
    final data = user.toJson();
    await MonggoDBServices().updateById(
      collectionName,
      user.id,
      data,
    );
    return user;
  }

  Future<void> delete(String id) async {
    await MonggoDBServices().deleteData(collectionName, id);
  }
}
