// lib/modules/teknisi/analisa_kerusakan/controller/analisa_kerusakan_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/analisa_kerusakan_model.dart';

class AnalisaKerusakanController extends GetxController {
  // ── State ──────────────────────────────────────────────────────────────────
  final RxList<AnalisaKerusakanModel> analisaList =
      <AnalisaKerusakanModel>[].obs;
  final RxList<LaporanSingkat> laporanAktif = <LaporanSingkat>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString filterKategori = 'semua'.obs;

  // Form state (untuk FormAnalisaView)
  final Rx<LaporanSingkat?> selectedLaporan = Rx<LaporanSingkat?>(null);
  final RxString diagnosaMasalah = ''.obs;
  final RxString komponenRusak = ''.obs;
  final Rx<KategoriKerusakan> kategoriKerusakan =
      KategoriKerusakan.hardware.obs;
  final Rx<TingkatKerusakan> tingkatKerusakan =
      TingkatKerusakan.sedang.obs;
  final RxString tindakanDirekomendasikan = ''.obs;
  final RxString catatanTambahan = ''.obs;
  final RxInt estimasiHari = 0.obs;
  final RxDouble estimasiBiaya = 0.0.obs;
  final RxBool isSubmitting = false.obs;

  // TextEditingControllers (dibuat di sini agar bisa di-dispose)
  late final TextEditingController diagnosaMasalahCtrl;
  late final TextEditingController komponenRusakCtrl;
  late final TextEditingController tindakanCtrl;
  late final TextEditingController catatanCtrl;
  late final TextEditingController estimasiHariCtrl;
  late final TextEditingController estimasiBiayaCtrl;

  // Info teknisi yang login (sesuai user TKS001 dari info proyek)
  final String teknisiId = 'user-tks001';
  final String teknisiName = 'Teknisi';

  @override
  void onInit() {
    super.onInit();
    diagnosaMasalahCtrl = TextEditingController();
    komponenRusakCtrl = TextEditingController();
    tindakanCtrl = TextEditingController();
    catatanCtrl = TextEditingController();
    estimasiHariCtrl = TextEditingController();
    estimasiBiayaCtrl = TextEditingController();
    loadData();
  }

  @override
  void onClose() {
    diagnosaMasalahCtrl.dispose();
    komponenRusakCtrl.dispose();
    tindakanCtrl.dispose();
    catatanCtrl.dispose();
    estimasiHariCtrl.dispose();
    estimasiBiayaCtrl.dispose();
    super.onClose();
  }

  // ── Load ───────────────────────────────────────────────────────────────────

  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      // TODO: ganti dengan API call ke MongoDB saat backend siap
      laporanAktif.assignAll(dummyLaporanAktif);
      analisaList.assignAll(dummyAnalisaList);
    } catch (e) {
      errorMessage.value = 'Gagal memuat data: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Getters / Filter ───────────────────────────────────────────────────────

  List<AnalisaKerusakanModel> get filteredAnalisa {
    if (filterKategori.value == 'semua') return analisaList;
    return analisaList
        .where((a) => a.kategoriKerusakan.value == filterKategori.value)
        .toList();
  }

  /// Laporan yang belum punya analisa
  List<LaporanSingkat> get laporanBelumDianalisa {
    final sudahDianalisa =
        analisaList.map((a) => a.laporanId).toSet();
    return laporanAktif
        .where((l) => !sudahDianalisa.contains(l.id))
        .toList();
  }

  bool laporanSudahDianalisa(String laporanId) =>
      analisaList.any((a) => a.laporanId == laporanId);

  // ── Form ───────────────────────────────────────────────────────────────────

  void resetForm() {
    selectedLaporan.value = null;
    diagnosaMasalahCtrl.clear();
    komponenRusakCtrl.clear();
    tindakanCtrl.clear();
    catatanCtrl.clear();
    estimasiHariCtrl.clear();
    estimasiBiayaCtrl.clear();
    kategoriKerusakan.value = KategoriKerusakan.hardware;
    tingkatKerusakan.value = TingkatKerusakan.sedang;
    isSubmitting.value = false;
  }

  void setLaporan(LaporanSingkat laporan) {
    selectedLaporan.value = laporan;
  }

  void setKategoriKerusakan(KategoriKerusakan k) {
    kategoriKerusakan.value = k;
  }

  void setTingkatKerusakan(TingkatKerusakan t) {
    tingkatKerusakan.value = t;
  }

  // ── Submit ─────────────────────────────────────────────────────────────────

  Future<void> submitAnalisa() async {
    // Validasi
    if (selectedLaporan.value == null) {
      _showError('Pilih laporan terlebih dahulu');
      return;
    }
    if (diagnosaMasalahCtrl.text.trim().isEmpty) {
      _showError('Isi diagnosa masalah');
      return;
    }
    if (komponenRusakCtrl.text.trim().isEmpty) {
      _showError('Isi komponen yang rusak');
      return;
    }
    if (tindakanCtrl.text.trim().isEmpty) {
      _showError('Isi tindakan yang direkomendasikan');
      return;
    }

    isSubmitting.value = true;

    try {
      await Future.delayed(const Duration(milliseconds: 800));

      final newAnalisa = AnalisaKerusakanModel(
        id: 'analisa-${DateTime.now().millisecondsSinceEpoch}',
        laporanId: selectedLaporan.value!.id,
        teknisiId: teknisiId,
        teknisiName: teknisiName,
        judulLaporan: selectedLaporan.value!.judul,
        lokasiLaporan: selectedLaporan.value!.lokasi,
        kategoriLaporan: selectedLaporan.value!.kategori,
        diagnosaMasalah: diagnosaMasalahCtrl.text.trim(),
        komponenRusak: komponenRusakCtrl.text.trim(),
        kategoriKerusakan: kategoriKerusakan.value,
        tingkatKerusakan: tingkatKerusakan.value,
        tindakanDirekomendasikan: tindakanCtrl.text.trim(),
        catatanTambahan: catatanCtrl.text.trim().isEmpty
            ? null
            : catatanCtrl.text.trim(),
        estimasiWaktuPerbaikanHari:
            int.tryParse(estimasiHariCtrl.text),
        estimasiBiaya: double.tryParse(
            estimasiBiayaCtrl.text.replaceAll('.', '').replaceAll(',', '.')),
        syncStatus: 'local',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: simpan ke MongoDB via service
      analisaList.insert(0, newAnalisa);

      Get.back(); // kembali ke list
      Get.snackbar(
        'Berhasil',
        'Analisa kerusakan berhasil disimpan',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      );
      resetForm();
    } catch (e) {
      _showError('Gagal menyimpan: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  void _showError(String msg) {
    Get.snackbar(
      'Perhatian',
      msg,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade900,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String formatRupiah(double? val) {
    if (val == null) return '-';
    final s = val.toStringAsFixed(0);
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }
}