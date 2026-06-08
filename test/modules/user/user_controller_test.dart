import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/controller/admin_user_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/service/user_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/hive_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

void main() {
  late MonggoDBServices mongoService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'check') {
          return ['wifi'];
        }
        return null;
      },
    );

    final tempDir = Directory.systemTemp.createTempSync('test_hive_user_ctrl_');
    HiveService.testPath = tempDir.path;

    final envFile = File('.env');
    if (envFile.existsSync()) {
      dotenv.loadFromString(envString: envFile.readAsStringSync());
    }
    mongoService = MonggoDBServices();
    await mongoService.connect();
  });

  tearDownAll(() async {
    await mongoService.close();
    await Hive.close();
    try {
      final dir = Directory(HiveService.testPath!);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  group('AdminUserController Tests (Real Connection)', () {
    late AdminUserController controller;
    late UserService userService;

    setUp(() async {
      Get.testMode = true;

      await mongoService.ensureConnected();
      try {
        await mongoService.getCollection('users').deleteMany({'_id': {'\$regex': '^test-usr-ctrl-'}});
      } catch (_) {}

      await HiveService.init();
      await HiveService.laporanBox.clear();
      await HiveService.queueBox.clear();

      userService = UserService();
      controller = AdminUserController(userService: userService);
    });

    tearDown(() async {
      try {
        if (mongoService.isConnected) {
          await mongoService.getCollection('users').deleteMany({'_id': {'\$regex': '^test-usr-ctrl-'}});
        }
      } catch (_) {}
      Get.reset();
    });

    testWidgets('fetchUsers should populate users list and toggle loading state', (tester) async {
      final u1 = UserModel.fromJson({
        '_id': 'test-usr-ctrl-001',
        'nomor_induk': '123',
        'password_hash': 'h1',
        'name': 'User 1',
        'role': 'mahasiswa',
        'isActive': true,
      });
      final u2 = UserModel.fromJson({
        '_id': 'test-usr-ctrl-002',
        'nomor_induk': '456',
        'password_hash': 'h2',
        'name': 'User 2',
        'role': 'mahasiswa',
        'isActive': true,
      });

      await userService.create(u1);
      await userService.create(u2);

      await controller.fetchUsers();

      expect(controller.isLoading.value, isFalse);
      expect(controller.users.any((u) => u.id == 'test-usr-ctrl-001'), isTrue);
      expect(controller.users.any((u) => u.id == 'test-usr-ctrl-002'), isTrue);
    });

    testWidgets('deleteUser should remove user from list', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      final u1 = UserModel.fromJson({
        '_id': 'test-usr-ctrl-003',
        'nomor_induk': '789',
        'password_hash': 'h3',
        'name': 'User 3',
        'role': 'mahasiswa',
        'isActive': true,
      });

      await userService.create(u1);
      await controller.fetchUsers();
      
      expect(controller.users.any((u) => u.id == 'test-usr-ctrl-003'), isTrue);

      await controller.deleteUser('test-usr-ctrl-003');
      await tester.pump(const Duration(seconds: 4));

      expect(controller.users.any((u) => u.id == 'test-usr-ctrl-003'), isFalse);
    });
  });
}
