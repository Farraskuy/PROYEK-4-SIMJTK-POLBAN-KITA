// ============================================================
// FILE: modules/home/teknisi/tugas/controller/daftar_tugas_controller.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// Sesuai UC-07: Mengelola Tindakan Teknisi
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/tugas_teknisi_model.dart';
import '../../laporan_fasilitas/model/laporan_fasilitas_model.dart';
import '../../laporan_fasilitas/view/selesaikan_tugas_view.dart';
import '../../laporan_fasilitas/view/detail_laporan_fasilitas_view.dart';
import '../../home/teknisi/view/home_view.dart';
import '../../riwayat_tugas/view/riwayat_tugas_view.dart';

class DaftarTugasController extends GetxController {
  // --------------------------------------------------------
  // STATE OBSERVABLES
  // --------------------------------------------------------

  /// Semua tugas (raw dari server/cache)
  final RxList<ItemTugasModel> _semuaTugas = <ItemTugasModel>[].obs;

  /// Tugas yang ditampilkan sesuai filter aktif
  final RxList<ItemTugasModel> tugasTampil = <ItemTugasModel>[].obs;

  /// Filter chip yang aktif
  final Rx<FilterTugas> activeFilter = FilterTugas.semua.obs;

  /// Status loading
  final RxBool isLoading = false.obs;

  /// Index bottom nav — 1 = TUGAS (aktif)
  final RxInt selectedNavIndex = 1.obs;

  // --------------------------------------------------------
  // GETTERS — jumlah per status (untuk badge count chip)
  // --------------------------------------------------------
  int get countSemua => _semuaTugas.length;
  int get countMenunggu => _semuaTugas
      .where((t) => t.status.filterGroup == FilterTugas.menunggu)
      .length;
  int get countDiproses => _semuaTugas
      .where((t) => t.status.filterGroup == FilterTugas.diproses)
      .length;
  int get countSelesai => _semuaTugas
      .where((t) => t.status.filterGroup == FilterTugas.selesai)
      .length;

  // --------------------------------------------------------
  // LIFECYCLE
  // --------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    _loadTugas();
  }

  // --------------------------------------------------------
  // PRIVATE METHODS
  // --------------------------------------------------------

  Future<void> _loadTugas() async {
    isLoading.value = true;

    // TODO: ganti dengan service call nyata
    // Offline-first: coba ambil dari local cache dulu,
    // lalu sync dari server bila online
    await Future.delayed(const Duration(milliseconds: 450));

    _semuaTugas.assignAll(ItemTugasModel.dummyList());
    _applyFilter();

    isLoading.value = false;
  }

  void _applyFilter() {
    final filter = activeFilter.value;

    if (filter == FilterTugas.semua) {
      // Sort: menunggu → diproses → selesai
      final sorted = List<ItemTugasModel>.from(_semuaTugas)
        ..sort((a, b) => _sortOrder(a).compareTo(_sortOrder(b)));
      tugasTampil.assignAll(sorted);
    } else {
      final filtered =
          _semuaTugas.where((t) => t.status.filterGroup == filter).toList()
            ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      tugasTampil.assignAll(filtered);
    }
  }

  /// Urutan tampil: menunggu (0) → diproses (1) → selesai (2)
  int _sortOrder(ItemTugasModel t) {
    switch (t.status.filterGroup) {
      case FilterTugas.menunggu:
        return 0;
      case FilterTugas.diproses:
        return 1;
      case FilterTugas.selesai:
        return 2;
      default:
        return 3;
    }
  }

  // --------------------------------------------------------
  // PUBLIC METHODS
  // --------------------------------------------------------

  /// Ganti filter aktif saat chip ditekan
  void onFilterChanged(FilterTugas filter) {
    if (activeFilter.value == filter) return;
    activeFilter.value = filter;
    _applyFilter();
  }

  /// Pull-to-refresh
  Future<void> onRefresh() async => await _loadTugas();

  /// Tap pada item tugas → buka detail (UC-07)
  void onItemTapped(ItemTugasModel tugas) {
    Get.to(
      () => DetailLaporanFasilitasView(
        laporanId: tugas.id,
        role: RoleUser.staff, // Petugas teknisi
      ),
    );
  }

  /// Mulai kerjakan — ubah status assigned → inProgress (UC-07)
  Future<void> onMulaiKerjakan(ItemTugasModel tugas) async {
    final idx = _semuaTugas.indexWhere((t) => t.id == tugas.id);
    if (idx == -1) return;

    final updated = ItemTugasModel(
      id: tugas.id,
      nomorRef: tugas.nomorRef,
      judul: tugas.judul,
      lokasi: tugas.lokasi,
      kategori: tugas.kategori,
      status: StatusLaporanTeknisi.inProgress,
      prioritas: tugas.prioritas,
      estimasiSelesai: tugas.estimasiSelesai,
      isSynced: tugas.isSynced,
      createdAt: tugas.createdAt,
      updatedAt: DateTime.now(),
    );

    _semuaTugas[idx] = updated;
    _applyFilter();

    Get.snackbar(
      'Tugas Dimulai',
      '"${tugas.judul}" sedang dikerjakan.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      margin: const EdgeInsets.all(16),
    );
  }

  /// Selesaikan tugas → buka form upload foto bukti (UC-07)
  void onSelesaikan(ItemTugasModel tugas) {
    // Konversi ItemTugasModel ke LaporanFasilitasModel untuk halaman selesaikan
    final laporan = _convertToLaporanFasilitas(tugas);
    Get.to(() => SelesaikanTugasView(laporan: laporan));
  }

  /// Konversi ItemTugasModel ke LaporanFasilitasModel
  LaporanFasilitasModel _convertToLaporanFasilitas(ItemTugasModel tugas) {
    // Mapping status
    StatusLaporan status;
    switch (tugas.status) {
      case StatusLaporanTeknisi.pending:
        status = StatusLaporan.pending;
        break;
      case StatusLaporanTeknisi.assigned:
        status = StatusLaporan.assigned;
        break;
      case StatusLaporanTeknisi.inProgress:
        status = StatusLaporan.inProgress;
        break;
      case StatusLaporanTeknisi.resolved:
        status = StatusLaporan.resolved;
        break;
      case StatusLaporanTeknisi.rejected:
        status = StatusLaporan.rejected;
        break;
    }

    return LaporanFasilitasModel(
      id: tugas.id,
      judul: tugas.judul,
      deskripsi: 'Tugas teknisi yang perlu diselesaikan', // Placeholder
      kategoriId: 'kategori-id', // Placeholder
      lokasiLabKelas: tugas.lokasi,
      fotoUrls: [], // Kosong
      status: status,
      prioritas: tugas.prioritas,
      pelaporId: 'pelapor-id', // Placeholder
      handlerId: 'handler-id', // Placeholder
      estimasiSelesai: tugas.estimasiSelesai,
      syncStatus: tugas.isSynced ? SyncStatus.synced : SyncStatus.local,
      createdAt: tugas.createdAt,
      updatedAt: tugas.updatedAt,
      tindakan: [], // Kosong
      namaKategori: tugas.kategori,
    );
  }

  /// Bottom nav tap
  void onNavTapped(int index) {
    selectedNavIndex.value = index;
    // TODO: navigasi ke halaman lain
    switch (index) {
      case 0:
        Get.to(() => const HomeTeknisiView());
        break;
      case 2:
        Get.to(() => const RiwayatTugasView());
        break;
    }
  }
}
