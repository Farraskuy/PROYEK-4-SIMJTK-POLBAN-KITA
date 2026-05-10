// lib/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart

enum StatusLaporan {
  pending('pending', 'Menunggu'),
  in_progress('in_progress', 'Sedang Dikerjakan'),
  resolved('resolved', 'Selesai'),
  escalated_to_upt('escalated_to_upt', 'Diteruskan ke UPT'),
  waiting_disposal('waiting_disposal', 'Menunggu Penghapusan'),
  cancelled('cancelled', 'Dibatalkan');

  const StatusLaporan(this.value, this.label);
  final String value;
  final String label;

  static StatusLaporan fromValue(Object? value) {
    final normalized = value.toString().trim().toLowerCase();
    // Kompatibilitas untuk kode lama (mapped ke status terdekat)
    if (normalized == 'assigned') return StatusLaporan.in_progress;
    if (normalized == 'rejected') return StatusLaporan.cancelled;

    return StatusLaporan.values.firstWhere(
      (status) => status.value == normalized || status.name == normalized,
      orElse: () => StatusLaporan.pending,
    );
  }
}

class LaporanFasilitasModel {
  final String id; // Mapping dari _id
  final String judul;
  final String deskripsi;
  final String lokasi;
  final List<String> foto_urls;
  final String pelapor_id;
  String? teknisi_id;
  StatusLaporan status;
  int vote_score;
  List<String> upvoter_ids;
  List<String> downvoter_ids;
  String syncStatus;
  final DateTime createdAt;
  DateTime updatedAt;

  // Alias getter agar View lama tidak error
  // String get lokasiLabKelas => lokasi; // Bakal di hapus/komentar nanti jika sudah migrasi total
  // List<String> get fotoUrls => foto_urls;

  LaporanFasilitasModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.lokasi,
    required this.foto_urls,
    required this.pelapor_id,
    this.teknisi_id,
    Object status = StatusLaporan.pending,
    this.vote_score = 0,
    this.upvoter_ids = const [],
    this.downvoter_ids = const [],
    this.syncStatus = 'synced',
    required this.createdAt,
    required this.updatedAt,
  }) : status = StatusLaporan.fromValue(status);

  factory LaporanFasilitasModel.fromJson(Map<String, dynamic> json) {
    return LaporanFasilitasModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      lokasi: json['lokasi'] ?? '',
      foto_urls: List<String>.from(json['foto_urls'] ?? []),
      pelapor_id: json['pelapor_id'] ?? '',
      teknisi_id: json['teknisi_id'],
      status: json['status'] ?? 'pending',
      vote_score: json['vote_score'] ?? 0,
      upvoter_ids: List<String>.from(json['upvoter_ids'] ?? []),
      downvoter_ids: List<String>.from(json['downvoter_ids'] ?? []),
      syncStatus: json['syncStatus'] ?? 'synced',
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Map<String, dynamic> toJson() => {
  //   '_id': id,
  //   'judul': judul,
  //   'deskripsi': deskripsi,
  //   'lokasi': lokasi,
  //   'foto_urls': foto_urls,
  //   'pelapor_id': pelapor_id,
  //   'teknisi_id': teknisi_id,
  //   'status': status.value,
  //   'vote_score': vote_score,
  //   'upvoter_ids': upvoter_ids,
  //   'downvoter_ids': downvoter_ids,
  //   'syncStatus': syncStatus,
  //   'createdAt': createdAt.toIso8601String(),
  //   'updatedAt': updatedAt.toIso8601String(),
  // };
  // Snippet di laporan_fasilitas_model.dart[cite: 8]
  Map<String, dynamic> toJson() => {
    '_id': id, // MongoDB butuh field _id[cite: 8]
    'judul': judul,
    'lokasi': lokasi,
    'foto_urls': foto_urls, // Gunakan snake_case sesuai skema Farras[cite: 8]
    'status': status.value,
    'vote_score': vote_score,
    // ... field lainnya
  };
}
