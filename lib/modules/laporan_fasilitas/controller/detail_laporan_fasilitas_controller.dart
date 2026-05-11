import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import '../model/laporan_fasilitas_model.dart';
import '../service/detail_laporan_fasilitas_service.dart';
import '../service/laporan_fasilitas_service.dart';

class DetailLaporanFasilitasController extends ChangeNotifier {
  final DetailLaporanFasilitasService _detailService =
      DetailLaporanFasilitasService();
  final LaporanFasilitasService _laporanService = LaporanFasilitasService();

  LaporanFasilitasModel? laporan;
  bool isLoading = true;
  bool isSubmitting = false;
  String? errorMessage;

  Future<void> fetchLaporan(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      laporan = await _detailService.getLaporanById(id);
    } catch (e) {
      errorMessage = 'Gagal memuat laporan: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> delegasikan(String teknisiId) async {
    if (laporan == null) return;
    try {
      await _detailService.delegasikanLaporan(laporan!.id, teknisiId);
      await fetchLaporan(laporan!.id);
    } catch (e) {
      errorMessage = 'Gagal mendelegasikan: $e';
      notifyListeners();
    }
  }

  Future<bool> tanggapiPetugas({
    required String catatan,
    required bool ajukanKeTu,
    required String kebutuhanTu,
  }) async {
    if (laporan == null) return false;
    if (catatan.trim().isEmpty) {
      errorMessage = 'Catatan petugas wajib diisi.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await AuthService().loadSavedSession();
      final teknisiId = user?.id ?? user?.nomorInduk ?? 'petugas';
      await _laporanService.tanggapiPetugas(
        laporanId: laporan!.id,
        teknisiId: teknisiId,
        catatan: catatan.trim(),
        ajukanKeTu: ajukanKeTu,
        kebutuhanTu: kebutuhanTu.trim().isEmpty
            ? catatan.trim()
            : kebutuhanTu.trim(),
      );
      await fetchLaporan(laporan!.id);
      return true;
    } catch (e) {
      errorMessage = 'Gagal menyimpan tanggapan: $e';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  Future<bool> tandaiDicetak() async {
    if (laporan == null) return false;
    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      final user = await AuthService().loadSavedSession();
      await _laporanService.tandaiDicetak(
        laporanId: laporan!.id,
        printedBy: user?.id ?? user?.nomorInduk ?? 'tu',
      );
      await fetchLaporan(laporan!.id);
      return true;
    } catch (e) {
      errorMessage = 'Gagal menandai cetak: $e';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}
