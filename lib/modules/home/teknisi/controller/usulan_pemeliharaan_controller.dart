import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../model/usulan_pemeliharaan_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

class UsulanPemeliharaanController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;

  final tahunUsulanCtrl = TextEditingController();
  final tahunAnggaranCtrl = TextEditingController();
  final pengelolaCtrl = TextEditingController();

  // Setiap row = 1 item usulan
  final RxList<Map<String, TextEditingController>> rows = <Map<String, TextEditingController>>[].obs;

  final RxList<UsulanPemeliharaanModel> dataList =
      <UsulanPemeliharaanModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    addRow();
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

  Future<bool> submit() async {
    if (!formKey.currentState!.validate()) return false;
    isSubmitting.value = true;

    try {
      final cleanTahunUsulan = tahunUsulanCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
      final cleanTahunAnggaran = tahunAnggaranCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

      final newUsulan = UsulanPemeliharaanModel(
        id: const Uuid().v4(),
        teknisiId: 'TKS001',
        tahunUsulan: int.tryParse(cleanTahunUsulan),
        tahunAnggaran: int.tryParse(cleanTahunAnggaran),
        pengelolaData: pengelolaCtrl.text.trim(),
        items: rows.map((r) {
          final cleanVol = r['vol']!.text.replaceAll(RegExp(r'[^0-9\.]'), '');
          final cleanHarga = r['harga']!.text.replaceAll(RegExp(r'[^0-9]'), '');
          final cleanJumlah = r['jumlah']!.text.replaceAll(RegExp(r'[^0-9]'), '');
          return UsulanPemeliharaanItem(
            namaBarangAlat: r['nama']!.text.trim(),
            spesifikasi: r['spesifikasi']!.text.trim(),
            spesifikasiTeknis: r['kegiatan']!.text.trim(),
            tingkatKerusakan: r['tingkat']!.text.trim(),
            volume: double.tryParse(cleanVol),
            satuan: r['sat']!.text.trim(),
            hargaSatuan: double.tryParse(cleanHarga),
            jumlah: double.tryParse(cleanJumlah),
          );
        }).toList(),
        createdAt: DateTime.now(),
      );

      final dbService = MonggoDBServices();
      await dbService.ensureConnected();
      await dbService.insertData('usulan_pemeliharaan', newUsulan.toJson());

      dataList.add(newUsulan);
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Usulan pemeliharaan disimpan ke Database',
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
      for (final c in r.values) {
        c.dispose();
      }
    }
    super.onClose();
  }
}