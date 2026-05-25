// ============================================================
// FILE: modules/home/teknisi/controller/home_teknisi_controller.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// Sesuai UC-07: Mengelola Tindakan Teknisi
// MODIFIKASI: Tugas Mendesak dari DB laporan_fasilitas, sort by vote_score
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/home_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_service.dart';

enum HomeTeknisiNavTarget { tugas, riwayat }

class HomeTeknisiController extends GetxController {
  // --------------------------------------------------------
  // STATE OBSERVABLES
  // --------------------------------------------------------

  /// Data teknisi yang sedang login
  final Rx<TeknisiUserModel> currentTeknisi = TeknisiUserModel.dummy().obs;

  /// Statistik tugas hari ini
  final Rx<StatistikTugasModel?> statistik = Rx<StatistikTugasModel?>(null);

  /// Tugas mendesak — laporan fasilitas pending/in_progress,
  /// diurutkan berdasarkan vote_score tertinggi (Top Upvote)
  final RxList<LaporanFasilitasModel> tugasMendesak =
      <LaporanFasilitasModel>[].obs;

  /// Index bottom nav aktif
  final RxInt selectedNavIndex = 0.obs;

  /// Status loading
  final RxBool isLoading = false.obs;

  /// Status koneksi internet (offline-first sesuai PDF)
  final RxBool isOnline = true.obs;

  /// Jumlah notifikasi belum dibaca
  final RxInt unreadNotif = 2.obs;

  // --------------------------------------------------------
  // SERVICES
  // --------------------------------------------------------
  final LaporanFasilitasService _laporanService = LaporanFasilitasService();

  // --------------------------------------------------------
  // LIFECYCLE
  // --------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  // --------------------------------------------------------
  // PRIVATE METHODS
  // --------------------------------------------------------

  Future<void> _loadData() async {
    isLoading.value = true;

    try {
      // Ambil semua laporan dengan role teknisi
      // (status: pending | in_progress | escalated_to_upt)
      final allLaporan = await _laporanService.getForRole('teknisi');

      // Urutkan berdasarkan vote_score tertinggi (Top Upvote) untuk Tugas Mendesak
      final sorted = List<LaporanFasilitasModel>.from(allLaporan)
        ..sort((a, b) => b.vote_score.compareTo(a.vote_score));

      tugasMendesak.assignAll(sorted);

      // Hitung statistik dari data real
      final selesai = allLaporan
          .where((l) => l.status == StatusLaporan.resolved)
          .length;
      final pending = allLaporan
          .where((l) =>
              l.status == StatusLaporan.pending ||
              l.status == StatusLaporan.in_progress)
          .length;

      statistik.value = StatistikTugasModel(
        totalTugas: allLaporan.length,
        tugasSelesai: selesai,
        tugasPending: pending,
        tugasInProgress: allLaporan
            .where((l) => l.status == StatusLaporan.in_progress)
            .length,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal Memuat Data',
        'Terjadi kesalahan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // --------------------------------------------------------
  // PUBLIC METHODS
  // --------------------------------------------------------

  /// Pull-to-refresh
  Future<void> onRefresh() async => await _loadData();

  /// Bottom nav tap
  HomeTeknisiNavTarget? onNavTapped(int index) {
    selectedNavIndex.value = index;
    switch (index) {
      case 1:
        return HomeTeknisiNavTarget.tugas;
      case 2:
        return HomeTeknisiNavTarget.riwayat;
      default:
        return null;
    }
  }

  /// Notifikasi bell
  void onNotifikasiTapped() {
    unreadNotif.value = 0;
  }

  /// Tap pada kartu tugas mendesak.
  void onTugasTapped(LaporanFasilitasModel laporan) {
    Get.snackbar(
      laporan.judul,
      '${laporan.lokasi} • ${laporan.vote_score} upvote',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  /// Tap hamburger menu (drawer)
  void onMenuTapped() {
    // TODO: buka drawer
  }

  // ---- GETTERS ----

  /// Sapaan berdasarkan jam
  String get sapaan {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Semangat bertugas demi layanan yang terbaik';
    if (hour < 15) return 'Tetap semangat menyelesaikan tugas hari ini';
    if (hour < 18) return 'Sore yang produktif untuk JTK yang lebih baik';
    return 'Terima kasih atas dedikasi Anda hari ini';
  }
}