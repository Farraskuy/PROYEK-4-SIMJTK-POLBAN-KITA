// Collection: data_kontrol_barang (MongoDB)

class SpesifikasiHardware {
  final String komponen; // Mainboard, Prosesor, dll
  final String nilai;
  SpesifikasiHardware({required this.komponen, required this.nilai});
  Map<String, dynamic> toJson() => {'komponen': komponen, 'nilai': nilai};
}

class PemeriksaanBerkalaItem {
  final String namaBarang;
  final String spesifikasi;
  final List<String> kondisiPerTanggal; // B/RR/RB per tanggal periksa
  final String keterangan;
  PemeriksaanBerkalaItem({required this.namaBarang, required this.spesifikasi, required this.kondisiPerTanggal, required this.keterangan});
  Map<String, dynamic> toJson() => {
    'nama_barang': namaBarang,
    'spesifikasi': spesifikasi,
    'kondisi_per_tanggal': kondisiPerTanggal,
    'keterangan': keterangan,
  };
}

class BiayaPerbaikanItem {
  final String komponenRusak;
  final String komponenPengganti;
  final String biayaPerbaikan;
  final String sumberDana;
  final String ditanganiOleh;
  BiayaPerbaikanItem({required this.komponenRusak, required this.komponenPengganti, required this.biayaPerbaikan, required this.sumberDana, required this.ditanganiOleh});
  Map<String, dynamic> toJson() => {
    'komponen_rusak': komponenRusak,
    'komponen_pengganti': komponenPengganti,
    'biaya_perbaikan': biayaPerbaikan,
    'sumber_dana': sumberDana,
    'ditangani_oleh': ditanganiOleh,
  };
}

class DataKontrolBarangModel {
  final String id;
  final String teknisiId;
  // Tabel A - Identitas
  final String namaRuangLab;
  final String namaBarangAlat;
  final String noInventaris;
  final String idKomputer;
  final String statusBarang;
  final String asalBarang;
  final String tahunPerolehan;
  final String prakiraanHarga;
  // Tabel B - Spesifikasi Hardware
  final List<SpesifikasiHardware> spesifikasiHardware;
  // Tabel C - Software
  final String operatingSystem;
  final List<String> aplikasi;
  // Tabel D - Pemeriksaan Berkala
  final List<PemeriksaanBerkalaItem> pemeriksaanBerkala;
  // Tabel F - Biaya Perbaikan
  final List<BiayaPerbaikanItem> biayaPerbaikan;
  final String syncStatus;
  final DateTime createdAt;

  DataKontrolBarangModel({
    required this.id,
    required this.teknisiId,
    required this.namaRuangLab,
    required this.namaBarangAlat,
    required this.noInventaris,
    required this.idKomputer,
    required this.statusBarang,
    required this.asalBarang,
    required this.tahunPerolehan,
    required this.prakiraanHarga,
    required this.spesifikasiHardware,
    required this.operatingSystem,
    required this.aplikasi,
    required this.pemeriksaanBerkala,
    required this.biayaPerbaikan,
    this.syncStatus = 'local',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    '_id': id,
    'teknisi_id': teknisiId,
    'nama_ruang_lab': namaRuangLab,
    'nama_barang_alat': namaBarangAlat,
    'no_inventaris': noInventaris,
    'id_komputer': idKomputer,
    'status_barang': statusBarang,
    'asal_barang': asalBarang,
    'tahun_perolehan': tahunPerolehan,
    'prakiraan_harga': prakiraanHarga,
    'spesifikasi_hardware': spesifikasiHardware.map((e) => e.toJson()).toList(),
    'operating_system': operatingSystem,
    'aplikasi': aplikasi,
    'pemeriksaan_berkala': pemeriksaanBerkala.map((e) => e.toJson()).toList(),
    'biaya_perbaikan': biayaPerbaikan.map((e) => e.toJson()).toList(),
    'syncStatus': syncStatus,
    'createdAt': createdAt.toIso8601String(),
  };
}