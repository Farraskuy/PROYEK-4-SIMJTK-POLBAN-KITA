import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/lapor_fasilitas_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
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

    final tempDir = Directory.systemTemp.createTempSync('test_hive_laporan_ctrl_');
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

  group('LaporFasilitasController Tests (Real Connection)', () {
    late LaporFasilitasController controller;
    final storageData = <String, String>{};

    setUp(() async {
      Get.testMode = true;
      storageData.clear();

      FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(storageData);
      storageData['current_user_data'] = jsonEncode({
        'id': 'usr-test',
        'name': 'Tester Budi',
        'nomor_induk': '12345678',
        'role': 'mahasiswa',
        'isActive': true,
      });

      await mongoService.ensureConnected();
      try {
        await mongoService.getCollection('laporan_fasilitas').deleteMany({'_id': {'\$regex': '^test-lap-ctrl-'}});
      } catch (_) {}

      await HiveService.init();
      await HiveService.laporanBox.clear();
      await HiveService.queueBox.clear();

      controller = LaporFasilitasController();
    });

    tearDown(() async {
      try {
        if (mongoService.isConnected) {
          await mongoService.getCollection('laporan_fasilitas').deleteMany({'_id': {'\$regex': '^test-lap-ctrl-'}});
        }
      } catch (_) {}
      Get.reset();
    });

    testWidgets('setupEditPage prepares controller for editing', (tester) async {
      final laporan = LaporanFasilitasModel(
        id: 'test-lap-ctrl-001',
        judul: 'Judul Edit',
        deskripsi: 'Deskripsi Edit',
        lokasi: 'Lokasi Edit',
        foto_urls: const ['path/to/foto.jpg'],
        pelapor_id: 'usr-1',
        status: StatusLaporan.pending.value,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      controller.setupEditPage(laporan);

      expect(controller.isEditMode.value, isTrue);
      expect(controller.judulController.text, equals('Judul Edit'));
      expect(controller.lokasiController.text, equals('Lokasi Edit'));
      expect(controller.selectedFotoPaths.length, equals(1));
    });

    testWidgets('onSubmitLaporan should fail if required fields are empty', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));
      
      final result = await controller.onSubmitLaporan();
      await tester.pump(const Duration(seconds: 4));
      
      expect(result, isFalse);
    });

    testWidgets('onSubmitLaporan should succeed for valid form', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      controller.lokasiController.text = 'Gedung Lama';
      controller.deskripsiController.text = 'Pintu rusak susah dibuka';
      controller.judulController.text = 'Pintu Rusak';

      final result = await controller.onSubmitLaporan();
      await tester.pump(const Duration(seconds: 4));
      
      expect(result, isTrue);
    });
  });
}
