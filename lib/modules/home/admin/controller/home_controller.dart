// ============================================================
// FILE: modules/admin/dashboard/controller/admin_dashboard_controller.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// ============================================================
//
// Dependency: get: ^4.6.6
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../model/home_model.dart';
import '../../../laporan_fasilitas/controller/fasilitas_controller.dart';
import '../../../laporan_fasilitas/view/laporan_fasilitas_screen.dart';

class AdminDashboardController extends GetxController {
  // --------------------------------------------------------
  // STATE OBSERVABLES
  // --------------------------------------------------------

  /// Data admin yang sedang login
  final Rx<AdminUserModel> currentAdmin = AdminUserModel.dummy().obs;

  /// Statistik laporan fasilitas (kartu utama)
  final Rx<StatistikLaporanModel?> statistikLaporan =
      Rx<StatistikLaporanModel?>(null);

  /// Statistik ringkasan (kartu kecil)
  final Rx<StatistikRingkasanModel?> statistikRingkasan =
      Rx<StatistikRingkasanModel?>(null);

  /// List aktivitas terbaru
  final RxList<AktivitasTerbaruModel> aktivitasList =
      <AktivitasTerbaruModel>[].obs;

  /// List tindakan cepat
  final RxList<TindakanCepatModel> tindakanCepatList =
      <TindakanCepatModel>[].obs;

  /// Index bottom nav yang aktif
  final RxInt selectedNavIndex = 0.obs;

  /// Status loading awal
  final RxBool isLoading = false.obs;

  /// Jumlah notifikasi belum dibaca
  final RxInt unreadNotif = 5.obs;

  // --------------------------------------------------------
  // LIFECYCLE
  // --------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // --------------------------------------------------------
  // PRIVATE METHODS
  // --------------------------------------------------------

  Future<void> _fetchStatistik() async {
    // TODO: ganti dengan API call ke endpoint /admin/statistik
    await Future.delayed(const Duration(milliseconds: 300));
    statistikLaporan.value = StatistikLaporanModel.dummy();
  }

  Future<void> _fetchRingkasan() async {
    // TODO: ganti dengan API call ke endpoint /admin/ringkasan
    await Future.delayed(const Duration(milliseconds: 200));
    statistikRingkasan.value = StatistikRingkasanModel.dummy();
  }

  Future<void> _fetchAktivitas() async {
    // TODO: ganti dengan API call ke endpoint /admin/aktivitas
    await Future.delayed(const Duration(milliseconds: 400));
    aktivitasList.assignAll(AktivitasTerbaruModel.dummyList());
  }

  // --------------------------------------------------------
  // PUBLIC METHODS
  // --------------------------------------------------------

  /// Load semua data dashboard secara paralel
  Future<void> loadDashboardData() async {
    isLoading.value = true;
    tindakanCepatList.assignAll(TindakanCepatModel.list());

    // Fetch paralel agar lebih cepat
    await Future.wait([
      _fetchStatistik(),
      _fetchRingkasan(),
      _fetchAktivitas(),
    ]);

    isLoading.value = false;
  }

  /// Pull-to-refresh
  Future<void> onRefresh() async => await loadDashboardData();

  /// Bottom nav
  void onNavTapped(int index) {
    selectedNavIndex.value = index;
    switch (index) {
      case 0:
        // Dashboard - stay on dashboard
        break;
      case 1:
        // Fasilitas
        Get.to(
          () => ChangeNotifierProvider(
            create: (_) => AdminFasilitasController(),
            child: const AdminLaporanFasilitasScreen(),
          ),
        );
        break;
      case 2:
        // Aspirasi
        // TODO: Get.to(() => const AdminAspirasiView())
        break;
      case 3:
        // Pengguna
        // TODO: Get.to(() => const AdminUsersView())
        break;
    }
  }

  /// Notifikasi bell
  void onNotifikasiTapped() {
    unreadNotif.value = 0;
    // TODO: Get.to(() => const AdminNotifikasiView())
  }

  // ---- TINDAKAN CEPAT ----

  /// Dipanggil saat admin menekan "Tugaskan"
  /// Sesuai UC-06: Admin mendelegasikan laporan ke Teknisi
  void onTugaskan() {
    Get.snackbar(
      'Delegasi Laporan',
      'Buka daftar laporan pending untuk mendelegasikan ke teknisi.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFFE3F2FD),
      colorText: const Color(0xFF1565C0),
    );
    // TODO: Get.to(() => const AdminFasilitasPendingView())
  }

  /// Dipanggil saat admin menekan "Siarkan"
  /// Menambah agenda ke Kalender Akademik (UC-01)
  void onSiarkan() {
    Get.snackbar(
      'Siarkan Pengumuman',
      'Buat pengumuman atau tambahkan agenda ke kalender akademik.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
      backgroundColor: const Color(0xFFE8F5E9),
      colorText: const Color(0xFF2E7D32),
    );
    // TODO: Get.to(() => const AdminKalenderFormView())
  }

  /// Dipanggil saat admin menekan "Moderasi"
  /// Moderasi Lost & Found (UC-04, UC-08)
  void onModerasi() {
    Get.snackbar(
      'Moderasi Konten',
      'Tinjau postingan Lost & Found yang menunggu persetujuan.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
    // TODO: Get.to(() => const AdminLostFoundModerasiView())
  }

  /// Dipanggil saat admin menekan "Tambah Agenda"
  void onTambahAgenda() {
    Get.snackbar(
      'Tambah Agenda',
      'Tambahkan agenda baru ke kalender akademik JTK.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  /// Dispatcher tindakan cepat
  void onTindakanCepatTapped(TindakanCepatType type) {
    switch (type) {
      case TindakanCepatType.tugaskan:
        onTugaskan();
        break;
      case TindakanCepatType.siarkan:
        onSiarkan();
        break;
      case TindakanCepatType.moderasi:
        onModerasi();
        break;
      case TindakanCepatType.tambahAgenda:
        onTambahAgenda();
        break;
    }
  }

  /// Lihat semua aktivitas terbaru
  void onLihatSemuaAktivitas() {
    // TODO: Get.to(() => const AdminAktivitasView())
    Get.snackbar(
      'Aktivitas',
      'Halaman riwayat aktivitas lengkap akan tersedia.',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  /// Tap pada satu item aktivitas — deep-link ke entitas terkait
  /// Sesuai field targetId pada entitas Notifikasi di PDF
  void onAktivitasTapped(AktivitasTerbaruModel aktivitas) {
    switch (aktivitas.tipe) {
      case TipeAktivitas.perbaikan:
      case TipeAktivitas.laporanBaru:
      case TipeAktivitas.delegasi:
        // TODO: Get.to(() => AdminDetailLaporanView(id: aktivitas.targetId))
        break;
      case TipeAktivitas.aspirasiBaru:
        // TODO: Get.to(() => AdminDetailAspirasiView(id: aktivitas.targetId))
        break;
      case TipeAktivitas.lostFound:
        // TODO: Get.to(() => AdminDetailLostFoundView(id: aktivitas.targetId))
        break;
    }
  }

  // ---- GETTERS ----
  String get sapaanAdmin {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi,';
    if (hour < 15) return 'Selamat Siang,';
    if (hour < 18) return 'Selamat Sore,';
    return 'Selamat Malam,';
  }
}
