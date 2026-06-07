import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import '../model/laporan_fasilitas_model.dart';
import '../service/laporan_fasilitas_service.dart';

enum AdminLaporanFilter { semua, aktif, selesai }

extension AdminLaporanFilterLabel on AdminLaporanFilter {
  String get label => switch (this) {
        AdminLaporanFilter.semua => 'Semua',
        AdminLaporanFilter.aktif => 'Aktif',
        AdminLaporanFilter.selesai => 'Selesai',
      };

  IconData get icon => switch (this) {
        AdminLaporanFilter.semua => Icons.dashboard_outlined,
        AdminLaporanFilter.aktif => Icons.pending_actions_rounded,
        AdminLaporanFilter.selesai => Icons.check_circle_outline_rounded,
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

  UserModel? get user => AuthService().currentUser;

  bool get isSearchActive => searchQuery.value.isNotEmpty;

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
