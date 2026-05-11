import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../model/penghapusan_model.dart';
 

class PenghapusanController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;

  final tahunUsulanCtrl = TextEditingController();
  final tahunAnggaranCtrl = TextEditingController();
  final pengelolaCtrl = TextEditingController();

  final RxList<Map<String, TextEditingController>> rows =
      <Map<String, TextEditingController>>[].obs;

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
    await Future.delayed(const Duration(milliseconds: 400));

    dataList.add(
      PenghapusanModel(
        id: const Uuid().v4(),
        teknisiId: 'TKS001', // TODO: ambil dari session
        tahunUsulanPenghapusan: tahunUsulanCtrl.text,
        tahunAnggaran: tahunAnggaranCtrl.text,
        pengelolaData: pengelolaCtrl.text,
        items: rows
            .map(
              (r) => PenghapusanItem(
                namaBarang: r['nama']!.text,
                kondisiBarang: r['kondisi']!.text,
                noInventaris: r['no_inv']!.text,
                keterangan: r['ket']!.text,
              ),
            )
            .toList(),
        createdAt: DateTime.now(),
      ),
    );

    isSubmitting.value = false;
    Get.snackbar(
      'Berhasil',
      'Usulan penghapusan disimpan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
    );
    return true;
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
