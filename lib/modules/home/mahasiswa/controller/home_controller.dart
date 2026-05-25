// lib/modules/home/controller/home_controller.dart

import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import '../model/home_model.dart';

enum MahasiswaNavTarget { laporanFasilitas, aspirasi, profile }

class HomeController extends GetxController {
  // --------------------------------------------------------
  // STATE OBSERVABLES
  // --------------------------------------------------------

  /// Data user yang sedang login (Menggunakan identitas kamu)[cite: 6]
  UserModel? get currentUser => AuthService().currentUser;

  final RxList<KalenderAkademikModel> kalenderList =
      <KalenderAkademikModel>[].obs;
  final RxList<AksesCepatModel> aksesCepatList = <AksesCepatModel>[].obs;
    final RxList<LaporanFasilitasModel> laporanTrendingList =
      <LaporanFasilitasModel>[].obs;
  final RxInt selectedNavIndex = 0.obs;
  final RxInt activeKalenderIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadNotifCount = 3.obs;

    final LaporanFasilitasService _laporanService = LaporanFasilitasService();

  @override
  void onInit() {
    super.onInit();
    _loadHomepageData();
  }

  // --------------------------------------------------------
  // PRIVATE METHODS
  // --------------------------------------------------------

  Future<void> _loadHomepageData() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 600));

    kalenderList.assignAll(KalenderAkademikModel.dummyList());
    aksesCepatList.assignAll(AksesCepatModel.dummyList());

    try {
      final laporan = await _laporanService.getForRole('mahasiswa');
      laporanTrendingList.assignAll(laporan);
    } catch (_) {
      laporanTrendingList.clear();
    }

    isLoading.value = false;
  }

  // --------------------------------------------------------
  // PUBLIC METHODS
  // --------------------------------------------------------

  /// Navigasi dari Bottom Navigation Bar[cite: 6]
  MahasiswaNavTarget? onNavItemTapped(int index) {
    selectedNavIndex.value = index;
    switch (index) {
      case 0:
        // Home
        return null;
      case 1:
        return MahasiswaNavTarget.laporanFasilitas;
      case 2:
        return MahasiswaNavTarget.aspirasi;
      case 3:
        return MahasiswaNavTarget.profile;
    }
    return null;
  }

  void onKalenderPageChanged(int index) {
    activeKalenderIndex.value = index;
  }

  String get _currentUserId {
    final user = currentUser;
    if (user == null) return '';
    return user.id.isNotEmpty ? user.id : user.nomorInduk;
  }

  void onUpvoteLaporan(String laporanId) {
    if (_currentUserId.isEmpty) return;
    final idx = laporanTrendingList.indexWhere((laporan) => laporan.id == laporanId);
    if (idx == -1) return;

    final current = laporanTrendingList[idx];
    final alreadyUpvoted = current.upvoter_ids.contains(_currentUserId);
    final updatedUpvoters = List<String>.from(current.upvoter_ids);
    final updatedDownvoters = List<String>.from(current.downvoter_ids);

    if (alreadyUpvoted) {
      updatedUpvoters.remove(_currentUserId);
    } else {
      updatedUpvoters.add(_currentUserId);
      updatedDownvoters.remove(_currentUserId);
    }

    laporanTrendingList[idx] = current.copyWith(
      upvoterIds: updatedUpvoters,
      downvoterIds: updatedDownvoters,
      voteScore: updatedUpvoters.length - updatedDownvoters.length,
      updatedAt: DateTime.now(),
    );
  }

  void onDownvoteLaporan(String laporanId) {
    if (_currentUserId.isEmpty) return;
    final idx = laporanTrendingList.indexWhere((laporan) => laporan.id == laporanId);
    if (idx == -1) return;

    final current = laporanTrendingList[idx];
    final alreadyDownvoted = current.downvoter_ids.contains(_currentUserId);
    final updatedUpvoters = List<String>.from(current.upvoter_ids);
    final updatedDownvoters = List<String>.from(current.downvoter_ids);

    if (alreadyDownvoted) {
      updatedDownvoters.remove(_currentUserId);
    } else {
      updatedDownvoters.add(_currentUserId);
      updatedUpvoters.remove(_currentUserId);
    }

    laporanTrendingList[idx] = current.copyWith(
      upvoterIds: updatedUpvoters,
      downvoterIds: updatedDownvoters,
      voteScore: updatedUpvoters.length - updatedDownvoters.length,
      updatedAt: DateTime.now(),
    );
  }

  bool isLaporanUpvoted(LaporanFasilitasModel laporan) {
    return laporan.upvoter_ids.contains(_currentUserId);
  }

  bool isLaporanDownvoted(LaporanFasilitasModel laporan) {
    return laporan.downvoter_ids.contains(_currentUserId);
  }

  void onNotificationTapped() {
    unreadNotifCount.value = 0;
  }

  void onLihatSemuaKalender() {}
  void onLihatSemuaAksesCepat() {}
  MahasiswaNavTarget onLihatSemuaAspirasi() =>
      MahasiswaNavTarget.laporanFasilitas;

  /// Navigasi dari Grid Akses Cepat di Dashboard[cite: 6]
  MahasiswaNavTarget? onAksesCepatTapped(AksesCepatRoute route) {
    switch (route) {
      case AksesCepatRoute.laporFasilitas:
        return MahasiswaNavTarget.laporanFasilitas;
      case AksesCepatRoute.lostFound:
        Get.snackbar(
          'Akses Cepat',
          'Menuju Lost & Found...',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      case AksesCepatRoute.beasiswa:
        Get.snackbar(
          'Akses Cepat',
          'Menuju Beasiswa...',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      case AksesCepatRoute.suratKeterangan:
        Get.snackbar(
          'Akses Cepat',
          'Menuju Surat Keterangan...',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      case AksesCepatRoute.izinLab:
        Get.snackbar(
          'Akses Cepat',
          'Menuju Izin Lab...',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      case AksesCepatRoute.peminjamanRuang:
        Get.snackbar(
          'Akses Cepat',
          'Menuju Peminjaman Ruang...',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      case AksesCepatRoute.jadwalKuliah:
        Get.snackbar(
          'Akses Cepat',
          'Menuju Jadwal Kuliah...',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
      case AksesCepatRoute.infoUkt:
        Get.snackbar(
          'Akses Cepat',
          'Menuju Info UKT...',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
    }
  }

  Future<void> refreshData() async {
    await _loadHomepageData();
  }
}
