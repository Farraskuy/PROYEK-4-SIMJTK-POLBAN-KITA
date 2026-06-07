import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/controller/admin_user_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/service/user_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('AdminUserController Tests', () {
    late AdminUserController controller;
    late UserService userService;
    final userStore = <String, Map<String, dynamic>>{};

    setUp(() {
      Get.testMode = true; // Enable GetX test mode
      
      userStore.clear();

      UserService.fetchOverride = (collection, filter) async =>
          userStore.values.toList();
      UserService.deleteOverride = (collection, id) async {
        userStore.remove(id);
      };

      userService = UserService();
      controller = AdminUserController(userService: userService);
    });

    tearDown(() {
      UserService.fetchOverride = null;
      UserService.deleteOverride = null;
      Get.reset();
    });

    testWidgets('fetchUsers should populate users list and toggle loading state', (tester) async {
      userStore['usr-001'] = {'_id': 'usr-001', 'name': 'User 1'};
      userStore['usr-002'] = {'_id': 'usr-002', 'name': 'User 2'};

      expect(controller.isLoading.value, isTrue); // Inisial state bisa true

      await controller.fetchUsers();

      expect(controller.isLoading.value, isFalse);
      expect(controller.users.length, equals(2));
      expect(controller.users[0].name, equals('User 1'));
    });

    testWidgets('deleteUser should remove user from list', (tester) async {
      // Pump GetMaterialApp agar Get.snackbar memiliki context
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      userStore['usr-001'] = {'_id': 'usr-001', 'name': 'User 1'};
      await controller.fetchUsers();
      
      expect(controller.users.length, equals(1));

      await controller.deleteUser('usr-001');
      await tester.pumpAndSettle(const Duration(seconds: 4));

      expect(controller.users.length, equals(0));
      expect(userStore.containsKey('usr-001'), isFalse);
    });
  });
}
