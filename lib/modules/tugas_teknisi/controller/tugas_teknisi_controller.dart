// lib/modules/home/teknisi/tugas/controller/daftar_tugas_controller.dart

import 'package:get/get.dart';
import '../model/tugas_teknisi_model.dart';
import '../../laporan_fasilitas/model/laporan_fasilitas_model.dart';

class DaftarTugasController extends GetxController {
  // --------------------------------------------------------
  // STATE OBSERVABLES
  // --------------------------------------------------------
  final RxList<ItemTugasModel> _semuaTugas = <ItemTugasModel>[].obs;
  final RxList<ItemTugasModel> tugasTampil = <ItemTugasModel>[].obs;
  final Rx<FilterTugas> activeFilter = FilterTugas.semua.obs;
  final RxBool isLoading = false.obs;
  final RxInt selectedNavIndex = 1.obs;

  @override
  void onInit() {
    super.onInit();
    _loadTugas();
  }

  // --------------------------------------------------------
  // LOGIC & FILTERING
  // --------------------------------------------------------
  Future<void> _loadTugas() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 450));
    _semuaTugas.assignAll(ItemTugasModel.dummyList());
    _applyFilter();
    isLoading.value = false;
  }

  void _applyFilter() {
    final filter = activeFilter.value;
    if (filter == FilterTugas.semua) {
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
  void onFilterChanged(FilterTugas filter) {
    if (activeFilter.value == filter) return;
    activeFilter.value = filter;
    _applyFilter();
  }

  String onItemTapped(ItemTugasModel tugas) => tugas.id;

  LaporanFasilitasModel onSelesaikan(ItemTugasModel tugas) =>
      _convertToLaporanFasilitas(tugas);

  /// Konversi ItemTugasModel ke LaporanFasilitasModel
  /// Sesuai dengan skema database Farras (_id, foto_urls, teknisi_id)
  LaporanFasilitasModel _convertToLaporanFasilitas(ItemTugasModel tugas) {
    return LaporanFasilitasModel(
      id: tugas.id, // ID merujuk ke _id database[cite: 8]
      judul: tugas.judul,
      deskripsi: 'Deskripsi tugas teknisi',
      lokasi: tugas.lokasi, // Menggunakan lokasi sesuai model terbaru[cite: 8]
      foto_urls: [], // Menggunakan snake_case sesuai skema[cite: 8]
      pelapor_id: 'system',
      teknisi_id:
          'current_teknisi_id', // Menggunakan teknisi_id sesuai skema[cite: 8]
      status: StatusLaporan.fromValue(
        tugas.status.toString().split('.').last,
      ), // Sync dengan Enum terbaru[cite: 8]
      vote_score: 0,
      createdAt: tugas.createdAt,
      updatedAt: tugas.updatedAt,
    );
  }

  Future<void> onRefresh() async => await _loadTugas();
}
