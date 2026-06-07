// ============================================================
// FILE: modules/home/teknisi/controller/home_teknisi_controller.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// Sesuai UC-07: Mengelola Tindakan Teknisi
// MODIFIKASI: Tugas Mendesak dari DB laporan_fasilitas, sort by vote_score
// ============================================================

import 'package:get/get.dart';
import '../model/home_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/tanggapan_tugas_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';

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

  /// Status loading
  final RxBool isLoading = false.obs;

  /// Status koneksi internet (offline-first sesuai PDF)
  final RxBool isOnline = true.obs;

  // --------------------------------------------------------
  // SERVICES
  // --------------------------------------------------------
  final LaporanFasilitasService _laporanService = LaporanFasilitasService();
  final TanggapanTugasService _draftService = TanggapanTugasService();

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
      final session =
          AuthService().currentUser ?? await AuthService().loadSavedSession();
      if (session != null) {
        currentTeknisi.value = TeknisiUserModel(
          id: session.id,
          name: session.name,
          nimNip: session.nomorInduk,
          email: session.email,
          role: session.role,
          spesialisasi: 'Teknisi JTK',
          isActive: session.isActive,
        );
      }

      final allLaporan = await _laporanService.getAll();
      final drafts = await _draftService.getAllDrafts();
      final activeLaporan = allLaporan
          .where(
            (laporan) =>
                laporan.status != StatusLaporan.resolved &&
                drafts[laporan.id]?['form_status'] != 'selesai',
          )
          .toList();

      // Urutkan berdasarkan vote_score tertinggi (Top Upvote) untuk Tugas Mendesak
      final sorted = List<LaporanFasilitasModel>.from(activeLaporan)
        ..sort((a, b) => b.vote_score.compareTo(a.vote_score));

      tugasMendesak.assignAll(sorted);

      // Hitung statistik dari data real
      final aliases = {
        session?.id.trim().toLowerCase(),
        session?.nomorInduk.trim().toLowerCase(),
      }..removeWhere((value) => value == null || value.isEmpty);
      final milikTeknisi = allLaporan.where((laporan) {
        final teknisiId = laporan.teknisi_id?.trim().toLowerCase();
        return teknisiId != null && aliases.contains(teknisiId);
      }).toList();
      final selesai = milikTeknisi
          .where(
            (laporan) =>
                laporan.status == StatusLaporan.resolved ||
                drafts[laporan.id]?['form_status'] == 'selesai',
          )
          .length;
      final pending = activeLaporan
          .where(
            (l) =>
                l.status == StatusLaporan.pending ||
                l.status == StatusLaporan.in_progress,
          )
          .length;

      statistik.value = StatistikTugasModel(
        totalTugas: activeLaporan.length,
        tugasSelesai: selesai,
        tugasPending: pending,
        tugasInProgress: activeLaporan
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
