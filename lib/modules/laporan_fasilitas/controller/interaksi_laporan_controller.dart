// lib/modules/laporan_fasilitas/controller/interaksi_laporan_controller.dart

import 'package:flutter/material.dart'; // Tambahkan untuk akses Color
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import '../model/laporan_fasilitas_model.dart';
import '../service/laporan_fasilitas_service.dart';
import '../service/detail_laporan_fasilitas_service.dart'; // Pastikan path ini benar

class InteraksiLaporanController extends GetxController {
  InteraksiLaporanController({this.role = 'mahasiswa'});

  final String role;
  final LaporanFasilitasService _service = LaporanFasilitasService();
  final DetailLaporanFasilitasService _detailService = DetailLaporanFasilitasService();

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
      listLaporan.assignAll(data);
      
      // Auto-sort untuk teknisi: default Top Upvote
      if (isPetugas) {
        sortLaporan(byUpvote: true);
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Sort list laporan:
  /// - byUpvote = true  → urut vote_score tertinggi
  /// - byUpvote = false → urut createdAt terbaru
  void sortLaporan({required bool byUpvote}) {
    if (byUpvote) {
      listLaporan.sort((a, b) => b.vote_score.compareTo(a.vote_score));
    } else {
      listLaporan.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    listLaporan.refresh();
  }

  /// Teknisi mengambil laporan: update teknisi_id + status = in_progress di DB
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

    if (laporan.upvoter_ids.contains(userId)) {
      laporan.upvoter_ids.remove(userId);
    } else {
      laporan.upvoter_ids.add(userId);
      laporan.downvoter_ids.remove(userId);
    }

    _updateVoteAndSync(laporan, index);
  }

  void downvoteLaporan(String userId, int index) async {
    final laporan = listLaporan[index];

    if (laporan.downvoter_ids.contains(userId)) {
      laporan.downvoter_ids.remove(userId);
    } else {
      laporan.downvoter_ids.add(userId);
      laporan.upvoter_ids.remove(userId);
    }

    _updateVoteAndSync(laporan, index);
  }

  void _updateVoteAndSync(LaporanFasilitasModel laporan, int index) async {
    laporan.vote_score =
        laporan.upvoter_ids.length - laporan.downvoter_ids.length;
    laporan.updatedAt = DateTime.now();

    listLaporan[index] = laporan;
    _applySort();

    await _service.update(laporan);
  }

  Future<void> deleteLaporan(String laporanId) async {
    try {
      await _service.delete(laporanId);
      listLaporan.removeWhere((l) => l.id == laporanId);
      _applySort();
      Get.snackbar('Sukses', 'Laporan berhasil dihapus');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menghapus laporan: $e');
    }
  }

  Future<void> refreshAfterAction() async => fetchLaporan();
}