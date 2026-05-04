// lib/modules/laporan_fasilitas/controller/interaksi_laporan_controller.dart

import 'package:get/get.dart';
import '../model/laporan_fasilitas_model.dart';
import '../service/laporan_fasilitas_service.dart';

class InteraksiLaporanController extends GetxController {
  final LaporanFasilitasService _service = LaporanFasilitasService();

  var listLaporan = <LaporanFasilitasModel>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLaporan();
  }

  Future<void> fetchLaporan() async {
    isLoading.value = true;
    try {
      var data = await _service.getAll();
      // Sorting default berdasarkan vote terbanyak (keresahan mahasiswa)[cite: 3, 11]
      data.sort((a, b) => b.vote_score.compareTo(a.vote_score));
      listLaporan.assignAll(data);
    } catch (e) {
      Get.snackbar("Error", "Gagal memuat data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Logika Upvote[cite: 3, 11]
  void upvoteLaporan(String userId, int index) async {
    var laporan = listLaporan[index];

    if (laporan.upvoter_ids.contains(userId)) {
      laporan.upvoter_ids.remove(userId);
    } else {
      laporan.upvoter_ids.add(userId);
      laporan.downvoter_ids.remove(
        userId,
      ); // Pastikan tidak ada di list downvote
    }

    _updateVoteAndSync(laporan, index);
  }

  /// Logika Downvote (Baru)[cite: 3, 11]
  void downvoteLaporan(String userId, int index) async {
    var laporan = listLaporan[index];

    if (laporan.downvoter_ids.contains(userId)) {
      laporan.downvoter_ids.remove(userId);
    } else {
      laporan.downvoter_ids.add(userId);
      laporan.upvoter_ids.remove(
        userId,
      ); // Pastikan tidak ada di list upvote[cite: 11]
    }

    _updateVoteAndSync(laporan, index);
  }

  /// Helper untuk hitung skor dan simpan ke MongoDB
  void _updateVoteAndSync(LaporanFasilitasModel laporan, int index) async {
    // Vote score = Total Upvote - Total Downvote[cite: 11]
    laporan.vote_score =
        laporan.upvoter_ids.length - laporan.downvoter_ids.length;
    laporan.updatedAt = DateTime.now();

    listLaporan[index] = laporan;
    listLaporan.refresh();

    await _service.update(laporan); // Simpan ke database
  }

  /// Logika Delete Laporan[cite: 3, 7]
  Future<void> deleteLaporan(String laporanId) async {
    try {
      await _service.delete(laporanId);
      listLaporan.removeWhere((l) => l.id == laporanId);
      Get.snackbar(
        "Sukses",
        "Laporan berhasil dihapus",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar("Gagal", "Gagal menghapus laporan: $e");
    }
  }

  void sortLaporan(String criteria) {
    if (criteria == 'terbaru') {
      listLaporan.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else {
      listLaporan.sort((a, b) => b.vote_score.compareTo(a.vote_score));
    }
    listLaporan.refresh();
  }
}
