// Collection: usulan_penghapusan (MongoDB)

class PenghapusanItem {
  final String namaBarang;
  final String kondisiBarang;
  final String noInventaris;
  final String keterangan;

  PenghapusanItem({
    required this.namaBarang,
    required this.kondisiBarang,
    required this.noInventaris,
    required this.keterangan,
  });

  Map<String, dynamic> toJson() => {
    'nama_barang': namaBarang,
    'kondisi_barang': kondisiBarang,
    'no_inventaris': noInventaris,
    'keterangan': keterangan,
  };
}

class PenghapusanModel {
  final String id;
  final String teknisiId;
  final int? tahunUsulanPenghapusan; // ⚠️ Typed as Integer
  final int? tahunAnggaran;          // ⚠️ Typed as Integer
  final String pengelolaData;
  final List<PenghapusanItem> items;
  final String syncStatus;
  final DateTime createdAt;

  PenghapusanModel({
    required this.id,
    required this.teknisiId,
    required this.tahunUsulanPenghapusan,
    required this.tahunAnggaran,
    required this.pengelolaData,
    required this.items,
    this.syncStatus = 'synced',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    '_id': id,
    'teknisi_id': teknisiId,
    'tahun_usulan_penghapusan': tahunUsulanPenghapusan,
    'tahun_anggaran': tahunAnggaran,
    'pengelola_data': pengelolaData,
    'items': items.map((e) => e.toJson()).toList(),
    'sync_Status': syncStatus,
    'created_At': createdAt.toIso8601String(),
  };
}