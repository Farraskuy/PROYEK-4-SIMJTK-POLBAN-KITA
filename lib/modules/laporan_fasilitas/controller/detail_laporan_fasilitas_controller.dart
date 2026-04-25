import 'package:flutter/material.dart';
import '../model/laporan_fasilitas_model.dart';
import '../service/detail_laporan_fasilitas_service.dart';

class DetailLaporanFasilitasController extends ChangeNotifier {
  final DetailLaporanFasilitasService _service =
      DetailLaporanFasilitasService();

  LaporanFasilitasModel? laporan;
  bool isLoading = true;
  String? errorMessage;

  Future<void> fetchLaporan(String id) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      laporan = await _service.getLaporanById(id);
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
      await _service.delegasikanLaporan(laporan!.id, teknisiId);
      // TODO: refresh laporan setelah delegasi
      await fetchLaporan(laporan!.id);
    } catch (e) {
      errorMessage = 'Gagal mendelegasikan: $e';
      notifyListeners();
    }
  }
}
