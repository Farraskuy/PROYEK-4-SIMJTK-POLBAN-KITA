// lib/modules/laporan_fasilitas/controller/interaksi_laporan_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import '../model/laporan_fasilitas_model.dart';
import '../service/laporan_fasilitas_service.dart';
import '../service/detail_laporan_fasilitas_service.dart';

enum LaporanSortMode { populer, terbaru, selesai }

class InteraksiLaporanController extends GetxController {
  InteraksiLaporanController({this.role = 'mahasiswa'});

  final String role;
  final LaporanFasilitasService _service = LaporanFasilitasService();
  final DetailLaporanFasilitasService _detailService = DetailLaporanFasilitasService();

  final _allLaporan = <LaporanFasilitasModel>[].obs;
  final listLaporan = <LaporanFasilitasModel>[].obs;
  final isLoading = false.obs;
  final unreadNotifCount = 3.obs;
  final sortMode = LaporanSortMode.populer.obs;

  String get currentUserId {
    final user = AuthService().currentUser;
    if (user == null) return 'anonymous';
    return user.id.isNotEmpty ? user.id : user.nomorInduk;
  }

  String get currentUserName => AuthService().currentUser?.name ?? 'Mahasiswa';

  bool get isMahasiswa => role == 'mahasiswa';
  bool get isPetugas => role == 'teknisi' || role == 'petugas';
  bool get isTu => role == 'tu';

  @override
  void onInit() {
    super.onInit();
    fetchLaporan();
  }

  Future<void> fetchLaporan() async {
    isLoading.value = true;
    try {
      final data = await _service.getForRole(role);
      _allLaporan.assignAll(data);
      _applySort();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void sortLaporan(LaporanSortMode mode) {
    sortMode.value = mode;
    _applySort();
  }

  void _applySort() {
    switch (sortMode.value) {
      case LaporanSortMode.populer:
        final sorted = List<LaporanFasilitasModel>.from(_allLaporan)
          ..sort((a, b) => b.vote_score.compareTo(a.vote_score));
        listLaporan.assignAll(sorted);
        break;
      case LaporanSortMode.terbaru:
        final sorted = List<LaporanFasilitasModel>.from(_allLaporan)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        listLaporan.assignAll(sorted);
        break;
      case LaporanSortMode.selesai:
        final filtered = _allLaporan
            .where((l) => l.status == StatusLaporan.resolved)
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        listLaporan.assignAll(filtered);
        break;
    }
    listLaporan.refresh();
  }

  Future<void> ambilLaporan(LaporanFasilitasModel laporan) async {
    try {
      final session = await AuthService().loadSavedSession();
      final teknisiId = session?.id ?? session?.nomorInduk;

      if (teknisiId == null) {
        Get.snackbar('Error', 'Session tidak ditemukan',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      await _detailService.delegasikanLaporan(laporan.id, teknisiId);

      Get.snackbar(
        'Berhasil',
        '"${laporan.judul}" sedang dikerjakan',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE8F5E9),
        colorText: const Color(0xFF2E7D32),
      );

      await fetchLaporan();
    } catch (e) {
      Get.snackbar('Gagal', 'Tidak dapat mengambil laporan: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void upvoteLaporan(String userId, int index) async {
    final laporan = listLaporan[index];
    final realIndex = _allLaporan.indexWhere((l) => l.id == laporan.id);
    if (realIndex == -1) return;

    if (laporan.upvoter_ids.contains(userId)) {
      laporan.upvoter_ids.remove(userId);
    } else {
      laporan.upvoter_ids.add(userId);
      laporan.downvoter_ids.remove(userId);
    }

    _updateVoteAndSync(laporan, realIndex);
  }

  void downvoteLaporan(String userId, int index) async {
    final laporan = listLaporan[index];
    final realIndex = _allLaporan.indexWhere((l) => l.id == laporan.id);
    if (realIndex == -1) return;

    if (laporan.downvoter_ids.contains(userId)) {
      laporan.downvoter_ids.remove(userId);
    } else {
      laporan.downvoter_ids.add(userId);
      laporan.upvoter_ids.remove(userId);
    }

    _updateVoteAndSync(laporan, realIndex);
  }

  void _updateVoteAndSync(LaporanFasilitasModel laporan, int realIndex) async {
    laporan.vote_score =
        laporan.upvoter_ids.length - laporan.downvoter_ids.length;
    laporan.updatedAt = DateTime.now();

    _allLaporan[realIndex] = laporan;
    _applySort();

    await _service.update(laporan);
  }

  Future<void> deleteLaporan(String laporanId) async {
    try {
      await _service.delete(laporanId);
      _allLaporan.removeWhere((l) => l.id == laporanId);
      _applySort();
      Get.snackbar('Sukses', 'Laporan berhasil dihapus');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menghapus laporan: $e');
    }
  }

  Future<void> refreshAfterAction() async => fetchLaporan();
}