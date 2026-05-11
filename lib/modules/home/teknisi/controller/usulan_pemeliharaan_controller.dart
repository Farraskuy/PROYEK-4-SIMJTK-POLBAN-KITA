import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../model/usulan_pemeliharaan_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/app_navigator.dart';

class UsulanPemeliharaanController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;

  final tahunUsulanCtrl = TextEditingController();
  final tahunAnggaranCtrl = TextEditingController();
  final pengelolaCtrl = TextEditingController();

  // Setiap row = 1 item usulan
  final RxList<Map<String, TextEditingController>> rows =
      <Map<String, TextEditingController>>[].obs;

  final RxList<UsulanPemeliharaanModel> dataList =
      <UsulanPemeliharaanModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    addRow(); // mulai dengan 1 baris kosong
  }

  void addRow() {
    rows.add({
      'nama': TextEditingController(),
      'spesifikasi': TextEditingController(),
      'kegiatan': TextEditingController(),
      'tingkat': TextEditingController(),
      'vol': TextEditingController(),
      'sat': TextEditingController(),
      'harga': TextEditingController(),
      'jumlah': TextEditingController(),
    });
  }

  void removeRow(int index) {
    if (rows.length > 1) rows.removeAt(index);
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 400));

    dataList.add(
      UsulanPemeliharaanModel(
        id: const Uuid().v4(),
        teknisiId: 'TKS001', // TODO: ambil dari session
        tahunUsulan: tahunUsulanCtrl.text,
        tahunAnggaran: tahunAnggaranCtrl.text,
        pengelolaData: pengelolaCtrl.text,
        items: rows
            .map(
              (r) => UsulanPemeliharaanItem(
                namaBarangAlat: r['nama']!.text,
                spesifikasi: r['spesifikasi']!.text,
                spesifikasiTeknis: r['kegiatan']!.text,
                tingkatKerusakan: r['tingkat']!.text,
                volume: r['vol']!.text,
                satuan: r['sat']!.text,
                hargaSatuan: r['harga']!.text,
                jumlah: r['jumlah']!.text,
              ),
            )
            .toList(),
        createdAt: DateTime.now(),
      ),
    );

    isSubmitting.value = false;
    AppNavigator.pop();
    Get.snackbar(
      'Berhasil',
      'Usulan pemeliharaan disimpan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
    );
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
