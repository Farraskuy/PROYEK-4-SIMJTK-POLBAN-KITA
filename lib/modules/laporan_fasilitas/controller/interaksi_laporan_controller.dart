// lib/modules/laporan_fasilitas/controller/interaksi_laporan_controller.dart

import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import '../model/laporan_fasilitas_model.dart';
import '../service/laporan_fasilitas_service.dart';

enum LaporanSortMode { populer, terbaru }

class InteraksiLaporanController extends GetxController {
  InteraksiLaporanController({this.role = 'mahasiswa'});

  final String role;
  final LaporanFasilitasService _service = LaporanFasilitasService();

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
      _applySort();
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshData() => fetchLaporan();

  void onNotificationTapped() {
    unreadNotifCount.value = 0;
  }

  void setSortMode(LaporanSortMode mode) {
    if (sortMode.value == mode) return;
    sortMode.value = mode;
    _applySort();
  }

  void _applySort() {
    switch (sortMode.value) {
      case LaporanSortMode.populer:
        listLaporan.sort((a, b) => b.vote_score.compareTo(a.vote_score));
        break;
      case LaporanSortMode.terbaru:
        listLaporan.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    listLaporan.refresh();
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
