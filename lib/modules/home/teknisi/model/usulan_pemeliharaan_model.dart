// Collection: usulan_pemeliharaan (MongoDB)

class UsulanPemeliharaanItem {
  final String namaBarangAlat;
  final String spesifikasi;
  final String spesifikasiTeknis;
  final String tingkatKerusakan;
  final String volume;
  final String satuan;
  final String hargaSatuan;
  final String jumlah;

  UsulanPemeliharaanItem({
    required this.namaBarangAlat,
    required this.spesifikasi,
    required this.spesifikasiTeknis,
    required this.tingkatKerusakan,
    required this.volume,
    required this.satuan,
    required this.hargaSatuan,
    required this.jumlah,
  });

  Map<String, dynamic> toJson() => {
    'nama_barang_alat': namaBarangAlat,
    'spesifikasi': spesifikasi,
    'spesifikasi_teknis': spesifikasiTeknis,
    'tingkat_kerusakan': tingkatKerusakan,
    'volume': volume,
    'satuan': satuan,
    'harga_satuan': hargaSatuan,
    'jumlah': jumlah,
  };
}

class UsulanPemeliharaanModel {
  final String id;
  final String teknisiId;
  final String tahunUsulan;
  final String tahunAnggaran;
  final String pengelolaData;
  final List<UsulanPemeliharaanItem> items;
  final String syncStatus; // 'local' | 'synced'
  final DateTime createdAt;

  UsulanPemeliharaanModel({
    required this.id,
    required this.teknisiId,
    required this.tahunUsulan,
    required this.tahunAnggaran,
    required this.pengelolaData,
    required this.items,
    this.syncStatus = 'local',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    '_id': id,
    'teknisi_id': teknisiId,
    'tahun_usulan': tahunUsulan,
    'tahun_anggaran': tahunAnggaran,
    'pengelola_data': pengelolaData,
    'items': items.map((e) => e.toJson()).toList(),
    'syncStatus': syncStatus,
    'createdAt': createdAt.toIso8601String(),
  };
}