// lib/modules/teknisi/analisa_kerusakan/controller/analisa_kerusakan_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/analisa_kerusakan_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/app_navigator.dart';

class AnalisaKerusakanController extends GetxController {
  // â”€â”€ State â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final RxList<AnalisaKerusakanModel> analisaList =
      <AnalisaKerusakanModel>[].obs;
  final RxList<LaporanSingkat> laporanAktif = <LaporanSingkat>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString filterKategori = 'semua'.obs;

  // â”€â”€ Form state (sesuai Formulir POLBAN) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final Rx<LaporanSingkat?> selectedLaporan = Rx<LaporanSingkat?>(null);

  // Identitas alat
  final Rx<DasarPemeriksaan> dasarPemeriksaan =
      DasarPemeriksaan.keluhanPemakai.obs;
  final RxString namaAlat = ''.obs;
  final RxString kodeAlat = ''.obs;
  final RxString noInventaris = ''.obs;
  // lokasi otomatis dari laporan
  final RxString noKerusakan = ''.obs;

  // Isi formulir
  final RxString analisaMasalah = ''.obs;
  final RxString rekomendasiPerbaikan = ''.obs;
  final RxString rekomendasiTempatPerbaikan = ''.obs;

  // Metadata tambahan
  final Rx<KategoriKerusakan> kategoriKerusakan =
      KategoriKerusakan.hardware.obs;
  final Rx<TingkatKerusakan> tingkatKerusakan = TingkatKerusakan.sedang.obs;
  final RxInt estimasiHari = 0.obs;
  final RxDouble estimasiBiaya = 0.0.obs;

  final RxBool isSubmitting = false.obs;

  // â”€â”€ TextEditingControllers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  late final TextEditingController namaAlatCtrl;
  late final TextEditingController kodeAlatCtrl;
  late final TextEditingController noInventarisCtrl;
  late final TextEditingController noKerusakanCtrl;
  late final TextEditingController analisaMasalahCtrl;
  late final TextEditingController rekomendasiPerbaikanCtrl;
  late final TextEditingController rekomendasiTempatCtrl;
  late final TextEditingController estimasiHariCtrl;
  late final TextEditingController estimasiBiayaCtrl;

  // Info teknisi yang login
  final String teknisiId = 'user-tks001';
  final String teknisiName = 'Teknisi';

  @override
  void onInit() {
    super.onInit();
    namaAlatCtrl = TextEditingController();
    kodeAlatCtrl = TextEditingController();
    noInventarisCtrl = TextEditingController();
    noKerusakanCtrl = TextEditingController();
    analisaMasalahCtrl = TextEditingController();
    rekomendasiPerbaikanCtrl = TextEditingController();
    rekomendasiTempatCtrl = TextEditingController();
    estimasiHariCtrl = TextEditingController();
    estimasiBiayaCtrl = TextEditingController();
    loadData();
  }

  @override
  void onClose() {
    namaAlatCtrl.dispose();
    kodeAlatCtrl.dispose();
    noInventarisCtrl.dispose();
    noKerusakanCtrl.dispose();
    analisaMasalahCtrl.dispose();
    rekomendasiPerbaikanCtrl.dispose();
    rekomendasiTempatCtrl.dispose();
    estimasiHariCtrl.dispose();
    estimasiBiayaCtrl.dispose();
    super.onClose();
  }

  // â”€â”€ Load â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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

  // â”€â”€ Getters / Filter â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  List<AnalisaKerusakanModel> get filteredAnalisa {
    if (filterKategori.value == 'semua') return analisaList;
    return analisaList
        .where((a) => a.kategoriKerusakan.value == filterKategori.value)
        .toList();
  }

  List<LaporanSingkat> get laporanBelumDianalisa {
    final sudahDianalisa = analisaList.map((a) => a.laporanId).toSet();
    return laporanAktif.where((l) => !sudahDianalisa.contains(l.id)).toList();
  }

  bool laporanSudahDianalisa(String laporanId) =>
      analisaList.any((a) => a.laporanId == laporanId);

  // Lokasi diambil langsung dari laporan yang dipilih
  String get lokasiDariLaporan => selectedLaporan.value?.lokasi ?? '';

  // â”€â”€ Form â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  void resetForm() {
    selectedLaporan.value = null;
    dasarPemeriksaan.value = DasarPemeriksaan.keluhanPemakai;
    namaAlatCtrl.clear();
    kodeAlatCtrl.clear();
    noInventarisCtrl.clear();
    noKerusakanCtrl.clear();
    analisaMasalahCtrl.clear();
    rekomendasiPerbaikanCtrl.clear();
    rekomendasiTempatCtrl.clear();
    estimasiHariCtrl.clear();
    estimasiBiayaCtrl.clear();
    kategoriKerusakan.value = KategoriKerusakan.hardware;
    tingkatKerusakan.value = TingkatKerusakan.sedang;
    isSubmitting.value = false;
  }

  void setLaporan(LaporanSingkat laporan) {
    selectedLaporan.value = laporan;
  }

  void setDasarPemeriksaan(DasarPemeriksaan d) {
    dasarPemeriksaan.value = d;
  }

  void setKategoriKerusakan(KategoriKerusakan k) {
    kategoriKerusakan.value = k;
  }

  void setTingkatKerusakan(TingkatKerusakan t) {
    tingkatKerusakan.value = t;
  }

  // â”€â”€ Submit â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> submitAnalisa() async {
    if (selectedLaporan.value == null) {
      _showError('Pilih laporan terlebih dahulu');
      return;
    }
    if (namaAlatCtrl.text.trim().isEmpty) {
      _showError('Isi nama alat');
      return;
    }
    if (kodeAlatCtrl.text.trim().isEmpty) {
      _showError('Isi kode alat');
      return;
    }
    if (noInventarisCtrl.text.trim().isEmpty) {
      _showError('Isi nomor inventaris');
      return;
    }
    if (noKerusakanCtrl.text.trim().isEmpty) {
      _showError('Isi nomor kerusakan');
      return;
    }
    if (analisaMasalahCtrl.text.trim().isEmpty) {
      _showError('Isi analisa masalah');
      return;
    }
    if (rekomendasiPerbaikanCtrl.text.trim().isEmpty) {
      _showError('Isi rekomendasi perbaikan');
      return;
    }
    if (rekomendasiTempatCtrl.text.trim().isEmpty) {
      _showError('Isi rekomendasi tempat perbaikan');
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
        kategoriLaporan: selectedLaporan.value!.kategori,
        dasarPemeriksaan: dasarPemeriksaan.value,
        namaAlat: namaAlatCtrl.text.trim(),
        kodeAlat: kodeAlatCtrl.text.trim(),
        noInventaris: noInventarisCtrl.text.trim(),
        lokasi: selectedLaporan.value!.lokasi,
        noKerusakan: noKerusakanCtrl.text.trim(),
        analisaMasalah: analisaMasalahCtrl.text.trim(),
        rekomendasiPerbaikan: rekomendasiPerbaikanCtrl.text.trim(),
        rekomendasiTempatPerbaikan: rekomendasiTempatCtrl.text.trim(),
        kategoriKerusakan: kategoriKerusakan.value,
        tingkatKerusakan: tingkatKerusakan.value,
        estimasiWaktuPerbaikanHari: int.tryParse(estimasiHariCtrl.text),
        estimasiBiaya: double.tryParse(
          estimasiBiayaCtrl.text.replaceAll('.', '').replaceAll(',', '.'),
        ),
        syncStatus: 'local',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // TODO: simpan ke MongoDB via service
      analisaList.insert(0, newAnalisa);

      AppNavigator.pop();
      Get.snackbar(
        'Berhasil',
        'Formulir analisa kerusakan berhasil disimpan',
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

  // â”€â”€ Helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

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
