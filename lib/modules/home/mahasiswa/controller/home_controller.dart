import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import '../model/home_model.dart';
import '../../../laporan_fasilitas/view/laporan_fasilitas_mahasiswa_view.dart';
import '../../../aspirasi/view/aspirasi_view.dart';

class HomeController extends GetxController {
  // --------------------------------------------------------
  // STATE OBSERVABLES
  // --------------------------------------------------------

  /// Data user yang sedang login
  final Rx<UserModel> currentUser = const UserModel(
    id: 'usr-001',
    username: '241511006',
    email: 'budi@student.polban.ac.id',
    name: 'Budi',
    role: 'mahasiswa',
    isActive: true,
  ).obs;

  /// List agenda kalender yang ditampilkan di carousel
  final RxList<KalenderAkademikModel> kalenderList =
      <KalenderAkademikModel>[].obs;

  /// List menu akses cepat
  final RxList<AksesCepatModel> aksesCepatList = <AksesCepatModel>[].obs;

  /// List aspirasi trending (diurutkan berdasarkan upvoteCount desc)
  final RxList<AspirasiModel> aspirasiTrendingList = <AspirasiModel>[].obs;

  /// Indeks bottom navigation bar yang aktif
  final RxInt selectedNavIndex = 0.obs;

  /// Indeks kartu kalender yang aktif (untuk page indicator)
  final RxInt activeKalenderIndex = 0.obs;

  /// Status loading data
  final RxBool isLoading = false.obs;

  /// Jumlah notifikasi belum dibaca
  final RxInt unreadNotifCount = 3.obs;

  // --------------------------------------------------------
  // LIFECYCLE
  // --------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    _loadHomepageData();
  }

  // --------------------------------------------------------
  // PRIVATE METHODS
  // --------------------------------------------------------

  /// Simulasi fetch data (ganti dengan service call di implementasi nyata)
  Future<void> _loadHomepageData() async {
    isLoading.value = true;

    // Simulasi network delay
    await Future.delayed(const Duration(milliseconds: 600));

    kalenderList.assignAll(KalenderAkademikModel.dummyList());
    aksesCepatList.assignAll(AksesCepatModel.dummyList());

    // Urutkan aspirasi berdasarkan upvote terbanyak (trending)
    final sorted = AspirasiModel.dummyList()
      ..sort((a, b) => b.upvoteCount.compareTo(a.upvoteCount));
    aspirasiTrendingList.assignAll(sorted);

    isLoading.value = false;
  }

  // --------------------------------------------------------
  // PUBLIC METHODS
  // --------------------------------------------------------

  /// Dipanggil saat user memilih item bottom nav
  void onNavItemTapped(int index) {
    selectedNavIndex.value = index;
    switch (index) {
      case 0:
        // Home - stay on home
        break;
      case 1:
        // Layanan - redirect ke Laporan Fasilitas Mahasiswa
        Get.to(() => const LaporanFasilitasMahasiswaView());
        break;
      case 2:
        // Aspirasi
        Get.to(() => const AspirasiView());
        break;
      case 3:
        // Profil
        Get.snackbar(
          'Profil',
          'Menuju Profil...',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }
  }

  /// Dipanggil saat kartu kalender di-swipe
  void onKalenderPageChanged(int index) {
    activeKalenderIndex.value = index;
  }

  /// Dipanggil saat user menekan tombol Upvote pada aspirasi
  void onUpvoteAspirasi(String aspirasiId) {
    final idx = aspirasiTrendingList.indexWhere((a) => a.id == aspirasiId);
    if (idx == -1) return;

    final current = aspirasiTrendingList[idx];
    final userId = currentUser.value.id;

    // Toggle: jika sudah upvote maka cancel, sebaliknya tambah
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

    // Buat instance baru (immutable pattern)
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

    // Urutkan ulang setelah update
    aspirasiTrendingList.sort((a, b) => b.upvoteCount.compareTo(a.upvoteCount));
  }

  /// Apakah user sudah memberi upvote pada aspirasi tertentu
  bool isUpvoted(AspirasiModel aspirasi) {
    return aspirasi.upvoterIds.contains(currentUser.value.id);
  }

  /// Dipanggil saat user menekan icon notifikasi
  void onNotificationTapped() {
    unreadNotifCount.value = 0;
    // TODO: Get.toNamed(Routes.notifikasi)
  }

  /// Dipanggil saat "Lihat Semua" kalender ditekan
  void onLihatSemuaKalender() {
    // TODO: Get.toNamed(Routes.kalender)
  }

  /// Dipanggil saat "Lihat Semua" akses cepat ditekan
  void onLihatSemuaAksesCepat() {
    // TODO: Get.toNamed(Routes.layanan)
  }

  /// Dipanggil saat "Lihat Semua" aspirasi ditekan
  void onLihatSemuaAspirasi() {
    Get.to(() => const AspirasiView());
  }

  /// Dipanggil saat salah satu menu akses cepat ditekan
  void onAksesCepatTapped(AksesCepatRoute route) {
    switch (route) {
      case AksesCepatRoute.laporFasilitas:
        // TODO: Get.toNamed(Routes.laporFasilitas)
        Get.to(() => const LaporanFasilitasMahasiswaView());
        break;
      case AksesCepatRoute.lostFound:
        Get.snackbar(
          'Akses Cepat',
          'Menuju Lost & Found...',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case AksesCepatRoute.beasiswa:
        Get.snackbar(
          'Akses Cepat',
          'Menuju Beasiswa...',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case AksesCepatRoute.suratKeterangan:
        Get.snackbar(
          'Akses Cepat',
          'Menuju Surat Keterangan...',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case AksesCepatRoute.izinLab:
        Get.snackbar(
          'Akses Cepat',
          'Menuju Izin Lab...',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case AksesCepatRoute.peminjamanRuang:
        Get.snackbar(
          'Akses Cepat',
          'Menuju Peminjaman Ruang...',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case AksesCepatRoute.jadwalKuliah:
        Get.snackbar(
          'Akses Cepat',
          'Menuju Jadwal Kuliah...',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case AksesCepatRoute.infoUkt:
        Get.snackbar(
          'Akses Cepat',
          'Menuju Info UKT...',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }
  }

  /// Refresh seluruh data homepage (pull-to-refresh)
  Future<void> refreshData() async {
    await _loadHomepageData();
  }
}
