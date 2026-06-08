enum StatusAspirasi { open, inReview, responded }

extension StatusAspirasiExt on StatusAspirasi {
  String get label {
    switch (this) {
      case StatusAspirasi.open:
        return 'Terbuka';
      case StatusAspirasi.inReview:
        return 'Diproses';
      case StatusAspirasi.responded:
        return 'Selesai';
    }
  }

  // Warna badge status
  bool get isSelesai => this == StatusAspirasi.responded;
  bool get isProses => this == StatusAspirasi.inReview;
}

// --------------- ENUM KATEGORI ---------------
enum KategoriAspirasi { fasilitas, akademik, himpunan, umum }

extension KategoriAspirasiExt on KategoriAspirasi {
  String get label {
    switch (this) {
      case KategoriAspirasi.fasilitas:
        return 'Fasilitas';
      case KategoriAspirasi.akademik:
        return 'Akademik';
      case KategoriAspirasi.himpunan:
        return 'Himpunan';
      case KategoriAspirasi.umum:
        return 'Umum';
    }
  }
}

// --------------- ENUM TAB FILTER ---------------
enum TabAspirasi { terbaru, terpopuler, selesai }

extension TabAspirasiExt on TabAspirasi {
  String get label {
    switch (this) {
      case TabAspirasi.terbaru:
        return 'Terbaru';
      case TabAspirasi.terpopuler:
        return 'Terpopuler';
      case TabAspirasi.selesai:
        return 'Selesai';
    }
  }
}

// --------------- MAIN MODEL (sesuai skema DB di PDF) ---------------
class AspirasiModel {
  /// _id (String, PK)
  final String id;

  /// topik (String)
  final String topik;

  /// isiSaran (String)
  final String isiSaran;

  /// pelaporId (String, Nullable, FK ke User)
  final String? pelaporId;

  /// Nama pelapor — di-join dari User untuk tampilan
  final String pelaporName;

  /// Program studi pelapor — untuk tampilan di card
  final String? pelaporProdi;

  /// upvoteCount (Integer) — total akumulasi dukungan
  final int upvoteCount;

  /// downvoteCount — tambahan fitur
  final int downvoteCount;

  /// upvoterIds (`List<String>`) — agar tidak bisa double vote
  final List<String> upvoterIds;

  /// downvoterIds (`List<String>`)
  final List<String> downvoterIds;

  /// tanggapanJurusan (String, Nullable) — balasan resmi Admin
  final String? tanggapanJurusan;

  /// status (Enum: open, in_review, responded)
  final StatusAspirasi status;

  /// kategori aspirasi
  final KategoriAspirasi kategori;

  /// sync status (local, pending, synced, deleted)
  final String syncStatus;

  /// createdAt (DateTime)
  final DateTime createdAt;

  const AspirasiModel({
    required this.id,
    required this.topik,
    required this.isiSaran,
    this.pelaporId,
    required this.pelaporName,
    this.pelaporProdi,
    required this.upvoteCount,
    this.downvoteCount = 0,
    required this.upvoterIds,
    this.downvoterIds = const [],
    this.tanggapanJurusan,
    required this.status,
    required this.kategori,
    this.syncStatus = 'synced',
    required this.createdAt,
  });

  // ---- HELPERS ----

  /// Inisial nama untuk avatar
  String get initials {
    if (pelaporName == null) return '?';
    final parts = pelaporName!.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return pelaporName![0].toUpperCase();
  }

  /// Waktu relatif sejak dibuat
  String get waktuRelatif {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 30) return '${diff.inDays} hari lalu';
    return '${(diff.inDays / 30).floor()} bulan lalu';
  }

  /// Skor net vote (upvote - downvote)
  int get netVote => upvoteCount - downvoteCount;

  /// CopyWith untuk update immutable
  AspirasiModel copyWith({
    String? topik,
    String? isiSaran,
    int? upvoteCount,
    int? downvoteCount,
    List<String>? upvoterIds,
    List<String>? downvoterIds,
    String? tanggapanJurusan,
    StatusAspirasi? status,
    String? syncStatus,
  }) {
    return AspirasiModel(
      id: id,
      topik: topik ?? this.topik,
      isiSaran: isiSaran ?? this.isiSaran,
      pelaporId: pelaporId,
      pelaporName: pelaporName,
      pelaporProdi: pelaporProdi,
      upvoteCount: upvoteCount ?? this.upvoteCount,
      downvoteCount: downvoteCount ?? this.downvoteCount,
      upvoterIds: upvoterIds ?? this.upvoterIds,
      downvoterIds: downvoterIds ?? this.downvoterIds,
      tanggapanJurusan: tanggapanJurusan ?? this.tanggapanJurusan,
      status: status ?? this.status,
      kategori: kategori,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt,
    );
  }

  factory AspirasiModel.fromJson(Map<String, dynamic> json) {
    return AspirasiModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      topik: json['topik'] ?? '',
      isiSaran: json['isiSaran'] ?? '',
      pelaporId: json['pelaporId'],
      pelaporName: json['pelaporName'],
      pelaporProdi: json['pelaporProdi'],
      upvoteCount: json['upvoteCount'] ?? 0,
      downvoteCount: json['downvoteCount'] ?? 0,
      upvoterIds: List<String>.from(json['upvoterIds'] ?? []),
      downvoterIds: List<String>.from(json['downvoterIds'] ?? []),
      tanggapanJurusan: json['tanggapanJurusan'],
      status: StatusAspirasi.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => StatusAspirasi.open,
      ),
      kategori: KategoriAspirasi.values.firstWhere(
        (e) => e.name == json['kategori'],
        orElse: () => KategoriAspirasi.umum,
      ),
      syncStatus: (json['syncStatus'] ?? 'synced').toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'].toString())
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'topik': topik,
      'isiSaran': isiSaran,
      'pelaporId': pelaporId,
      'pelaporName': pelaporName,
      'pelaporProdi': pelaporProdi,
      'upvoteCount': upvoteCount,
      'downvoteCount': downvoteCount,
      'upvoterIds': upvoterIds,
      'downvoterIds': downvoterIds,
      'tanggapanJurusan': tanggapanJurusan,
      'status': status.name,
      'kategori': kategori.name,
      'syncStatus': syncStatus,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

// --------------- FORM INPUT MODEL ---------------
class AspirasiFormInput {
  final String judul;
  final String isiSaran;
  final KategoriAspirasi kategori;

  const AspirasiFormInput({
    this.judul = '',
    this.isiSaran = '',
    this.kategori = KategoriAspirasi.umum,
  });

  bool get isValid => judul.trim().length >= 5 && isiSaran.trim().length >= 20;

  AspirasiFormInput copyWith({
    String? judul,
    String? isiSaran,
    KategoriAspirasi? kategori,
  }) {
    return AspirasiFormInput(
      judul: judul ?? this.judul,
      isiSaran: isiSaran ?? this.isiSaran,
      kategori: kategori ?? this.kategori,
    );
  }
}
