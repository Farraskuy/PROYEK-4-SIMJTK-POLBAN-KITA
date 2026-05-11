// lib/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart

enum StatusLaporan {
  pending('pending', 'Menunggu Petugas'),
  in_progress('in_progress', 'Ditangani Petugas'),
  resolved('resolved', 'Selesai'),
  escalated_to_upt('escalated_to_upt', 'Diajukan ke TU'),
  waiting_disposal('waiting_disposal', 'Menunggu Cetak TU'),
  cancelled('cancelled', 'Dibatalkan');

  const StatusLaporan(this.value, this.label);
  final String value;
  final String label;

  static StatusLaporan fromValue(Object? value) {
    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'assigned') return StatusLaporan.in_progress;
    if (normalized == 'rejected') return StatusLaporan.cancelled;

    return StatusLaporan.values.firstWhere(
      (status) => status.value == normalized || status.name == normalized,
      orElse: () => StatusLaporan.pending,
    );
  }
}

class LaporanFasilitasModel {
  final String id;
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
  final String? catatanPetugas;
  final String? kebutuhanTu;
  final String? printedAt;
  final String? printedBy;

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
    this.catatanPetugas,
    this.kebutuhanTu,
    this.printedAt,
    this.printedBy,
  }) : status = StatusLaporan.fromValue(status);

  bool get diajukanKeTu =>
      status == StatusLaporan.escalated_to_upt ||
      status == StatusLaporan.waiting_disposal ||
      kebutuhanTu != null;

  bool get sudahDicetak => printedAt != null && printedAt!.isNotEmpty;

  factory LaporanFasilitasModel.fromJson(Map<String, dynamic> json) {
    return LaporanFasilitasModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      judul: (json['judul'] ?? '').toString(),
      deskripsi: (json['deskripsi'] ?? '').toString(),
      lokasi: (json['lokasi'] ?? json['lokasiLabKelas'] ?? '').toString(),
      foto_urls: List<String>.from(json['foto_urls'] ?? json['fotoUrls'] ?? []),
      pelapor_id: (json['pelapor_id'] ?? json['pelaporId'] ?? '').toString(),
      teknisi_id: json['teknisi_id']?.toString(),
      status: json['status'] ?? 'pending',
      vote_score: (json['vote_score'] ?? 0) as int,
      upvoter_ids: List<String>.from(json['upvoter_ids'] ?? []),
      downvoter_ids: List<String>.from(json['downvoter_ids'] ?? []),
      syncStatus: (json['syncStatus'] ?? 'synced').toString(),
      createdAt:
          DateTime.tryParse((json['createdAt'] ?? '').toString()) ??
          DateTime.now(),
      updatedAt:
          DateTime.tryParse((json['updatedAt'] ?? '').toString()) ??
          DateTime.now(),
      catatanPetugas: json['catatan_petugas']?.toString(),
      kebutuhanTu: json['kebutuhan_tu']?.toString(),
      printedAt: json['printedAt']?.toString(),
      printedBy: json['printedBy']?.toString(),
    );
  }

  LaporanFasilitasModel copyWith({
    String? judul,
    String? deskripsi,
    String? lokasi,
    List<String>? fotoUrls,
    String? pelaporId,
    String? teknisiId,
    Object? status,
    int? voteScore,
    List<String>? upvoterIds,
    List<String>? downvoterIds,
    String? syncStatus,
    DateTime? updatedAt,
    String? catatanPetugas,
    String? kebutuhanTu,
    String? printedAt,
    String? printedBy,
  }) {
    return LaporanFasilitasModel(
      id: id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      lokasi: lokasi ?? this.lokasi,
      foto_urls: fotoUrls ?? foto_urls,
      pelapor_id: pelaporId ?? pelapor_id,
      teknisi_id: teknisiId ?? teknisi_id,
      status: status ?? this.status,
      vote_score: voteScore ?? vote_score,
      upvoter_ids: upvoterIds ?? upvoter_ids,
      downvoter_ids: downvoterIds ?? downvoter_ids,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      catatanPetugas: catatanPetugas ?? this.catatanPetugas,
      kebutuhanTu: kebutuhanTu ?? this.kebutuhanTu,
      printedAt: printedAt ?? this.printedAt,
      printedBy: printedBy ?? this.printedBy,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'id': id,
    'judul': judul,
    'deskripsi': deskripsi,
    'lokasi': lokasi,
    'foto_urls': foto_urls,
    'pelapor_id': pelapor_id,
    'teknisi_id': teknisi_id,
    'status': status.value,
    'vote_score': vote_score,
    'upvoter_ids': upvoter_ids,
    'downvoter_ids': downvoter_ids,
    'syncStatus': syncStatus,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'catatan_petugas': catatanPetugas,
    'kebutuhan_tu': kebutuhanTu,
    'printedAt': printedAt,
    'printedBy': printedBy,
  };
}
