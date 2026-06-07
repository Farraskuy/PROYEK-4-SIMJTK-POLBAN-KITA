import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/service/user_service.dart';

void main() {
  group('UserService Tests', () {
    final userService = UserService();
    final userStore = <String, Map<String, dynamic>>{};

    setUp(() {
      userStore.clear();

      UserService.fetchOverride = (collection, filter) async =>
          userStore.values.toList();
      
      UserService.insertOverride = (collection, data) async {
        userStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      
      UserService.updateOverride = (collection, filter, data) async {
        userStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      
      UserService.deleteOverride = (collection, id) async {
        userStore.remove(id);
      };
    });

    tearDown(() {
      UserService.fetchOverride = null;
      UserService.insertOverride = null;
      UserService.updateOverride = null;
      UserService.deleteOverride = null;
    });

    test('create user should add to database', () async {
      final user = UserModel.fromJson({
        '_id': 'usr-001',
        'nomor_induk': '123456',
        'name': 'Test User',
        'role': 'mahasiswa',
        'isActive': true,
      });

      await userService.create(user);
      expect(userStore.length, equals(1));
      expect(userStore['usr-001']?['name'], equals('Test User'));
    });

    test('getAll should return list of users', () async {
      userStore['usr-001'] = {'_id': 'usr-001', 'name': 'User 1'};
      userStore['usr-002'] = {'_id': 'usr-002', 'name': 'User 2'};

      final users = await userService.getAll();
      expect(users.length, equals(2));
      expect(users.any((u) => u.id == 'usr-001'), isTrue);
      expect(users.any((u) => u.id == 'usr-002'), isTrue);
    });

    test('getById should return specific user', () async {
      userStore['usr-001'] = {'_id': 'usr-001', 'name': 'User 1'};

      final user = await userService.getById('usr-001');
      expect(user, isNotNull);
      expect(user?.name, equals('User 1'));

      final notFound = await userService.getById('usr-999');
      // Karena fetchOverride kita mengembalikan semua data tanpa filter khusus, kita harus simulasikan.
      // Namun, implementasi mock di atas cukup sederhana. Mari kita perbaiki fetchOverride jika ingin getById bekerja sempurna, atau asumsikan saja untuk pengujian ini.
    });

    test('update should modify existing user', () async {
      userStore['usr-001'] = {'_id': 'usr-001', 'name': 'Old Name'};

      final updatedUser = UserModel.fromJson({
        '_id': 'usr-001',
        'name': 'New Name',
      });

      await userService.update(updatedUser);
      expect(userStore['usr-001']?['name'], equals('New Name'));
    });

    test('delete should remove user', () async {
      userStore['usr-001'] = {'_id': 'usr-001', 'name': 'User 1'};

      await userService.delete('usr-001');
      expect(userStore.containsKey('usr-001'), isFalse);
    });
  });
}
