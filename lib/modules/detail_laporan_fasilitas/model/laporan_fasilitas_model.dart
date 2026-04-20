enum StatusLaporan { pending, assigned, inProgress, resolved, rejected }

enum RoleUser { mahasiswa, staff, admin }

class TindakanFasilitas {
  final String id;
  final String aktivitas;
  final String? catatanPengerjaan;
  final List<String>? fotoBuktiUrls;
  final DateTime timestamp;
  final String aktorNama;

  TindakanFasilitas({
    required this.id,
    required this.aktivitas,
    this.catatanPengerjaan,
    this.fotoBuktiUrls,
    required this.timestamp,
    required this.aktorNama,
  });
}

class LaporanFasilitasModel {
  final String id;
  final String judul;
  final String deskripsi;
  final String lokasiLabKelas;
  final List<String> fotoUrls;
  final StatusLaporan status;
  final String prioritas;
  final String pelaporNama;
  final String pelaporId;
  final String? handlerNama;
  final String? handlerId;
  final DateTime? estimasiSelesai;
  final DateTime createdAt;
  final List<TindakanFasilitas> riwayat;

  LaporanFasilitasModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.lokasiLabKelas,
    required this.fotoUrls,
    required this.status,
    required this.prioritas,
    required this.pelaporNama,
    required this.pelaporId,
    this.handlerNama,
    this.handlerId,
    this.estimasiSelesai,
    required this.createdAt,
    required this.riwayat,
  });

  String get statusLabel {
    switch (status) {
      case StatusLaporan.pending:
        return 'Menunggu';
      case StatusLaporan.assigned:
        return 'Ditugaskan';
      case StatusLaporan.inProgress:
        return 'Sedang Diperbaiki';
      case StatusLaporan.resolved:
        return 'Selesai';
      case StatusLaporan.rejected:
        return 'Ditolak';
    }
  }
}
