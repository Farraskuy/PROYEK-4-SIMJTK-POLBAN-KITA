import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/controller/aspirasi_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/service/aspirasi_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/model/aspirasi_model.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'dart:convert';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AspirasiController Tests', () {
    late AspirasiController controller;
    final aspirasiStore = <String, Map<String, dynamic>>{};
    final storageData = <String, String>{};

    setUp(() {
      Get.testMode = true;
      aspirasiStore.clear();
      storageData.clear();

      FlutterSecureStoragePlatform.instance =
          TestFlutterSecureStoragePlatform(storageData);
      storageData['current_user_data'] = jsonEncode({
        'id': 'usr-test',
        'name': 'Tester Budi',
      });

      AspirasiService.fetchOverride = (collection, filter) async =>
          aspirasiStore.values.toList();
      AspirasiService.insertOverride = (collection, data) async {
        aspirasiStore[data['_id'].toString()] =
            Map<String, dynamic>.from(data);
      };
      AspirasiService.updateOverride = (collection, filter, data) async {
        aspirasiStore[data['_id'].toString()] =
            Map<String, dynamic>.from(data);
      };

      controller = AspirasiController();
    });

    tearDown(() {
      AspirasiService.fetchOverride = null;
      AspirasiService.insertOverride = null;
      AspirasiService.updateOverride = null;
      Get.reset();
    });

    testWidgets('submitAspirasi should add aspirasi if form is valid',
        (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      // Minimal 20 karakter agar lolos validasi
      controller.isiSaranController.text =
          'Saran ini sudah lebih dari dua puluh karakter lho.';

      await controller.submitAspirasi();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Controller menyimpan ke list lokal, bukan langsung ke service
      expect(controller.displayedAspirasi.length, equals(1));
      expect(
        controller.displayedAspirasi[0].isiSaran,
        equals('Saran ini sudah lebih dari dua puluh karakter lho.'),
      );
      expect(controller.displayedAspirasi[0].pelaporId, equals('usr-test'));
    });

    testWidgets('submitAspirasi does not add if invalid', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      // Kurang dari 20 karakter → invalid
      controller.isiSaranController.text = 'Pendek saja';

      await controller.submitAspirasi();
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Tidak ada yang ditambahkan ke list
      expect(controller.displayedAspirasi.length, equals(0));
      expect(controller.errorIsiSaran.value, isNotEmpty);
    });

    testWidgets('onUpvote increments upvote and adds userId', (tester) async {
      await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: Container())));

      // Buat dummy aspirasi menggunakan constructor yang benar
      final aspirasi = AspirasiModel(
        id: 'asp-1',
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

      aspirasiStore['asp-1'] = aspirasi.toJson();
      await controller.onRefresh();

      expect(
        controller.displayedAspirasi[0].upvoterIds.contains('usr-test'),
        isFalse,
      );

      await controller.onUpvote(controller.displayedAspirasi[0].id);
      await tester.pumpAndSettle(const Duration(seconds: 4));

      expect(
        controller.displayedAspirasi[0].upvoterIds.contains('usr-test'),
        isTrue,
      );
    });
  });
}
