import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/kontrol_barang_model.dart';
import 'package:uuid/uuid.dart';

class DataKontrolBarangController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;

  // Tabel A
  final namaRuangCtrl = TextEditingController();
  final namaBarangCtrl = TextEditingController();
  final noInventarisCtrl = TextEditingController();
  final idKomputerCtrl = TextEditingController();
  final statusBarangCtrl = TextEditingController();
  final asalBarangCtrl = TextEditingController();
  final tahunPerolehanCtrl = TextEditingController();
  final prakiraanHargaCtrl = TextEditingController();

  // Tabel B
  final List<String> hardwareLabels = ['Mainboard', 'Prosesor', 'Harddisk', 'RAM', 'VGA', 'LAN', 'Sound', 'CDROOM', 'Diskdrive', 'Keyboard', 'Mouse', 'Monitor'];
  late final List<TextEditingController> hardwareCtrls;

  // Tabel C
  final osCtrl = TextEditingController();
  // Refactored to a reactive dynamic list for scalability
  final RxList<TextEditingController> aplikasiCtrls = <TextEditingController>[].obs;

  // Tabel F
  final RxList<Map<String, TextEditingController>> biayaRows = <Map<String, TextEditingController>>[].obs;

  final RxList<DataKontrolBarangModel> dataList = <DataKontrolBarangModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    hardwareCtrls = List.generate(12, (_) => TextEditingController());
    _addBiayaRow();
    addAplikasiRow(); // Initialize with at least one field
  }

  void _addBiayaRow() {
    biayaRows.add({
      'komponen_rusak': TextEditingController(),
      'komponen_pengganti': TextEditingController(),
      'biaya': TextEditingController(),
      'sumber_dana': TextEditingController(),
      'ditangani': TextEditingController(),
    });
  }

  void addBiayaRow() => _addBiayaRow();

  // Dynamic Application Methods
  void addAplikasiRow() => aplikasiCtrls.add(TextEditingController());

  void removeAplikasiRow(int index) {
    // Explicit disposal prevents memory leaks when dynamic widgets are destroyed
    aplikasiCtrls[index].dispose();
    aplikasiCtrls.removeAt(index);
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 500));

    final data = DataKontrolBarangModel(
      id: const Uuid().v4(),
      teknisiId: 'TKS001',
      namaRuangLab: namaRuangCtrl.text,
      namaBarangAlat: namaBarangCtrl.text,
      noInventaris: noInventarisCtrl.text,
      idKomputer: idKomputerCtrl.text,
      statusBarang: statusBarangCtrl.text,
      asalBarang: asalBarangCtrl.text,
      tahunPerolehan: tahunPerolehanCtrl.text,
      prakiraanHarga: prakiraanHargaCtrl.text,
      spesifikasiHardware: List.generate(12, (i) => SpesifikasiHardware(komponen: hardwareLabels[i], nilai: hardwareCtrls[i].text)),
      operatingSystem: osCtrl.text,
      aplikasi: aplikasiCtrls.map((c) => c.text).where((t) => t.trim().isNotEmpty).toList(),
      pemeriksaanBerkala: [],
      biayaPerbaikan: biayaRows.map((r) => BiayaPerbaikanItem(
        komponenRusak: r['komponen_rusak']!.text,
        komponenPengganti: r['komponen_pengganti']!.text,
        biayaPerbaikan: r['biaya']!.text,
        sumberDana: r['sumber_dana']!.text,
        ditanganiOleh: r['ditangani']!.text,
      )).toList(),
      createdAt: DateTime.now(),
    );

    dataList.add(data);
    isSubmitting.value = false;
    Get.back();
    Get.snackbar('Berhasil', 'Data kontrol barang disimpan', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green.shade100);
  }

  @override
  void onClose() {
    namaRuangCtrl.dispose(); namaBarangCtrl.dispose(); noInventarisCtrl.dispose();
    idKomputerCtrl.dispose(); statusBarangCtrl.dispose(); asalBarangCtrl.dispose();
    tahunPerolehanCtrl.dispose(); prakiraanHargaCtrl.dispose(); osCtrl.dispose();
    for (final c in hardwareCtrls) c.dispose();
    for (final c in aplikasiCtrls) c.dispose();
    super.onClose();
  }
}