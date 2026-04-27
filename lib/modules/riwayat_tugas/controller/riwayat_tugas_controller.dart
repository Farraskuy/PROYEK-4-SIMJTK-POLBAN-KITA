// ============================================================
// FILE: modules/home/teknisi/riwayat/controller/riwayat_tugas_controller.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/riwayat_tugas_model.dart';
import '../../home/teknisi/view/home_view.dart';
import '../../tugas_teknisi/view/tugas_teknisi_view.dart';

class RiwayatTugasController extends GetxController {
  // --------------------------------------------------------
  // TEXT CONTROLLER
  // --------------------------------------------------------
  final searchController = TextEditingController();

  // --------------------------------------------------------
  // STATE OBSERVABLES
  // --------------------------------------------------------

  /// Semua riwayat (raw)
  final RxList<ItemRiwayatModel> _semuaRiwayat = <ItemRiwayatModel>[].obs;

  /// Riwayat yang ditampilkan (sudah difilter & dicari)
  final RxList<ItemRiwayatModel> riwayatTampil = <ItemRiwayatModel>[].obs;

  /// Filter waktu aktif
  final Rx<FilterRiwayat> activeFilter = FilterRiwayat.semua.obs;

  /// Teks pencarian
  final RxString searchQuery = ''.obs;

  /// Status loading
  final RxBool isLoading = false.obs;

  /// Index bottom nav — 2 = RIWAYAT (aktif)
  final RxInt selectedNavIndex = 2.obs;

  // --------------------------------------------------------
  // GETTERS — jumlah per filter
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
    _loadRiwayat();

    // Reaktif terhadap perubahan teks search
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

  Future<void> _loadRiwayat() async {
    isLoading.value = true;

    // TODO: ganti dengan service call — ambil semua laporan
    // dengan status resolved yang handlerId == currentTeknisiId
    await Future.delayed(const Duration(milliseconds: 450));

    // Sort terbaru dulu
    final sorted = ItemRiwayatModel.dummyList()
      ..sort((a, b) => b.selesaiAt.compareTo(a.selesaiAt));
    _semuaRiwayat.assignAll(sorted);
    _applyFilterAndSearch();

    isLoading.value = false;
  }

  void _applyFilterAndSearch() {
    // 1. Filter berdasarkan waktu
    List<ItemRiwayatModel> filtered;
    switch (activeFilter.value) {
      case FilterRiwayat.mingguIni:
        filtered = _semuaRiwayat.where((r) => r.isMingguIni).toList();
        break;
      case FilterRiwayat.bulanIni:
        filtered = _semuaRiwayat.where((r) => r.isBulanIni).toList();
        break;
      case FilterRiwayat.semua:
      default:
        filtered = List.from(_semuaRiwayat);
        break;
    }

    // 2. Filter berdasarkan search query
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((r) =>
              r.judul.toLowerCase().contains(query) ||
              r.nomorId.toLowerCase().contains(query) ||
              r.lokasi.toLowerCase().contains(query) ||
              r.kategori.toLowerCase().contains(query))
          .toList();
    }

    riwayatTampil.assignAll(filtered);
  }

  // --------------------------------------------------------
  // PUBLIC METHODS
  // --------------------------------------------------------

  /// Ganti filter chip
  void onFilterChanged(FilterRiwayat filter) {
    if (activeFilter.value == filter) return;
    activeFilter.value = filter;
    _applyFilterAndSearch();
  }

  /// Hapus teks search
  void onClearSearch() {
    searchController.clear();
    searchQuery.value = '';
    _applyFilterAndSearch();
  }

  /// Pull-to-refresh
  Future<void> onRefresh() async => await _loadRiwayat();

  /// Tap item — buka detail riwayat
  void onItemTapped(ItemRiwayatModel item) {
    // TODO: Get.to(() => DetailRiwayatView(id: item.id))
    Get.snackbar(
      item.nomorId,
      item.judul,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFFE8F5E9),
      colorText: const Color(0xFF2E7D32),
      duration: const Duration(seconds: 2),
    );
  }

  /// Bottom nav tap
  void onNavTapped(int index) {
    selectedNavIndex.value = index;
    switch (index) {
      case 0: // BERANDA
        Get.to(() => const HomeTeknisiView());
        break;
      case 1: // TUGAS
        Get.to(() => const DaftarTugasView());
        break;
    }
  }

  /// Apakah search bar sedang aktif (ada teks)
  bool get isSearchActive => searchQuery.value.isNotEmpty;
}