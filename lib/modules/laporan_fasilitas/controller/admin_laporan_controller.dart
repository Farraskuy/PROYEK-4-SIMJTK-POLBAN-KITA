import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/laporan_fasilitas_model.dart';
import '../service/laporan_fasilitas_service.dart';

enum AdminLaporanFilter { semua, aktif, selesai }

extension AdminLaporanFilterLabel on AdminLaporanFilter {
  String get label => switch (this) {
        AdminLaporanFilter.semua => 'Semua',
        AdminLaporanFilter.aktif => 'Aktif',
        AdminLaporanFilter.selesai => 'Selesai',
      };
}

class AdminLaporanController extends GetxController {
  final LaporanFasilitasService _service = LaporanFasilitasService();
  final searchController = TextEditingController();
  final RxList<LaporanFasilitasModel> _all = <LaporanFasilitasModel>[].obs;
  final RxList<LaporanFasilitasModel> laporanList =
      <LaporanFasilitasModel>[].obs;
  final Rx<AdminLaporanFilter> activeFilter =
      AdminLaporanFilter.semua.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _applyFilter();
    });
    fetchLaporan();
  }

  Future<void> fetchLaporan() async {
    isLoading.value = true;
    try {
      _all.assignAll(await _service.fetchAll());
      _applyFilter();
    } catch (_) {
      Get.snackbar('Gagal', 'Data laporan tidak dapat dimuat.');
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(AdminLaporanFilter filter) {
    activeFilter.value = filter;
    _applyFilter();
  }

  void clearSearch() => searchController.clear();

  void _applyFilter() {
    var result = _all.where((laporan) {
      return switch (activeFilter.value) {
        AdminLaporanFilter.semua => true,
        AdminLaporanFilter.aktif =>
          laporan.status != StatusLaporan.resolved &&
              laporan.status != StatusLaporan.cancelled,
        AdminLaporanFilter.selesai =>
          laporan.status == StatusLaporan.resolved,
      };
    }).toList();

    final query = searchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((laporan) {
        return laporan.judul.toLowerCase().contains(query) ||
            laporan.lokasi.toLowerCase().contains(query) ||
            laporan.id.toLowerCase().contains(query) ||
            laporan.pelapor_nama.toLowerCase().contains(query);
      }).toList();
    }
    result.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    laporanList.assignAll(result);
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
