// ============================================================
// FILE: modules/home/teknisi/controller/home_teknisi_controller.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// Sesuai UC-07: Mengelola Tindakan Teknisi
// ============================================================
//
// Dependency: get: ^4.6.6
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/home_model.dart';
import '../../../tugas_teknisi/view/tugas_teknisi_view.dart';

class HomeTeknisiController extends GetxController {
  // --------------------------------------------------------
  // STATE OBSERVABLES
  // --------------------------------------------------------

  /// Data teknisi yang sedang login
  final Rx<TeknisiUserModel> currentTeknisi = TeknisiUserModel.dummy().obs;

  /// Statistik tugas hari ini
  final Rx<StatistikTugasModel?> statistik = Rx<StatistikTugasModel?>(null);

  /// Semua tugas yang didelegasikan ke teknisi ini
  final RxList<TugasTeknisiModel> semuaTugas = <TugasTeknisiModel>[].obs;

  /// Hanya tugas mendesak (high priority, belum selesai)
  final RxList<TugasTeknisiModel> tugasMendesak = <TugasTeknisiModel>[].obs;

  /// Index bottom nav aktif
  final RxInt selectedNavIndex = 0.obs;

  /// Status loading
  final RxBool isLoading = false.obs;

  /// Status koneksi internet (offline-first sesuai PDF)
  final RxBool isOnline = true.obs;

  /// Jumlah notifikasi belum dibaca
  final RxInt unreadNotif = 2.obs;

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

    // Simulasi fetch data dari server / local cache (offline-first)
    // TODO: ganti dengan service call nyata
    await Future.delayed(const Duration(milliseconds: 500));

    statistik.value = StatistikTugasModel.dummy();

    final allTugas = TugasTeknisiModel.dummyList();
    semuaTugas.assignAll(allTugas);

    // Filter tugas mendesak: high priority & belum selesai
    // Sesuai hak akses Teknisi — menerima delegasi dari Admin (UC-06)
    tugasMendesak.assignAll(
      allTugas.where((t) => t.isMendesak).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
    );

    isLoading.value = false;
  }

  // --------------------------------------------------------
  // PUBLIC METHODS
  // --------------------------------------------------------

  /// Pull-to-refresh
  Future<void> onRefresh() async => await _loadData();

  /// Bottom nav tap
  void onNavTapped(int index) {
    selectedNavIndex.value = index;
    // TODO: navigasi ke halaman lain
    switch (index) {
      case 1: Get.to(() => const DaftarTugasView()); break;
    }
  }

  /// Notifikasi bell
  void onNotifikasiTapped() {
    unreadNotif.value = 0;
  }

  /// Tap pada kartu tugas mendesak → buka detail laporan
  /// Sesuai UC-07: Teknisi memperbarui status & tambah estimasi
  void onTugasTapped(TugasTeknisiModel tugas) {
    // TODO: Get.to(() => DetailLaporanFasilitasView(id: tugas.id))
    Get.snackbar(
      'Detail Tugas',
      tugas.judul,
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFFE3F2FD),
      colorText: const Color(0xFF1565C0),
      duration: const Duration(seconds: 2),
    );
  }

  /// Mulai kerjakan tugas — ubah status ke in_progress (UC-07)
  Future<void> onMulaiKerjakan(TugasTeknisiModel tugas) async {
    final idx = semuaTugas.indexWhere((t) => t.id == tugas.id);
    if (idx == -1) return;

    // Simulasi update — di implementasi nyata panggil service
    await Future.delayed(const Duration(milliseconds: 300));

    // Update di list mendesak
    final idxMendesak = tugasMendesak.indexWhere((t) => t.id == tugas.id);
    if (idxMendesak != -1) {
      final updated = TugasTeknisiModel(
        id: tugas.id,
        judul: tugas.judul,
        lokasi: tugas.lokasi,
        kategori: tugas.kategori,
        prioritas: tugas.prioritas,
        status: StatusTugas.inProgress,
        estimasiSelesai: tugas.estimasiSelesai,
        isSynced: isOnline.value,
        createdAt: tugas.createdAt,
      );
      tugasMendesak[idxMendesak] = updated;
    }

    Get.snackbar(
      'Status Diperbarui',
      '"${tugas.judul}" sedang dikerjakan.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      margin: const EdgeInsets.all(16),
    );
  }

  /// Selesaikan tugas — ubah status ke resolved + wajib foto bukti (UC-07)
  void onSelesaikanTugas(TugasTeknisiModel tugas) {
    // TODO: navigasi ke form selesaikan tugas dengan upload foto bukti
    // Get.to(() => SelesaikanTugasView(tugas: tugas))
    Get.snackbar(
      'Selesaikan Tugas',
      'Upload foto bukti untuk menyelesaikan "${tugas.judul}"',
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

  /// Jumlah tugas yang belum dikerjakan
  int get jumlahTugasBelumDikerjakan =>
      semuaTugas
          .where((t) =>
              t.status == StatusTugas.assigned ||
              t.status == StatusTugas.inProgress)
          .length;
}