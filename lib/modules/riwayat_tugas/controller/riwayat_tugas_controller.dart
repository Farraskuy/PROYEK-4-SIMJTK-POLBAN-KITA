// ============================================================
// FILE: modules/home/teknisi/riwayat/controller/riwayat_tugas_controller.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// MODIFIKASI:
//   - Data dari DB laporan_fasilitas berdasarkan teknisi_id yang login
//   - Filter: status == resolved
//   - Tampilkan ID petugas yang menanggapi
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';

// ============================================================
// ENUM FILTER
// ============================================================
enum FilterRiwayat { semua, mingguIni, bulanIni }

extension FilterRiwayatLabel on FilterRiwayat {
  String get label {
    switch (this) {
      case FilterRiwayat.semua:
        return 'Semua';
      case FilterRiwayat.mingguIni:
        return 'Minggu Ini';
      case FilterRiwayat.bulanIni:
        return 'Bulan Ini';
    }
  }
}

// ============================================================
// MODEL RIWAYAT WRAPPER (dari LaporanFasilitasModel)
// ============================================================
class RiwayatLaporanModel {
  final LaporanFasilitasModel laporan;

  const RiwayatLaporanModel(this.laporan);

  bool get isMingguIni {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    return laporan.updatedAt.isAfter(weekAgo);
  }

  bool get isBulanIni {
    final now = DateTime.now();
    return laporan.updatedAt.month == now.month &&
        laporan.updatedAt.year == now.year;
  }

  String get tanggalLabel {
    final d = laporan.updatedAt;
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
    ];
    return '${d.day} ${bulan[d.month]} ${d.year}';
  }
}

// ============================================================
// CONTROLLER
// ============================================================
class RiwayatTugasController extends GetxController {
  // --------------------------------------------------------
  // TEXT CONTROLLER
  // --------------------------------------------------------
  final searchController = TextEditingController();

  // --------------------------------------------------------
  // STATE OBSERVABLES
  // --------------------------------------------------------
  final RxList<RiwayatLaporanModel> _semuaRiwayat =
      <RiwayatLaporanModel>[].obs;
  final RxList<RiwayatLaporanModel> riwayatTampil =
      <RiwayatLaporanModel>[].obs;
  final Rx<FilterRiwayat> activeFilter = FilterRiwayat.semua.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedNavIndex = 2.obs;

  // ID teknisi yang sedang login
  final RxString _currentTeknisiId = '-'.obs;
  String get currentTeknisiId => _currentTeknisiId.value ?? '-';

  // --------------------------------------------------------
  // SERVICES
  // --------------------------------------------------------
  final LaporanFasilitasService _service = LaporanFasilitasService();

  // --------------------------------------------------------
  // GETTERS
  // --------------------------------------------------------
  int get countSemua => _semuaRiwayat.length;
  int get countMingguIni =>
      _semuaRiwayat.where((r) => r.isMingguIni).length;
  int get countBulanIni =>
      _semuaRiwayat.where((r) => r.isBulanIni).length;

  // --------------------------------------------------------
  // LIFECYCLE
  // --------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    _initAndLoad();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _applyFilterAndSearch();
    });
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  // --------------------------------------------------------
  // PRIVATE METHODS
  // --------------------------------------------------------
  Future<void> _initAndLoad() async {
    // Ambil session user yang login
    final session = await AuthService().loadSavedSession();
    _currentTeknisiId.value = session?.id ?? session?.nomorInduk ?? '-';
    await _loadRiwayat();
  }

  Future<void> _loadRiwayat() async {
    isLoading.value = true;
    try {
      final allLaporan = await _service.getAll();

      // Filter: hanya laporan yang
      //   1. teknisi_id == currentTeknisiId (dikerjakan oleh teknisi ini)
      //   2. status == resolved (selesai)
      final riwayat = allLaporan
          .where((l) =>
              l.teknisi_id == _currentTeknisiId.value &&
              l.status == StatusLaporan.resolved)
          .map((l) => RiwayatLaporanModel(l))
          .toList()
        ..sort((a, b) =>
            b.laporan.updatedAt.compareTo(a.laporan.updatedAt));

      _semuaRiwayat.assignAll(riwayat);
      _applyFilterAndSearch();
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Tidak dapat memuat riwayat: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _applyFilterAndSearch() {
    List<RiwayatLaporanModel> filtered;
    switch (activeFilter.value) {
      case FilterRiwayat.mingguIni:
        filtered = _semuaRiwayat.where((r) => r.isMingguIni).toList();
        break;
      case FilterRiwayat.bulanIni:
        filtered = _semuaRiwayat.where((r) => r.isBulanIni).toList();
        break;
      case FilterRiwayat.semua:
        filtered = List.from(_semuaRiwayat);
        break;
    }

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((r) {
        final l = r.laporan;
        return l.judul.toLowerCase().contains(query) ||
            l.lokasi.toLowerCase().contains(query) ||
            l.id.toLowerCase().contains(query);
      }).toList();
    }
    riwayatTampil.assignAll(filtered);
  }

  // --------------------------------------------------------
  // PUBLIC METHODS
  // --------------------------------------------------------
  void onFilterChanged(FilterRiwayat filter) {
    if (activeFilter.value == filter) return;
    activeFilter.value = filter;
    _applyFilterAndSearch();
  }

  void onClearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilterAndSearch();
  }

  Future<void> onRefresh() async => await _loadRiwayat();

  void onItemTapped(RiwayatLaporanModel item) {
    Get.snackbar(
      item.laporan.id,
      item.laporan.judul,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFFE8F5E9),
      colorText: const Color(0xFF2E7D32),
      duration: const Duration(seconds: 2),
    );
  }

  void onNavTapped(int index) {
    if (selectedNavIndex.value == index) return;
    selectedNavIndex.value = index;
  }

  bool get isSearchActive => searchQuery.value.isNotEmpty;
}