// lib/modules/teknisi/analisa_kerusakan/model/analisa_kerusakan_model.dart

class AnalisaKerusakanModel {
  final String id; // Di-mapping dari '_id' MongoDB
  final String laporanId;
  final String teknisiId;
  final String teknisiName;

  // ── Identitas Alat ──────────────────────────────────────────────
  final DasarPemeriksaan dasarPemeriksaan;
  final String namaAlat;
  final String kodeAlat;
  final String noInventaris;
  final String lokasi;
  final String noKerusakan;

  // ── Isi Formulir ────────────────────────────────────────────────
  final String analisaMasalah;
  final String rekomendasiPerbaikan;
  final String rekomendasiTempatPerbaikan;

  // ── Field tambahan ─────────────────────────────────────────────
  final String judulLaporan;
  final String kategoriLaporan;
  final KategoriKerusakan kategoriKerusakan;
  final TingkatKerusakan tingkatKerusakan;
  final List<String> fotoAnalisaUrls;
  final int? estimasiWaktuPerbaikanHari;
  final double? estimasiBiaya;

  final String syncStatus;
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

  // ─── CONSTRUCTOR DARI MONGODB (JSON / MAP) ──────────────────────
  factory AnalisaKerusakanModel.fromJson(Map<String, dynamic> json) {
    // Helper function untuk parsing enum dengan aman (fallback jika null/salah)
    DasarPemeriksaan getDasar(String? val) => DasarPemeriksaan.values.firstWhere(
        (e) => e.value == val, orElse: () => DasarPemeriksaan.keluhanPemakai);
        
    KategoriKerusakan getKategori(String? val) => KategoriKerusakan.values.firstWhere(
        (e) => e.value == val, orElse: () => KategoriKerusakan.lainnya);
        
    TingkatKerusakan getTingkat(String? val) => TingkatKerusakan.values.firstWhere(
        (e) => e.value == val, orElse: () => TingkatKerusakan.sedang);

    // Helper untuk parsing DateTime (menangani format String ISO atau objek DateTime native dari Mongo)
    DateTime parseDate(dynamic dateData) {
      if (dateData == null) return DateTime.now();
      if (dateData is DateTime) return dateData;
      return DateTime.tryParse(dateData.toString()) ?? DateTime.now();
    }

    // Helper untuk angka (menghindari error casting int <-> double)
    double? parseBiaya(dynamic val) {
      if (val == null) return null;
      if (val is num) return val.toDouble();
      return double.tryParse(val.toString());
    }

    return AnalisaKerusakanModel(
      // MongoDB menggunakan field '_id', ObjectId akan dikonversi ke string
      id: json['_id']?.toString() ?? '', 
      laporanId: json['laporan_id'] ?? '',
      teknisiId: json['teknisi_id'] ?? '',
      teknisiName: json['teknisi_name'] ?? '',
      judulLaporan: json['judul_laporan'] ?? '',
      kategoriLaporan: json['kategori_laporan'] ?? '',
      dasarPemeriksaan: getDasar(json['dasar_pemeriksaan']),
      namaAlat: json['nama_alat'] ?? '',
      kodeAlat: json['kode_alat'] ?? '',
      noInventaris: json['no_inventaris'] ?? '',
      lokasi: json['lokasi'] ?? '',
      noKerusakan: json['no_kerusakan'] ?? '',
      analisaMasalah: json['analisa_masalah'] ?? '',
      rekomendasiPerbaikan: json['rekomendasi_perbaikan'] ?? '',
      rekomendasiTempatPerbaikan: json['rekomendasi_tempat_perbaikan'] ?? '',
      kategoriKerusakan: getKategori(json['kategori_kerusakan']),
      tingkatKerusakan: getTingkat(json['tingkat_kerusakan']),
      fotoAnalisaUrls: (json['foto_analisa_urls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ?? [],
      estimasiWaktuPerbaikanHari: json['estimasi_waktu_perbaikan_hari'] is int
          ? json['estimasi_waktu_perbaikan_hari']
          : int.tryParse(json['estimasi_waktu_perbaikan_hari']?.toString() ?? ''),
      estimasiBiaya: parseBiaya(json['estimasi_biaya']),
      syncStatus: json['sync_status'] ?? 'synced',
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  // ─── METHOD EXPORT KE MONGODB (JSON / MAP) ──────────────────────
  // Diubah namanya menjadi toMap() agar konsisten dengan panggilan di Service
  Map<String, dynamic> toMap() => {
        // Jangan paksa kirim string kosong ke _id, biarkan Mongo meng-generate-nya
        if (id.isNotEmpty) '_id': id,
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
        // mongo_dart native menangani objek DateTime, tidak perlu toIso8601String() 
        // kecuali Anda menggunakan REST API (seperti Dio/Http). 
        // Mengirim native DateTime membuat sorting query di Mongo jauh lebih cepat.
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

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