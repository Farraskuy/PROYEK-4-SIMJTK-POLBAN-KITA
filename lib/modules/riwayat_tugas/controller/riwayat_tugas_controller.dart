// ============================================================
// FILE: modules/home/teknisi/riwayat/controller/riwayat_tugas_controller.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/riwayat_tugas_model.dart';
// FIX: Pastikan path import mengarah ke file view yang benar

class RiwayatTugasController extends GetxController {
  // --------------------------------------------------------
  // TEXT CONTROLLER
  // --------------------------------------------------------
  final searchController = TextEditingController();

  // --------------------------------------------------------
  // STATE OBSERVABLES
  // --------------------------------------------------------
  final RxList<ItemRiwayatModel> _semuaRiwayat = <ItemRiwayatModel>[].obs;
  final RxList<ItemRiwayatModel> riwayatTampil = <ItemRiwayatModel>[].obs;
  final Rx<FilterRiwayat> activeFilter = FilterRiwayat.semua.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedNavIndex = 2.obs;

  // --------------------------------------------------------
  // GETTERS
  // --------------------------------------------------------
  int get countSemua => _semuaRiwayat.length;
  int get countMingguIni => _semuaRiwayat.where((r) => r.isMingguIni).length;
  int get countBulanIni => _semuaRiwayat.where((r) => r.isBulanIni).length;

  // --------------------------------------------------------
  // LIFECYCLE
  // --------------------------------------------------------
  @override
  void onInit() {
    super.onInit();
    _loadRiwayat();

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
    // Simulasi pengambilan data laporan status 'resolved'
    await Future.delayed(const Duration(milliseconds: 450));

    final sorted = ItemRiwayatModel.dummyList()
      ..sort((a, b) => b.selesaiAt.compareTo(a.selesaiAt));
    _semuaRiwayat.assignAll(sorted);
    _applyFilterAndSearch();

    isLoading.value = false;
  }

  void _applyFilterAndSearch() {
    List<ItemRiwayatModel> filtered;
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
      filtered = filtered
          .where(
            (r) =>
                r.judul.toLowerCase().contains(query) ||
                r.nomorId.toLowerCase().contains(query) ||
                r.lokasi.toLowerCase().contains(query) ||
                r.kategori.toLowerCase().contains(query),
          )
          .toList();
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

  void onItemTapped(ItemRiwayatModel item) {
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

  void onNavTapped(int index) {
    if (selectedNavIndex.value == index) return;
    selectedNavIndex.value = index;

    switch (index) {
      case 0:
        break;
      case 1:
        break;
    }
  }

  bool get isSearchActive => searchQuery.value.isNotEmpty;
}
