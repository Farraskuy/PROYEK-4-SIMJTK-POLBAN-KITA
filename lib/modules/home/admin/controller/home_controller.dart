// modules/admin/dashboard/controller/home_controller_3.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/home_model.dart';
 
// // Import file view/screen admin yang sudah ada
// import '../../../laporan_fasilitas/view/admin_laporan_fasilitas_screen.dart';
// import '../../../laporan_fasilitas/view/detail_laporan_fasilitas_view.dart';

class AdminDashboardController extends GetxController {
  // --------------------------------------------------------
  // STATE OBSERVABLES
  // --------------------------------------------------------
  final Rx<AdminUserModel> currentAdmin = AdminUserModel.dummy().obs;
  final Rx<StatistikLaporanModel?> statistikLaporan =
      Rx<StatistikLaporanModel?>(null);
  final Rx<StatistikRingkasanModel?> statistikRingkasan =
      Rx<StatistikRingkasanModel?>(null);
  final RxList<AktivitasTerbaruModel> aktivitasList =
      <AktivitasTerbaruModel>[].obs;
  final RxList<TindakanCepatModel> tindakanCepatList =
      <TindakanCepatModel>[].obs;
  final RxInt selectedNavIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadNotif = 5.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // --------------------------------------------------------
  // DATA LOADING
  // --------------------------------------------------------
  Future<void> loadDashboardData() async {
    isLoading.value = true;
    tindakanCepatList.assignAll(TindakanCepatModel.list());

    await Future.wait([
      _fetchStatistik(),
      _fetchRingkasan(),
      _fetchAktivitas(),
    ]);

    isLoading.value = false;
  }

  Future<void> _fetchStatistik() async {
    await Future.delayed(const Duration(milliseconds: 300));
    statistikLaporan.value = StatistikLaporanModel.dummy();
  }

  Future<void> _fetchRingkasan() async {
    await Future.delayed(const Duration(milliseconds: 200));
    statistikRingkasan.value = StatistikRingkasanModel.dummy();
  }

  Future<void> _fetchAktivitas() async {
    await Future.delayed(const Duration(milliseconds: 400));
    aktivitasList.assignAll(AktivitasTerbaruModel.dummyList());
  }

  Future<void> onRefresh() async => await loadDashboardData();

  // --------------------------------------------------------
  // NAVIGATION & ACTIONS (FIXED: Murni GetX)
  // --------------------------------------------------------
  void onNavTapped(int index) {
    selectedNavIndex.value = index;
    if (index == 1) {
      // Navigasi ke admin fasilitas tanpa Provider agar tidak error[cite: 11]
      // AppNavigator.push(const AdminLaporanFasilitasScreen());
    }
  }

  void onTugaskan() {
    // Navigasi cepat ke panel admin fasilitas[cite: 20]
    // AppNavigator.push(const AdminLaporanFasilitasScreen());
  }

  void onAktivitasTapped(AktivitasTerbaruModel aktivitas) {
    switch (aktivitas.tipe) {
      case TipeAktivitas.perbaikan:
      case TipeAktivitas.laporanBaru:
      case TipeAktivitas.delegasi:
        // Navigasi ke detail laporan menggunakan targetId (UUIDv4)
        // AppNavigator.push(DetailLaporanFasilitasView(
        //       laporanId: aktivitas.targetId,
        //       role: 'admin',
        //     ));
        break;
      default:
        break;
    }
  }

  void onNotifikasiTapped() => unreadNotif.value = 0;

  void onTindakanCepatTapped(TindakanCepatType type) {
    if (type == TindakanCepatType.tugaskan) onTugaskan();
    // Tambahkan dispatcher lainnya sesuai kebutuhan
  }

  void onLihatSemuaAktivitas() {
    Get.snackbar('Aktivitas', 'Halaman riwayat lengkap segera tersedia.');
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
