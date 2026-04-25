import '../model/laporan_fasilitas_model.dart';

class DetailLaporanFasilitasService {
  // TODO: Ganti dengan Dio/http call ke API atau query Hive lokal

  Future<LaporanFasilitasModel> getLaporanById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));

    return LaporanFasilitasModel(
      id: id,
      judul: 'AC Central Mati Total & Meneteskan Air',
      deskripsi:
          'AC tiba-tiba mati saat sedang digunakan rapat. Ada rembesan air cukup deras dari celah ventilasi. Harap segera ditangani karena ruangan akan digunakan kembali siang ini.',
      lokasiLabKelas: 'Ruang Rapat Eksekutif, Lt. 3 Gedung A',
      fotoUrls: [],
      status: StatusLaporan.inProgress,
      prioritas: 'high',
      pelaporNama: 'Bpk. Sudirman (Div. HRD)',
      pelaporId: 'user-001',
      handlerNama: 'Ahmad Sapri',
      handlerId: 'teknisi-001',
      estimasiSelesai: DateTime.now().add(const Duration(hours: 2)),
      createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      riwayat: [
        TindakanFasilitas(
          id: 'tindakan-001',
          aktivitas: 'Laporan Dibuat',
          catatanPengerjaan: 'Laporan berhasil diterima oleh sistem.',
          timestamp: DateTime.now().subtract(const Duration(hours: 1)),
          aktorNama: 'Sistem',
        ),
        TindakanFasilitas(
          id: 'tindakan-002',
          aktivitas: 'Ditugaskan ke Teknisi',
          catatanPengerjaan:
              'Teknisi Ahmad Sapri ditugaskan untuk menangani laporan ini.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
          aktorNama: 'Admin',
        ),
        TindakanFasilitas(
          id: 'tindakan-003',
          aktivitas: 'Sedang Diperbaiki',
          catatanPengerjaan:
              'Teknisi sedang melakukan pengecekan dan penggantian komponen di lokasi.',
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
          aktorNama: 'Ahmad Sapri',
        ),
      ],
    );
  }

  Future<void> delegasikanLaporan(String laporanId, String teknisiId) async {
    // TODO: PATCH /laporan/{id}/delegasi
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
