import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/kategori_fasilitas/controller/kategori_fasilitas_controller.dart';

void main() {
  group('KategoriFasilitasController Tests', () {
    late KategoriFasilitasController controller;

    setUp(() {
      Get.testMode = true;
      controller = KategoriFasilitasController();
    });

    tearDown(() {
      Get.reset();
    });

    test('Controller initializes with dummy items', () {
      expect(controller.items, isNotEmpty);
      expect(controller.items.first.id, isNotEmpty);
      expect(controller.items.first.namaKategori, isNotEmpty);
    });
  });
}
