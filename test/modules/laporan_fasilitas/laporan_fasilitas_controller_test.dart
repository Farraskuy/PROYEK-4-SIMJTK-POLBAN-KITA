import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/lapor_fasilitas_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('LaporFasilitasController Tests', () {
    late LaporFasilitasController controller;
    final laporanStore = <String, Map<String, dynamic>>{};
    final storageData = <String, String>{};

    setUp(() {
      Get.testMode = true;
      laporanStore.clear();
      storageData.clear();

      FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(storageData);
      storageData['current_user_data'] = jsonEncode({
        'id': 'usr-test',
        'name': 'Tester Budi',
      });

      LaporanFasilitasService.fetchOverride = (collection, filter) async =>
          laporanStore.values.toList();
      LaporanFasilitasService.insertOverride = (collection, data) async {
        laporanStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      LaporanFasilitasService.updateOverride = (collection, filter, data) async {
        laporanStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };

      controller = LaporFasilitasController();
    });

    tearDown(() {
      LaporanFasilitasService.fetchOverride = null;
      LaporanFasilitasService.insertOverride = null;
      LaporanFasilitasService.updateOverride = null;
      Get.reset();
    });

    testWidgets('setupEditPage prepares controller for editing', (tester) async {
      final laporan = LaporanFasilitasModel(
        id: 'lap-001',
        judul: 'Judul Edit',
        deskripsi: 'Deskripsi Edit',
        lokasi: 'Lokasi Edit',
        foto_urls: ['path/to/foto.jpg'],
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
      await tester.pumpAndSettle(const Duration(seconds: 4));
      
      expect(result, isFalse);
      expect(laporanStore.length, equals(0));
    });

    testWidgets('onSubmitLaporan should succeed for valid form', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      controller.lokasiController.text = 'Gedung Lama';
      controller.deskripsiController.text = 'Pintu rusak susah dibuka';
      controller.judulController.text = 'Pintu Rusak';

      final result = await controller.onSubmitLaporan();
      await tester.pumpAndSettle(const Duration(seconds: 4));
      
      expect(result, isTrue);
      expect(laporanStore.length, equals(1));
      
      final saved = laporanStore.values.first;
      expect(saved['judul'], equals('Pintu Rusak'));
      expect(saved['pelapor_id'], equals('usr-test'));
    });
  });
}
