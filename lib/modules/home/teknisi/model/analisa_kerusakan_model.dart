// lib/modules/teknisi/analisa_kerusakan/model/analisa_kerusakan_model.dart

class AnalisaKerusakanModel {
  final String id; // UUIDv4
  final String laporanId; // Reference ke laporan_fasilitas._id
  final String teknisiId; // Reference ke users._id
  final String teknisiName;

  // ── Identitas Alat (sesuai Formulir POLBAN) ───────────────────────────────
  final DasarPemeriksaan dasarPemeriksaan; // Pemeriksaan Berkala / Keluhan Pemakai
  final String namaAlat;       // Nama Alat
  final String kodeAlat;       // Kode Alat
  final String noInventaris;   // No. Inventaris
  final String lokasi;         // Lokasi
  final String noKerusakan;    // No. Kerusakan

  // ── Isi Formulir ──────────────────────────────────────────────────────────
  final String analisaMasalah;           // Analisa Masalah (diagnosa teknis)
  final String rekomendasiPerbaikan;     // Rekomendasi Perbaikan
  final String rekomendasiTempatPerbaikan; // Rekomendasi Tempat Perbaikan

  // ── Field tambahan (internal / display) ──────────────────────────────────
  final String judulLaporan;     // denormalized dari laporan
  final String kategoriLaporan;
  final KategoriKerusakan kategoriKerusakan;
  final TingkatKerusakan tingkatKerusakan;
  final List<String> fotoAnalisaUrls;
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
    required this.dasarPemeriksaan,
    required this.namaAlat,
    required this.kodeAlat,
    required this.noInventaris,
    required this.lokasi,
    required this.noKerusakan,
    required this.analisaMasalah,
    required this.rekomendasiPerbaikan,
    required this.rekomendasiTempatPerbaikan,
    required this.judulLaporan,
    required this.kategoriLaporan,
    required this.kategoriKerusakan,
    required this.tingkatKerusakan,
    this.fotoAnalisaUrls = const [],
    this.estimasiWaktuPerbaikanHari,
    this.estimasiBiaya,
    this.syncStatus = 'local',
    required this.createdAt,
    required this.updatedAt,
  });

  AnalisaKerusakanModel copyWith({
    DasarPemeriksaan? dasarPemeriksaan,
    String? namaAlat,
    String? kodeAlat,
    String? noInventaris,
    String? lokasi,
    String? noKerusakan,
    String? analisaMasalah,
    String? rekomendasiPerbaikan,
    String? rekomendasiTempatPerbaikan,
    KategoriKerusakan? kategoriKerusakan,
    TingkatKerusakan? tingkatKerusakan,
    List<String>? fotoAnalisaUrls,
    int? estimasiWaktuPerbaikanHari,
    double? estimasiBiaya,
    String? syncStatus,
    DateTime? updatedAt,
  }) {
    return AnalisaKerusakanModel(
      id: id,
      laporanId: laporanId,
      teknisiId: teknisiId,
      teknisiName: teknisiName,
      judulLaporan: judulLaporan,
      kategoriLaporan: kategoriLaporan,
      dasarPemeriksaan: dasarPemeriksaan ?? this.dasarPemeriksaan,
      namaAlat: namaAlat ?? this.namaAlat,
      kodeAlat: kodeAlat ?? this.kodeAlat,
      noInventaris: noInventaris ?? this.noInventaris,
      lokasi: lokasi ?? this.lokasi,
      noKerusakan: noKerusakan ?? this.noKerusakan,
      analisaMasalah: analisaMasalah ?? this.analisaMasalah,
      rekomendasiPerbaikan: rekomendasiPerbaikan ?? this.rekomendasiPerbaikan,
      rekomendasiTempatPerbaikan:
          rekomendasiTempatPerbaikan ?? this.rekomendasiTempatPerbaikan,
      kategoriKerusakan: kategoriKerusakan ?? this.kategoriKerusakan,
      tingkatKerusakan: tingkatKerusakan ?? this.tingkatKerusakan,
      fotoAnalisaUrls: fotoAnalisaUrls ?? this.fotoAnalisaUrls,
      estimasiWaktuPerbaikanHari:
          estimasiWaktuPerbaikanHari ?? this.estimasiWaktuPerbaikanHari,
      estimasiBiaya: estimasiBiaya ?? this.estimasiBiaya,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'laporan_id': laporanId,
        'teknisi_id': teknisiId,
        'teknisi_name': teknisiName,
        'judul_laporan': judulLaporan,
        'kategori_laporan': kategoriLaporan,
        'dasar_pemeriksaan': dasarPemeriksaan.value,
        'nama_alat': namaAlat,
        'kode_alat': kodeAlat,
        'no_inventaris': noInventaris,
        'lokasi': lokasi,
        'no_kerusakan': noKerusakan,
        'analisa_masalah': analisaMasalah,
        'rekomendasi_perbaikan': rekomendasiPerbaikan,
        'rekomendasi_tempat_perbaikan': rekomendasiTempatPerbaikan,
        'kategori_kerusakan': kategoriKerusakan.value,
        'tingkat_kerusakan': tingkatKerusakan.value,
        'foto_analisa_urls': fotoAnalisaUrls,
        'estimasi_waktu_perbaikan_hari': estimasiWaktuPerbaikanHari,
        'estimasi_biaya': estimasiBiaya,
        'sync_status': syncStatus,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

// ── Enums ─────────────────────────────────────────────────────────────────────

enum DasarPemeriksaan {
  pemeriksaanBerkala('pemeriksaan_berkala', '1. Pemeriksaan Berkala'),
  keluhanPemakai('keluhan_pemakai', '2. Keluhan Pemakai');

  final String value;
  final String label;
  const DasarPemeriksaan(this.value, this.label);
}

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

// ── Dummy laporan aktif ───────────────────────────────────────────────────────

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

// ── Dummy analisa list ────────────────────────────────────────────────────────

List<AnalisaKerusakanModel> dummyAnalisaList = [
  AnalisaKerusakanModel(
    id: 'analisa-uuid-001',
    laporanId: 'lap-uuid-002',
    teknisiId: 'user-t1',
    teknisiName: 'Budi Santoso',
    judulLaporan: 'Proyektor Lab Komputer Tidak Menyala',
    kategoriLaporan: 'Proyektor',
    dasarPemeriksaan: DasarPemeriksaan.keluhanPemakai,
    namaAlat: 'Proyektor Epson EB-X41',
    kodeAlat: 'PRY-LAB-C-001',
    noInventaris: 'INV/2021/PRY/003',
    lokasi: 'Lab Komputer C, Gedung A',
    noKerusakan: 'KRS-2024-0042',
    analisaMasalah:
        'Lampu proyektor sudah melebihi batas jam penggunaan (3000 jam). '
        'Ballast rusak dan tidak dapat menyalakan lampu. '
        'Indikator lampu berkedip merah 3 kali yang menandakan umur lampu habis.',
    rekomendasiPerbaikan:
        'Penggantian lampu proyektor (part no. ELPLP88) dan ballast. '
        'Estimasi penggantian 3 hari kerja.',
    rekomendasiTempatPerbaikan:
        'Bengkel Teknik Komputer POLBAN / Authorized Service Center Epson Bandung.',
    kategoriKerusakan: KategoriKerusakan.hardware,
    tingkatKerusakan: TingkatKerusakan.berat,
    estimasiWaktuPerbaikanHari: 3,
    estimasiBiaya: 1500000,
    syncStatus: 'local',
    createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
  ),
];