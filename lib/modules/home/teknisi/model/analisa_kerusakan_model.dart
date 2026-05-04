// lib/modules/teknisi/analisa_kerusakan/model/analisa_kerusakan_model.dart

class AnalisaKerusakanModel {
  final String id; // UUIDv4
  final String laporanId; // Reference ke laporan_fasilitas._id
  final String teknisiId; // Reference ke users._id
  final String teknisiName;

  // Info laporan (denormalized untuk display)
  final String judulLaporan;
  final String lokasiLaporan;
  final String kategoriLaporan;

  // Field analisa teknis
  final String diagnosaMasalah; // Hasil diagnosa teknisi
  final String komponenRusak; // Komponen/bagian yang rusak
  final KategoriKerusakan kategoriKerusakan;
  final TingkatKerusakan tingkatKerusakan;
  final String tindakanDirekomendasikan; // Perbaikan / Penggantian / Penghapusan
  final String? catatanTambahan;
  final List<String> fotoAnalisaUrls; // Foto saat diagnosa

  // Estimasi
  final int? estimasiWaktuPerbaikanHari;
  final double? estimasiBiaya;

  final String syncStatus; // 'local' | 'synced'
  final DateTime createdAt;
  final DateTime updatedAt;

  AnalisaKerusakanModel({
    required this.id,
    required this.laporanId,
    required this.teknisiId,
    required this.teknisiName,
    required this.judulLaporan,
    required this.lokasiLaporan,
    required this.kategoriLaporan,
    required this.diagnosaMasalah,
    required this.komponenRusak,
    required this.kategoriKerusakan,
    required this.tingkatKerusakan,
    required this.tindakanDirekomendasikan,
    this.catatanTambahan,
    this.fotoAnalisaUrls = const [],
    this.estimasiWaktuPerbaikanHari,
    this.estimasiBiaya,
    this.syncStatus = 'local',
    required this.createdAt,
    required this.updatedAt,
  });

  AnalisaKerusakanModel copyWith({
    String? diagnosaMasalah,
    String? komponenRusak,
    KategoriKerusakan? kategoriKerusakan,
    TingkatKerusakan? tingkatKerusakan,
    String? tindakanDirekomendasikan,
    String? catatanTambahan,
    List<String>? fotoAnalisaUrls,
    int? estimasiWaktuPerbaikanHari,
    double? estimasiBiaya,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AnalisaKerusakanModel(
      id: id,
      laporanId: laporanId,
      teknisiId: teknisiId,
      teknisiName: teknisiName,
      judulLaporan: judulLaporan,
      lokasiLaporan: lokasiLaporan,
      kategoriLaporan: kategoriLaporan,
      diagnosaMasalah: diagnosaMasalah ?? this.diagnosaMasalah,
      komponenRusak: komponenRusak ?? this.komponenRusak,
      kategoriKerusakan: kategoriKerusakan ?? this.kategoriKerusakan,
      tingkatKerusakan: tingkatKerusakan ?? this.tingkatKerusakan,
      tindakanDirekomendasikan:
          tindakanDirekomendasikan ?? this.tindakanDirekomendasikan,
      catatanTambahan: catatanTambahan ?? this.catatanTambahan,
      fotoAnalisaUrls: fotoAnalisaUrls ?? this.fotoAnalisaUrls,
      estimasiWaktuPerbaikanHari:
          estimasiWaktuPerbaikanHari ?? this.estimasiWaktuPerbaikanHari,
      estimasiBiaya: estimasiBiaya ?? this.estimasiBiaya,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'laporan_id': laporanId,
        'teknisi_id': teknisiId,
        'teknisi_name': teknisiName,
        'judul_laporan': judulLaporan,
        'lokasi_laporan': lokasiLaporan,
        'kategori_laporan': kategoriLaporan,
        'diagnosa_masalah': diagnosaMasalah,
        'komponen_rusak': komponenRusak,
        'kategori_kerusakan': kategoriKerusakan.value,
        'tingkat_kerusakan': tingkatKerusakan.value,
        'tindakan_direkomendasikan': tindakanDirekomendasikan,
        'catatan_tambahan': catatanTambahan,
        'foto_analisa_urls': fotoAnalisaUrls,
        'estimasi_waktu_perbaikan_hari': estimasiWaktuPerbaikanHari,
        'estimasi_biaya': estimasiBiaya,
        'syncStatus': syncStatus,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}

// ── Enums ─────────────────────────────────────────────────────────────────────

enum KategoriKerusakan {
  hardware('hardware', 'Hardware'),
  software('software', 'Software'),
  jaringan('jaringan', 'Jaringan'),
  instalasi('instalasi', 'Instalasi'),
  lainnya('lainnya', 'Lainnya');

  final String value;
  final String label;
  const KategoriKerusakan(this.value, this.label);
}

enum TingkatKerusakan {
  ringan('ringan', 'Ringan', 'Masih bisa digunakan'),
  sedang('sedang', 'Sedang', 'Perlu perbaikan segera'),
  berat('berat', 'Berat', 'Tidak bisa digunakan'),
  total('total', 'Total Loss', 'Tidak bisa diperbaiki');

  final String value;
  final String label;
  final String deskripsi;
  const TingkatKerusakan(this.value, this.label, this.deskripsi);
}

// ── Dummy laporan yang bisa dianalisa (status in_progress) ───────────────────
// Sesuai struktur laporan_fasilitas dari Zidan

class LaporanSingkat {
  final String id;
  final String judul;
  final String lokasi;
  final String kategori;
  final String status;
  final String pelaporName;
  final DateTime createdAt;

  const LaporanSingkat({
    required this.id,
    required this.judul,
    required this.lokasi,
    required this.kategori,
    required this.status,
    required this.pelaporName,
    required this.createdAt,
  });
}

final List<LaporanSingkat> dummyLaporanAktif = [
  LaporanSingkat(
    id: 'lap-uuid-001',
    judul: 'AC Central Ruang Kelas 10A Mati',
    lokasi: 'Gedung B, Lt. 2, Ruang 10A',
    kategori: 'AC & Pendingin',
    status: 'in_progress',
    pelaporName: 'Budi Santoso',
    createdAt: DateTime.now().subtract(const Duration(hours: 5)),
  ),
  LaporanSingkat(
    id: 'lap-uuid-002',
    judul: 'Proyektor Lab Komputer Tidak Menyala',
    lokasi: 'Lab Komputer C, Gedung A',
    kategori: 'Proyektor',
    status: 'in_progress',
    pelaporName: 'Rina Sari',
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
  ),
  LaporanSingkat(
    id: 'lap-uuid-003',
    judul: 'Switch Jaringan Lantai 3 Tidak Responsif',
    lokasi: 'Gedung C, Lt. 3, Server Room',
    kategori: 'Jaringan',
    status: 'in_progress',
    pelaporName: 'Ahmad Fauzi',
    createdAt: DateTime.now().subtract(const Duration(hours: 3)),
  ),
  LaporanSingkat(
    id: 'lap-uuid-004',
    judul: 'PC Lab Rusak - Tidak Bisa Booting',
    lokasi: 'Lab Komputer D, Gedung B',
    kategori: 'PC & Komputer',
    status: 'in_progress',
    pelaporName: 'Dewi Putri',
    createdAt: DateTime.now().subtract(const Duration(hours: 8)),
  ),
];

// Dummy data analisa yang sudah dibuat
List<AnalisaKerusakanModel> dummyAnalisaList = [
  AnalisaKerusakanModel(
    id: 'analisa-uuid-001',
    laporanId: 'lap-uuid-002',
    teknisiId: 'user-t1',
    teknisiName: 'Budi Santoso',
    judulLaporan: 'Proyektor Lab Komputer Tidak Menyala',
    lokasiLaporan: 'Lab Komputer C, Gedung A',
    kategoriLaporan: 'Proyektor',
    diagnosaMasalah:
        'Lampu proyektor sudah melebihi batas jam penggunaan (3000 jam). Ballast rusak dan tidak dapat menyalakan lampu.',
    komponenRusak: 'Lampu proyektor, Ballast',
    kategoriKerusakan: KategoriKerusakan.hardware,
    tingkatKerusakan: TingkatKerusakan.berat,
    tindakanDirekomendasikan: 'Penggantian lampu dan ballast proyektor',
    estimasiWaktuPerbaikanHari: 3,
    estimasiBiaya: 1500000,
    syncStatus: 'local',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
];