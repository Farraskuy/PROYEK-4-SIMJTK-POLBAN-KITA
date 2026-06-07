import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/tanggapan_tugas_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';

enum TeknisiLaporanSort { mendesak, terbaru, terlama }

extension TeknisiLaporanSortLabel on TeknisiLaporanSort {
  String get label {
    switch (this) {
      case TeknisiLaporanSort.mendesak:
        return 'Mendesak';
      case TeknisiLaporanSort.terbaru:
        return 'Terbaru';
      case TeknisiLaporanSort.terlama:
        return 'Terlama';
    }
  }

  IconData get icon {
    switch (this) {
      case TeknisiLaporanSort.mendesak:
        return Icons.local_fire_department_outlined;
      case TeknisiLaporanSort.terbaru:
        return Icons.schedule_rounded;
      case TeknisiLaporanSort.terlama:
        return Icons.history_rounded;
    }
  }
}

class TeknisiLaporanFasilitasController extends GetxController {
  final LaporanFasilitasService _service = LaporanFasilitasService();
  final TanggapanTugasService _draftService = TanggapanTugasService();

  final searchController = TextEditingController();
  final RxList<LaporanFasilitasModel> _semuaTugas =
      <LaporanFasilitasModel>[].obs;
  final RxList<LaporanFasilitasModel> tugasTampil =
      <LaporanFasilitasModel>[].obs;
  final Rx<TeknisiLaporanSort> activeSort =
      TeknisiLaporanSort.mendesak.obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;

  UserModel? get user => AuthService().currentUser;

  bool get isSearchActive => searchQuery.value.isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    searchController.addListener(() {
      searchQuery.value = searchController.text;
      _applyFilter();
    });
    fetchTugas();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchTugas() async {
    isLoading.value = true;
    try {
      final tugas = await _service.getForRole('teknisi');
      final drafts = await _draftService.getAllDrafts();
      _semuaTugas.assignAll(
        tugas.where(
          (laporan) => drafts[laporan.id]?['form_status'] != 'selesai',
        ),
      );
      _applyFilter();
    } catch (e) {
      Get.snackbar(
        'Gagal Memuat Tugas',
        'Data tugas petugas tidak dapat dimuat.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void changeSort(TeknisiLaporanSort sort) {
    if (activeSort.value == sort) return;
    activeSort.value = sort;
    _applyFilter();
  }

  void clearSearch() {
    searchController.clear();
  }

  void _applyFilter() {
    final query = searchQuery.value.trim().toLowerCase();
    final filtered = query.isEmpty
        ? List<LaporanFasilitasModel>.from(_semuaTugas)
        : _semuaTugas.where((laporan) {
            return laporan.judul.toLowerCase().contains(query) ||
                laporan.lokasi.toLowerCase().contains(query) ||
                laporan.id.toLowerCase().contains(query);
          }).toList();

    switch (activeSort.value) {
      case TeknisiLaporanSort.mendesak:
        filtered.sort((a, b) {
          final voteComparison = b.vote_score.compareTo(a.vote_score);
          if (voteComparison != 0) return voteComparison;
          return b.createdAt.compareTo(a.createdAt);
        });
        break;
      case TeknisiLaporanSort.terbaru:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TeknisiLaporanSort.terlama:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;
    }

    tugasTampil.assignAll(filtered);
  }
}
