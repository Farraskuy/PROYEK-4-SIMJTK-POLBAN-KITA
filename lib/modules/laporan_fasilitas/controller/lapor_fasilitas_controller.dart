// lib/modules/laporan_fasilitas/controller/lapor_fasilitas_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/laporan_fasilitas_model.dart';
import '../service/laporan_fasilitas_service.dart';

class LaporFasilitasController extends GetxController {
  final formKey = GlobalKey<FormState>();

  // Controller untuk input text
  final judulController = TextEditingController();
  final lokasiController = TextEditingController();
  final deskripsiController = TextEditingController();

  final RxList<String> selectedFotoPaths = <String>[].obs;
  final RxBool isSubmitting = false.obs;

  // Variabel untuk menangani Mode Edit
  final RxBool isEditMode = false.obs;
  String? _idLaporanLama;

  final LaporanFasilitasService _service = LaporanFasilitasService();

  // Getter dinamis untuk UI View
  String get pageTitle =>
      isEditMode.value ? "Edit Laporan" : "Lapor Kerusakan Fasilitas";
  String get submitButtonLabel =>
      isEditMode.value ? "Simpan Perubahan" : "Kirim Laporan";

  // --- LOGIKA EDIT (FIX ERROR) ---

  /// Fungsi ini dipanggil dari View untuk mengisi form dengan data lama
  void setupEditPage(LaporanFasilitasModel laporan) {
    isEditMode.value = true;
    _idLaporanLama = laporan.id;

    // Isi field dengan data yang sudah ada di database[cite: 7]
    judulController.text = laporan.judul;
    lokasiController.text = laporan.lokasi;
    deskripsiController.text = laporan.deskripsi;
    selectedFotoPaths.assignAll(laporan.foto_urls);
  }

  // --- LOGIKA SUBMIT (CREATE & UPDATE) ---[cite: 7]

  Future<void> onSubmitLaporan() async {
    // Validasi input[cite: 7]
    if (lokasiController.text.isEmpty || deskripsiController.text.isEmpty) {
      Get.snackbar("Error", "Field Lokasi dan Deskripsi wajib diisi");
      return;
    }

    isSubmitting.value = true;
    try {
      final now = DateTime.now();

      // Susun data model sesuai skema MongoDB[cite: 7]
      final laporanData = LaporanFasilitasModel(
        // Jika edit pakai ID lama, jika baru buat ID baru[cite: 7]
        id: isEditMode.value
            ? _idLaporanLama!
            : 'LAP-${now.millisecondsSinceEpoch}',
        judul: judulController.text.isEmpty
            ? "Laporan Fasilitas"
            : judulController.text,
        deskripsi: deskripsiController.text,
        lokasi: lokasiController.text,
        foto_urls: List.from(selectedFotoPaths),
        pelapor_id: 'user_dummy_123', // ID User dummy
        status: StatusLaporan.pending,
        vote_score: 0,
        createdAt: now,
        updatedAt: now,
      );

      if (isEditMode.value) {
        // Panggil service update untuk MongoDB[cite: 7]
        await _service.update(laporanData);
        Get.snackbar("Sukses", "Laporan berhasil diperbarui");
      } else {
        // Panggil service create untuk data baru[cite: 7]
        await _service.create(laporanData);
        Get.snackbar("Sukses", "Laporan berhasil terkirim");
      }

      // Kembali ke halaman sebelumnya dan kirim sinyal refresh[cite: 7]
      Get.back(result: true);
    } catch (e) {
      Get.snackbar("Gagal", "Terjadi kesalahan: ${e.toString()}");
    } finally {
      isSubmitting.value = false;
    }
  }

  // --- HELPER METHODS ---[cite: 7]

  void onBatalKembali() => Get.back();

  @override
  void onClose() {
    // Bersihkan memori controller saat tidak dipakai[cite: 7]
    judulController.dispose();
    lokasiController.dispose();
    deskripsiController.dispose();
    super.onClose();
  }
}
