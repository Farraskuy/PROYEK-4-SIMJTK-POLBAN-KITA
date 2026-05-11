// lib/modules/home/controller/home_controller.dart

import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import '../model/home_model.dart';

enum MahasiswaNavTarget { laporanFasilitas, aspirasi }

class HomeController extends GetxController {
  // --------------------------------------------------------
  // STATE OBSERVABLES
  // --------------------------------------------------------

  /// Data user yang sedang login (Menggunakan identitas kamu)[cite: 6]
  final Rx<UserModel> currentUser = const UserModel(
    id: 'usr-001',
    name: 'Zidan Taufiqurahman',
    nomorInduk: '241511006',
    passwordHash: '',
    role: 'mahasiswa',
    isActive: true,
    email: 'zidan@student.polban.ac.id',
  ).obs;

  final RxList<KalenderAkademikModel> kalenderList =
      <KalenderAkademikModel>[].obs;
  final RxList<AksesCepatModel> aksesCepatList = <AksesCepatModel>[].obs;
  final RxList<AspirasiModel> aspirasiTrendingList = <AspirasiModel>[].obs;
  final RxInt selectedNavIndex = 0.obs;
  final RxInt activeKalenderIndex = 0.obs;
  final RxBool isLoading = false.obs;
  final RxInt unreadNotifCount = 3.obs;

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

    final sorted = AspirasiModel.dummyList()
      ..sort((a, b) => b.upvoteCount.compareTo(a.upvoteCount));
    aspirasiTrendingList.assignAll(sorted);

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
        // Profil
        Get.snackbar(
          'Profil',
          'Menuju Profil...',
          snackPosition: SnackPosition.BOTTOM,
        );
        return null;
    }
    return null;
  }

  void onKalenderPageChanged(int index) {
    activeKalenderIndex.value = index;
  }

  void onUpvoteAspirasi(String aspirasiId) {
    final idx = aspirasiTrendingList.indexWhere((a) => a.id == aspirasiId);
    if (idx == -1) return;

    final current = aspirasiTrendingList[idx];
    final userId = currentUser.value.id;
    final alreadyVoted = current.upvoterIds.contains(userId);
    final updatedVoters = List<String>.from(current.upvoterIds);
    int updatedCount = current.upvoteCount;

    if (alreadyVoted) {
      updatedVoters.remove(userId);
      updatedCount--;
    } else {
      updatedVoters.add(userId);
      updatedCount++;
    }

    final updated = AspirasiModel(
      id: current.id,
      topik: current.topik,
      isiSaran: current.isiSaran,
      isAnonymous: current.isAnonymous,
      pelaporId: current.pelaporId,
      pelaporName: current.pelaporName,
      upvoteCount: updatedCount,
      upvoterIds: updatedVoters,
      tanggapanJurusan: current.tanggapanJurusan,
      status: current.status,
      kategori: current.kategori,
      createdAt: current.createdAt,
    );

    aspirasiTrendingList[idx] = updated;
    aspirasiTrendingList.sort((a, b) => b.upvoteCount.compareTo(a.upvoteCount));
  }

  bool isUpvoted(AspirasiModel aspirasi) {
    return aspirasi.upvoterIds.contains(currentUser.value.id);
  }

  void onNotificationTapped() {
    unreadNotifCount.value = 0;
  }

  void onLihatSemuaKalender() {}
  void onLihatSemuaAksesCepat() {}
  MahasiswaNavTarget onLihatSemuaAspirasi() => MahasiswaNavTarget.aspirasi;

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
