// lib/modules/teknisi/analisa_kerusakan/controller/analisa_kerusakan_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_service.dart';

import '../model/analisa_kerusakan_model.dart';
// TODO: Pastikan Anda membuat service ini
import '../service/analisa_kerusakan_service.dart';

class AnalisaKerusakanController extends GetxController {
  // ─── SERVICES ──────────────────────────────────────────────
  final AnalisaKerusakanService _analisaService = AnalisaKerusakanService();
  final LaporanFasilitasService _laporanService = LaporanFasilitasService();

  // ─── STATE OBSERVABLES ─────────────────────────────────────
  final RxList<AnalisaKerusakanModel> analisaList = <AnalisaKerusakanModel>[].obs;
  // Ganti LaporanSingkat dengan LaporanFasilitasModel dari DB
  final RxList<LaporanFasilitasModel> laporanAktif = <LaporanFasilitasModel>[].obs;
  
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString filterKategori = 'semua'.obs;

  // Form state
  final Rx<LaporanFasilitasModel?> selectedLaporan = Rx<LaporanFasilitasModel?>(null);

  final Rx<DasarPemeriksaan> dasarPemeriksaan = DasarPemeriksaan.keluhanPemakai.obs;
  final RxString namaAlat = ''.obs;
  final RxString kodeAlat = ''.obs;
  final RxString noInventaris = ''.obs;
  final RxString noKerusakan = ''.obs;

  final RxString analisaMasalah = ''.obs;
  final RxString rekomendasiPerbaikan = ''.obs;
  final RxString rekomendasiTempatPerbaikan = ''.obs;

  final Rx<KategoriKerusakan> kategoriKerusakan = KategoriKerusakan.hardware.obs;
  final Rx<TingkatKerusakan> tingkatKerusakan = TingkatKerusakan.sedang.obs;
  final RxInt estimasiHari = 0.obs;
  final RxDouble estimasiBiaya = 0.0.obs;

  final RxBool isSubmitting = false.obs;

  // Session Teknisi
  final RxString currentTeknisiId = '-'.obs;
  final RxString currentTeknisiName = 'Teknisi'.obs;

  // ─── TEXT CONTROLLERS ──────────────────────────────────────
  late final TextEditingController namaAlatCtrl;
  late final TextEditingController kodeAlatCtrl;
  late final TextEditingController noInventarisCtrl;
  late final TextEditingController noKerusakanCtrl;
  late final TextEditingController analisaMasalahCtrl;
  late final TextEditingController rekomendasiPerbaikanCtrl;
  late final TextEditingController rekomendasiTempatCtrl;
  late final TextEditingController estimasiHariCtrl;
  late final TextEditingController estimasiBiayaCtrl;

  @override
  void onInit() {
    super.onInit();
    _initControllers();
    loadData();
  }

  void _initControllers() {
    namaAlatCtrl = TextEditingController();
    kodeAlatCtrl = TextEditingController();
    noInventarisCtrl = TextEditingController();
    noKerusakanCtrl = TextEditingController();
    analisaMasalahCtrl = TextEditingController();
    rekomendasiPerbaikanCtrl = TextEditingController();
    rekomendasiTempatCtrl = TextEditingController();
    estimasiHariCtrl = TextEditingController();
    estimasiBiayaCtrl = TextEditingController();
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

  // ─── LOAD DATA (CONCURRENT FETCHING) ───────────────────────
  Future<void> loadData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1. Ambil sesi autentikasi secara dinamis
      final session = await AuthService().loadSavedSession();
      currentTeknisiId.value = session?.id ?? session?.nomorInduk ?? '-';
      currentTeknisiName.value = session?.name ?? 'Teknisi';

      if (currentTeknisiId.value == '-') {
        throw Exception('Sesi pengguna tidak valid atau belum login.');
      }

      // 2. Load data secara bersamaan (Concurrent) untuk efisiensi waktu
      final results = await Future.wait([
        _laporanService.getAll(), // Ambil laporan (sesuaikan jika ada getByTeknisi)
        _analisaService.getAll(), // Ambil riwayat analisa
      ]);

      final List<LaporanFasilitasModel> allLaporan = results[0] as List<LaporanFasilitasModel>;
      final List<AnalisaKerusakanModel> allAnalisa = results[1] as List<AnalisaKerusakanModel>;

      // Filter laporan yang dikerjakan teknisi ini dan belum berstatus resolved
      final laporanUntukTeknisi = allLaporan.where((l) => 
        l.teknisi_id == currentTeknisiId.value && 
        l.status != StatusLaporan.resolved
      ).toList();

      laporanAktif.assignAll(laporanUntukTeknisi);
      analisaList.assignAll(allAnalisa.where((a) => a.teknisiId == currentTeknisiId.value));

    } catch (e) {
      errorMessage.value = 'Gagal memuat data dari database: $e';
      Get.snackbar('Kesalahan Koneksi', errorMessage.value, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // ─── GETTERS & FILTERS ─────────────────────────────────────
  List<AnalisaKerusakanModel> get filteredAnalisa {
    if (filterKategori.value == 'semua') return analisaList;
    return analisaList
        .where((a) => a.kategoriKerusakan.value == filterKategori.value)
        .toList();
  }

  List<LaporanFasilitasModel> get laporanBelumDianalisa {
    final sudahDianalisa = analisaList.map((a) => a.laporanId).toSet();
    return laporanAktif.where((l) => !sudahDianalisa.contains(l.id)).toList();
  }

  bool laporanSudahDianalisa(String laporanId) =>
      analisaList.any((a) => a.laporanId == laporanId);

  String get lokasiDariLaporan => selectedLaporan.value?.lokasi ?? '';

  // ─── FORM METHODS ──────────────────────────────────────────
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

  void setLaporan(LaporanFasilitasModel laporan) {
    selectedLaporan.value = laporan;
  }

  void setDasarPemeriksaan(DasarPemeriksaan d) => dasarPemeriksaan.value = d;
  void setKategoriKerusakan(KategoriKerusakan k) => kategoriKerusakan.value = k;
  void setTingkatKerusakan(TingkatKerusakan t) => tingkatKerusakan.value = t;

  // ─── SUBMIT KE DATABASE ────────────────────────────────────
  Future<bool> submitAnalisa() async {
    if (selectedLaporan.value == null) return _failValidation('Pilih laporan terlebih dahulu');
    if (namaAlatCtrl.text.trim().isEmpty) return _failValidation('Isi nama alat');
    if (kodeAlatCtrl.text.trim().isEmpty) return _failValidation('Isi kode alat');
    if (noInventarisCtrl.text.trim().isEmpty) return _failValidation('Isi nomor inventaris');
    if (noKerusakanCtrl.text.trim().isEmpty) return _failValidation('Isi nomor kerusakan');
    if (analisaMasalahCtrl.text.trim().isEmpty) return _failValidation('Isi analisa masalah');
    if (rekomendasiPerbaikanCtrl.text.trim().isEmpty) return _failValidation('Isi rekomendasi perbaikan');
    if (rekomendasiTempatCtrl.text.trim().isEmpty) return _failValidation('Isi rekomendasi tempat perbaikan');

    isSubmitting.value = true;

    try {
      // Parsing angka yang aman dari format Rupiah
      final estimasiBiayaParsed = double.tryParse(
        estimasiBiayaCtrl.text.replaceAll(RegExp(r'[^0-9]'), '')
      ) ?? 0.0;

      final newAnalisa = AnalisaKerusakanModel(
        id: '', // Kosongkan, biarkan MongoDB yang men-generate _id
        laporanId: selectedLaporan.value!.id,
        teknisiId: currentTeknisiId.value,
        teknisiName: currentTeknisiName.value,
        judulLaporan: selectedLaporan.value!.judul,
        kategoriLaporan: selectedLaporan.value!.status.value,
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
        estimasiWaktuPerbaikanHari: int.tryParse(estimasiHariCtrl.text) ?? 0,
        estimasiBiaya: estimasiBiayaParsed,
        syncStatus: 'synced', // Berubah dari local karena sudah live
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // 3. Simpan via Service ke MongoDB
      await _analisaService.create(newAnalisa);
      
      // Refresh data lokal agar tersinkronisasi murni dengan DB
      await loadData();

      Get.snackbar(
        'Berhasil',
        'Formulir analisa kerusakan berhasil disimpan ke server',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        snackPosition: SnackPosition.BOTTOM,
        margin: const EdgeInsets.all(16),
      );
      
      resetForm();
      return true;
    } catch (e) {
      Get.snackbar('Gagal', 'Kesalahan sistem: $e', snackPosition: SnackPosition.BOTTOM);
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  bool _failValidation(String msg) {
    Get.snackbar(
      'Validasi Gagal',
      msg,
      backgroundColor: Colors.orange.shade100,
      colorText: Colors.orange.shade900,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
    return false;
  }

  // ─── HELPERS ───────────────────────────────────────────────
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