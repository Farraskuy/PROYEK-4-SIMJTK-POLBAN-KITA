import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../model/penghapusan_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

class PenghapusanController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;

  final tahunUsulanCtrl = TextEditingController();
  final tahunAnggaranCtrl = TextEditingController();
  final pengelolaCtrl = TextEditingController();

  final RxList<Map<String, TextEditingController>> rows = <Map<String, TextEditingController>>[].obs;
  final RxList<PenghapusanModel> dataList = <PenghapusanModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    addRow();
  }

  void addRow() {
    rows.add({
      'nama': TextEditingController(),
      'kondisi': TextEditingController(),
      'no_inv': TextEditingController(),
      'ket': TextEditingController(),
    });
  }

  void removeRow(int index) {
    if (rows.length > 1) rows.removeAt(index);
  }

  Future<bool> submit() async {
    if (!formKey.currentState!.validate()) return false;
    isSubmitting.value = true;

    try {
      final cleanTahunUsulan = tahunUsulanCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      final cleanTahunAnggaran = tahunAnggaranCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

      final newUsulan = PenghapusanModel(
        id: const Uuid().v4(),
        teknisiId: 'TKS001',
        tahunUsulanPenghapusan: int.tryParse(cleanTahunUsulan),
        tahunAnggaran: int.tryParse(cleanTahunAnggaran),
        pengelolaData: pengelolaCtrl.text.trim(),
        items: rows.map((r) => PenghapusanItem(
          namaBarang: r['nama']!.text.trim(),
          kondisiBarang: r['kondisi']!.text.trim(),
          noInventaris: r['no_inv']!.text.trim(),
          keterangan: r['ket']!.text.trim(),
        )).toList(),
        createdAt: DateTime.now(),
      );

      final dbService = MonggoDBServices();
      await dbService.ensureConnected();
      await dbService.insertData('usulan_penghapusan', newUsulan.toJson());

      dataList.add(newUsulan);
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Usulan penghapusan disimpan ke Database',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
      );
      return true;
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Error: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
      );
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    tahunUsulanCtrl.dispose();
    tahunAnggaranCtrl.dispose();
    pengelolaCtrl.dispose();
    for (final r in rows) {
      for (final c in r.values) c.dispose();
    }
    super.onClose();
  }
}