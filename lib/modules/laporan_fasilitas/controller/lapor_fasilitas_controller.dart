// lib/modules/laporan_fasilitas/controller/lapor_fasilitas_controller.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import '../model/laporan_fasilitas_model.dart';
import '../service/laporan_fasilitas_service.dart';

class LaporFasilitasController extends GetxController {
  final formKey = GlobalKey<FormState>();

  final judulController = TextEditingController();
  final lokasiController = TextEditingController();
  final deskripsiController = TextEditingController();

  final RxList<String> selectedFotoPaths = <String>[].obs;
  final RxBool isSubmitting = false.obs;

  final RxBool isEditMode = false.obs;
  String? _idLaporanLama;
  LaporanFasilitasModel? _laporanLama;

  final LaporanFasilitasService _service = LaporanFasilitasService();

  String get pageTitle =>
      isEditMode.value ? 'Edit Laporan' : 'Lapor Kerusakan Fasilitas';
  String get submitButtonLabel =>
      isEditMode.value ? 'Simpan Perubahan' : 'Kirim Laporan';

  void setupEditPage(LaporanFasilitasModel laporan) {
    isEditMode.value = true;
    _idLaporanLama = laporan.id;
    _laporanLama = laporan;

    judulController.text = laporan.judul;
    lokasiController.text = laporan.lokasi;
    deskripsiController.text = laporan.deskripsi;
    selectedFotoPaths.assignAll(laporan.foto_urls);
  }

  /// ─── FUNGSI BARU PENAMPUNG DATA KAMERA ───
  /// Menerima path file dari VisionView lokal dan menyimpannya ke dalam list laporan.
  void tambahFotoPath(String path) {
    if (path.isNotEmpty) {
      selectedFotoPaths.add(path);
      Get.snackbar(
        'Berhasil',
        'Foto berhasil ditambahkan ke laporan',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> onSubmitLaporan() async {
    if (lokasiController.text.trim().isEmpty ||
        deskripsiController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Field Lokasi dan Deskripsi wajib diisi');
      return false;
    }

    isSubmitting.value = true;
    try {
      final now = DateTime.now();
      final currentUser = await AuthService().loadSavedSession();
      final pelaporId =
          currentUser?.id ?? currentUser?.nomorInduk ?? 'anonymous';
      final old = _laporanLama;

      final laporanData = LaporanFasilitasModel(
        id: isEditMode.value
            ? _idLaporanLama!
            : 'LAP-${now.millisecondsSinceEpoch}',
        judul: judulController.text.trim().isEmpty
            ? 'Laporan Fasilitas'
            : judulController.text.trim(),
        deskripsi: deskripsiController.text.trim(),
        lokasi: lokasiController.text.trim(),
        foto_urls: List.from(selectedFotoPaths),
        pelapor_id: old?.pelapor_id ?? pelaporId,
        teknisi_id: old?.teknisi_id,
        status: old?.status ?? StatusLaporan.pending,
        vote_score: old?.vote_score ?? 0,
        upvoter_ids: old?.upvoter_ids ?? const [],
        downvoter_ids: old?.downvoter_ids ?? const [],
        createdAt: old?.createdAt ?? now,
        updatedAt: now,
        catatanPetugas: old?.catatanPetugas,
        kebutuhanTu: old?.kebutuhanTu,
        printedAt: old?.printedAt,
        printedBy: old?.printedBy,
      );

      if (isEditMode.value) {
        await _service.update(laporanData);
        Get.snackbar('Sukses', 'Laporan berhasil diperbarui');
      } else {
        await _service.create(laporanData);
        Get.snackbar('Sukses', 'Laporan berhasil terkirim');
      }

      return true;
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan: $e');
      return false;
    } finally {
      isSubmitting.value = false;
    }
  }

  @override
  void onClose() {
    judulController.dispose();
    lokasiController.dispose();
    deskripsiController.dispose();
    super.onClose();
  }
}
