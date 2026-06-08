import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/controller/aspirasi_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/hive_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'dart:convert';

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

    final tempDir = Directory.systemTemp.createTempSync('test_hive_aspirasi_ctrl_');
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

  group('AspirasiController Tests (Real Connection)', () {
    late AspirasiController controller;
    final storageData = <String, String>{};

    setUp(() async {
      Get.testMode = true;
      storageData.clear();

      FlutterSecureStoragePlatform.instance =
          TestFlutterSecureStoragePlatform(storageData);
      storageData['current_user_data'] = jsonEncode({
        'id': 'usr-test',
        'name': 'Tester Budi',
        'nomor_induk': '12345678',
        'role': 'mahasiswa',
        'isActive': true,
      });

      await mongoService.ensureConnected();
      try {
        await mongoService.getCollection('aspirasi').deleteMany({'_id': {'\$regex': '^test-asp-ctrl-'}});
      } catch (_) {}

      await HiveService.init();
      await HiveService.aspirasiBox.clear();
      await HiveService.queueBox.clear();

      controller = AspirasiController();
    });

    tearDown(() async {
      try {
        if (mongoService.isConnected) {
          await mongoService.getCollection('aspirasi').deleteMany({'_id': {'\$regex': '^test-asp-ctrl-'}});
        }
      } catch (_) {}
      Get.reset();
    });

    testWidgets('submitAspirasi should add aspirasi if form is valid',
        (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      controller.judulController.text = 'Judul Aspirasi Valid';
      controller.isiSaranController.text =
          'Saran ini sudah lebih dari dua puluh karakter lho.';

      await controller.submitAspirasi();
      await tester.pump(const Duration(seconds: 4));

      expect(controller.displayedAspirasi.length, equals(1));
      expect(
        controller.displayedAspirasi[0].isiSaran,
        equals('Saran ini sudah lebih dari dua puluh karakter lho.'),
      );
    });

    testWidgets('submitAspirasi does not add if invalid', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      controller.judulController.text = 'Pendek';
      controller.isiSaranController.text = 'Pendek saja';

      await controller.submitAspirasi();
      await tester.pump(const Duration(seconds: 4));

      expect(controller.displayedAspirasi.length, equals(0));
      expect(controller.errorIsiSaran.value, isNotEmpty);
    });

    testWidgets('onUpvote increments upvote and adds userId', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      final aspirasi = AspirasiModel(
        id: 'test-asp-ctrl-001',
        topik: 'Topik A',
        isiSaran: 'Isi saran ini cukup panjang untuk lolos validasi',
        pelaporId: 'usr-1',
        pelaporName: 'User Satu',
        upvoteCount: 0,
        upvoterIds: const [],
        status: StatusAspirasi.open,
        kategori: KategoriAspirasi.umum,
        createdAt: DateTime.now(),
      );

      // Insert directly
      await mongoService.insertData('aspirasi', aspirasi.toJson());
      await controller.onRefresh();

      expect(controller.displayedAspirasi.length, greaterThanOrEqualTo(1));
      final itemIndex = controller.displayedAspirasi.indexWhere((a) => a.id == aspirasi.id);
      expect(itemIndex, isNot(-1));

      final target = controller.displayedAspirasi[itemIndex];
      expect(target.upvoterIds.contains('usr-test'), isFalse);

      await controller.onUpvote(target.id);
      await tester.pump(const Duration(seconds: 4));

      final updatedIndex = controller.displayedAspirasi.indexWhere((a) => a.id == aspirasi.id);
      expect(controller.displayedAspirasi[updatedIndex].upvoterIds.contains('usr-test'), isTrue);
    });
  });
}
