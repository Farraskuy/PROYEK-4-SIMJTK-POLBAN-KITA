// Re-export model laporan yang dibutuhkan dari feature detail_laporan_fasilitas
export '../../detail_laporan_fasilitas/model/laporan_fasilitas_model.dart'
    show LaporanFasilitasModel, StatusLaporan;

class SelesaikanTugasModel {
  final String laporanId;
  final String catatanPengerjaan;
  final List<String> fotoBuktiPaths; // local file paths sebelum di-upload
  final int durasiMenit;

  SelesaikanTugasModel({
    required this.laporanId,
    required this.catatanPengerjaan,
    required this.fotoBuktiPaths,
    required this.durasiMenit,
  });

  bool get isValid =>
      catatanPengerjaan.trim().isNotEmpty &&
      fotoBuktiPaths.isNotEmpty &&
      durasiMenit > 0;
}
