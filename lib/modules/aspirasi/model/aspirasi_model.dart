// ============================================================
// FILE: modules/aspirasi/model/aspirasi_model.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// Sesuai entitas Saran_Masukan dari dokumen pengajuan topik
// ============================================================

// --------------- ENUM STATUS ---------------
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
enum TabAspirasi { terbaru, terpopuler, diproses }

extension TabAspirasiExt on TabAspirasi {
  String get label {
    switch (this) {
      case TabAspirasi.terbaru:
        return 'Terbaru';
      case TabAspirasi.terpopuler:
        return 'Terpopuler';
      case TabAspirasi.diproses:
        return 'Diproses';
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

  /// isAnonymous (Boolean)
  final bool isAnonymous;

  /// pelaporId (String, Nullable, FK ke User)
  final String? pelaporId;

  /// Nama pelapor — di-join dari User untuk tampilan
  final String? pelaporName;

  /// Program studi pelapor — untuk tampilan di card
  final String? pelaporProdi;

  /// upvoteCount (Integer) — total akumulasi dukungan
  final int upvoteCount;

  /// downvoteCount — tambahan fitur
  final int downvoteCount;

  /// upvoterIds (List<String>) — agar tidak bisa double vote
  final List<String> upvoterIds;

  /// downvoterIds (List<String>)
  final List<String> downvoterIds;

  /// tanggapanJurusan (String, Nullable) — balasan resmi Admin
  final String? tanggapanJurusan;

  /// status (Enum: open, in_review, responded)
  final StatusAspirasi status;

  /// kategori aspirasi
  final KategoriAspirasi kategori;

  /// createdAt (DateTime)
  final DateTime createdAt;

  const AspirasiModel({
    required this.id,
    required this.topik,
    required this.isiSaran,
    required this.isAnonymous,
    this.pelaporId,
    this.pelaporName,
    this.pelaporProdi,
    required this.upvoteCount,
    this.downvoteCount = 0,
    required this.upvoterIds,
    this.downvoterIds = const [],
    this.tanggapanJurusan,
    required this.status,
    required this.kategori,
    required this.createdAt,
  });

  // ---- HELPERS ----

  /// Inisial nama untuk avatar
  String get initials {
    if (isAnonymous || pelaporName == null) return '?';
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
    bool? isAnonymous,
    int? upvoteCount,
    int? downvoteCount,
    List<String>? upvoterIds,
    List<String>? downvoterIds,
    String? tanggapanJurusan,
    StatusAspirasi? status,
  }) {
    return AspirasiModel(
      id: id,
      topik: topik ?? this.topik,
      isiSaran: isiSaran ?? this.isiSaran,
      isAnonymous: isAnonymous ?? this.isAnonymous,
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
      createdAt: createdAt,
    );
  }

  // ---- DUMMY DATA ----
  static List<AspirasiModel> dummyList() => [
        AspirasiModel(
          id: 'asp-001',
          topik: 'Penambahan Fasilitas Air Minum di Gedung Baru',
          isiSaran:
              'Mohon dipertimbangkan untuk menambahkan dispenser air minum di setiap lantai gedung perkuliahan baru. Saat ini mahasiswa kesulitan mencari air minum saat pergantian jam kuliah, terutama di lantai atas.',
          isAnonymous: false,
          pelaporId: 'usr-010',
          pelaporName: 'Ahmad Hidayat',
          pelaporProdi: 'D4 Teknik Informatika',
          upvoteCount: 128,
          downvoteCount: 3,
          upvoterIds: [],
          downvoterIds: [],
          tanggapanJurusan:
              'Terima kasih atas masukannya. Pengadaan dispenser air minum untuk gedung baru sedang dalam proses tender dan ditargetkan akan tersedia di setiap lantai pada awal semester ganjil mendatang.',
          status: StatusAspirasi.responded,
          kategori: KategoriAspirasi.fasilitas,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AspirasiModel(
          id: 'asp-002',
          topik: 'AC di Ruang Kelas 302 Rusak',
          isiSaran:
              'AC di ruang 302 sudah tidak berfungsi selama 2 minggu. Suasana ruangan sangat panas dan mengganggu konsentrasi belajar mahasiswa. Mohon segera diperbaiki.',
          isAnonymous: false,
          pelaporId: 'usr-002',
          pelaporName: 'Rina Sari',
          pelaporProdi: 'D3 Teknik Informatika',
          upvoteCount: 89,
          downvoteCount: 1,
          upvoterIds: [],
          downvoterIds: [],
          status: StatusAspirasi.inReview,
          kategori: KategoriAspirasi.fasilitas,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        AspirasiModel(
          id: 'asp-003',
          topik: 'Jadwal Praktikum Jaringan Komputer Bentrok',
          isiSaran:
              'Terdapat bentrok jadwal antara praktikum Jaringan Komputer dan mata kuliah Basis Data untuk mahasiswa kelas 2B. Mohon pihak jurusan meninjau ulang jadwal tersebut.',
          isAnonymous: false,
          pelaporId: 'usr-003',
          pelaporName: 'Budi Santoso',
          pelaporProdi: 'D3 Teknik Informatika',
          upvoteCount: 67,
          downvoteCount: 0,
          upvoterIds: [],
          downvoterIds: [],
          status: StatusAspirasi.inReview,
          kategori: KategoriAspirasi.akademik,
          createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        ),
        AspirasiModel(
          id: 'asp-004',
          topik: 'Parkiran Motor Kurang Luas',
          isiSaran:
              'Area parkiran motor di depan gedung JTK tidak cukup menampung kendaraan mahasiswa pada jam sibuk. Banyak motor terpaksa parkir di area yang tidak semestinya.',
          isAnonymous: true,
          upvoteCount: 54,
          downvoteCount: 2,
          upvoterIds: [],
          downvoterIds: [],
          status: StatusAspirasi.open,
          kategori: KategoriAspirasi.fasilitas,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        AspirasiModel(
          id: 'asp-005',
          topik: 'Perlu Ruang Diskusi Tambahan',
          isiSaran:
              'Mahasiswa sering kesulitan mendapatkan ruang untuk berdiskusi kelompok. Mohon disediakan ruang diskusi tambahan yang bisa digunakan secara bebas tanpa harus melalui proses peminjaman yang rumit.',
          isAnonymous: false,
          pelaporId: 'usr-005',
          pelaporName: 'Siti Nurhaliza',
          pelaporProdi: 'D4 Teknik Informatika',
          upvoteCount: 41,
          downvoteCount: 4,
          upvoterIds: [],
          downvoterIds: [],
          status: StatusAspirasi.open,
          kategori: KategoriAspirasi.fasilitas,
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ];
}

// --------------- FORM INPUT MODEL ---------------
class AspirasiFormInput {
  final String isiSaran;
  final bool isAnonymous;
  final KategoriAspirasi kategori;

  const AspirasiFormInput({
    this.isiSaran = '',
    this.isAnonymous = false,
    this.kategori = KategoriAspirasi.umum,
  });

  bool get isValid => isiSaran.trim().length >= 20;

  AspirasiFormInput copyWith({
    String? isiSaran,
    bool? isAnonymous,
    KategoriAspirasi? kategori,
  }) {
    return AspirasiFormInput(
      isiSaran: isiSaran ?? this.isiSaran,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      kategori: kategori ?? this.kategori,
    );
  }
}