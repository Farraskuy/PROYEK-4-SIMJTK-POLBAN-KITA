// lib/modules/laporan_fasilitas/controller/fasilitas_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/laporan_fasilitas_model.dart';
import '../service/laporan_fasilitas_service.dart';

class FasilitasController extends GetxController {
  final LaporanFasilitasService _service = LaporanFasilitasService();

  // State untuk daftar laporan dan kategori
  var listLaporan = <LaporanFasilitasModel>[].obs;
  var isLoading = false.obs;

  // Master data untuk dropdown kategori sesuai skema kategori_fasilitas
  var daftarKategori = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  /// Mengambil data terbaru dari service[cite: 7, 11]
  Future<void> refreshData() async {
    isLoading.value = true;
    try {
      final data = await _service.getAll();
      listLaporan.assignAll(data);
    } catch (e) {
      Get.snackbar("Error", "Gagal menyegarkan data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  /// Mencari laporan berdasarkan ID (_id)[cite: 7, 8]
  LaporanFasilitasModel? findLaporanById(String id) {
    return listLaporan.firstWhereOrNull((l) => l.id == id);
  }

  /// Update status laporan (misal: membatalkan laporan)[cite: 8, 11]
  Future<void> updateStatusLaporan(String id, StatusLaporan newStatus) async {
    final index = listLaporan.indexWhere((l) => l.id == id);
    if (index != -1) {
      try {
        final updatedLaporan = listLaporan[index];
        updatedLaporan.status = newStatus;
        updatedLaporan.updatedAt = DateTime.now();

        await _service.update(updatedLaporan); // Sync ke MongoDB[cite: 7]
        listLaporan[index] = updatedLaporan;
        listLaporan.refresh();
      } catch (e) {
        Get.snackbar("Gagal", "Gagal memperbarui status: $e");
      }
    }
  }

  // Komentar: Fungsi lama yang menggunakan 'lokasiLabKelas' atau 'fotoUrls'
  // sudah digantikan oleh getter di model agar tetap aman.
}
