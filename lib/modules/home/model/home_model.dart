// --------------- USER MODEL ---------------
class UserModel {
  final String id;
  final String name;
  final String nimNip;
  final String email;
  final String role; // mahasiswa | staff | admin
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.name,
    required this.nimNip,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  /// Dummy data untuk keperluan prototype / low-fidelity
  factory UserModel.dummy() => const UserModel(
        id: 'usr-001',
        name: 'Budi',
        nimNip: '241511006',
        email: 'budi@student.polban.ac.id',
        role: 'mahasiswa',
        avatarUrl: null,
      );
}

// --------------- KALENDER AKADEMIK MODEL ---------------
enum KategoriAgenda { akademik, himpunan, umum, libur }
enum TipeKartuKalender { ujian, tugas, event }

class KalenderAkademikModel {
  final String id;
  final String tahunAjaran;
  final String semester; // Ganjil | Genap
  final String judulAgenda;
  final String deskripsi;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final KategoriAgenda kategoriAgenda;
  final TipeKartuKalender tipeKartu;

  const KalenderAkademikModel({
    required this.id,
    required this.tahunAjaran,
    required this.semester,
    required this.judulAgenda,
    required this.deskripsi,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.kategoriAgenda,
    required this.tipeKartu,
  });

  String get labelTipe {
    switch (tipeKartu) {
      case TipeKartuKalender.ujian:
        return 'Ujian';
      case TipeKartuKalender.tugas:
        return 'Tugas';
      case TipeKartuKalender.event:
        return 'Event';
    }
  }

  String get rentangTanggal {
    final bulan = [
      '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    if (tanggalMulai.month == tanggalSelesai.month &&
        tanggalMulai.year == tanggalSelesai.year) {
      return '${tanggalMulai.day} – ${tanggalSelesai.day} '
          '${bulan[tanggalMulai.month]} ${tanggalMulai.year}';
    }
    return '${tanggalMulai.day} ${bulan[tanggalMulai.month]} – '
        '${tanggalSelesai.day} ${bulan[tanggalSelesai.month]} ${tanggalSelesai.year}';
  }

  /// Dummy data
  static List<KalenderAkademikModel> dummyList() => [
        KalenderAkademikModel(
          id: 'kal-001',
          tahunAjaran: '2025/2026',
          semester: 'Ganjil',
          judulAgenda: 'UTS Semester Ganjil',
          deskripsi: 'Ujian Tengah Semester Ganjil 2025/2026',
          tanggalMulai: DateTime(2023, 10, 15),
          tanggalSelesai: DateTime(2023, 10, 20),
          kategoriAgenda: KategoriAgenda.akademik,
          tipeKartu: TipeKartuKalender.ujian,
        ),
        KalenderAkademikModel(
          id: 'kal-002',
          tahunAjaran: '2025/2026',
          semester: 'Ganjil',
          judulAgenda: 'Pengumpulan Laporan Proyek 4',
          deskripsi: 'Deadline pengumpulan laporan akhir Proyek 4',
          tanggalMulai: DateTime(2023, 10, 25),
          tanggalSelesai: DateTime(2023, 10, 25),
          kategoriAgenda: KategoriAgenda.akademik,
          tipeKartu: TipeKartuKalender.tugas,
        ),
        KalenderAkademikModel(
          id: 'kal-003',
          tahunAjaran: '2025/2026',
          semester: 'Ganjil',
          judulAgenda: 'Seminar Nasional Informatika',
          deskripsi: 'Seminar tahunan jurusan TKI POLBAN',
          tanggalMulai: DateTime(2023, 11, 5),
          tanggalSelesai: DateTime(2023, 11, 5),
          kategoriAgenda: KategoriAgenda.himpunan,
          tipeKartu: TipeKartuKalender.event,
        ),
      ];
}

// --------------- AKSES CEPAT MODEL ---------------
enum AksesCepatRoute {
  laporFasilitas,
  lostFound,
  beasiswa,
  suratKeterangan,
  izinLab,
  peminjamanRuang,
  jadwalKuliah,
  infoUkt,
}

class AksesCepatModel {
  final String label;
  final String iconAsset; // nama icon (untuk low-fi pakai Icons.*)
  final AksesCepatRoute route;

  const AksesCepatModel({
    required this.label,
    required this.iconAsset,
    required this.route,
  });

  static List<AksesCepatModel> dummyList() => const [
        AksesCepatModel(
          label: 'Lapor\nFasilitas',
          iconAsset: 'report',
          route: AksesCepatRoute.laporFasilitas,
        ),
        AksesCepatModel(
          label: 'Lost &\nFound',
          iconAsset: 'search',
          route: AksesCepatRoute.lostFound,
        ),
        AksesCepatModel(
          label: 'Beasiswa',
          iconAsset: 'school',
          route: AksesCepatRoute.beasiswa,
        ),
        AksesCepatModel(
          label: 'Surat\nKeterangan',
          iconAsset: 'description',
          route: AksesCepatRoute.suratKeterangan,
        ),
        AksesCepatModel(
          label: 'Izin Lab',
          iconAsset: 'science',
          route: AksesCepatRoute.izinLab,
        ),
        AksesCepatModel(
          label: 'Peminjaman\nRuang',
          iconAsset: 'meeting_room',
          route: AksesCepatRoute.peminjamanRuang,
        ),
        AksesCepatModel(
          label: 'Jadwal\nKuliah',
          iconAsset: 'calendar_month',
          route: AksesCepatRoute.jadwalKuliah,
        ),
        AksesCepatModel(
          label: 'Info UKT',
          iconAsset: 'receipt_long',
          route: AksesCepatRoute.infoUkt,
        ),
      ];
}

// --------------- ASPIRASI / SARAN MODEL ---------------
enum KategoriAspirasi { fasilitas, akademik, himpunan, umum }
enum StatusAspirasi { open, inReview, responded }

class AspirasiModel {
  final String id;
  final String topik;
  final String isiSaran;
  final bool isAnonymous;
  final String? pelaporId;
  final String? pelaporName;
  final int upvoteCount;
  final List<String> upvoterIds;
  final String? tanggapanJurusan;
  final StatusAspirasi status;
  final KategoriAspirasi kategori;
  final DateTime createdAt;

  const AspirasiModel({
    required this.id,
    required this.topik,
    required this.isiSaran,
    required this.isAnonymous,
    this.pelaporId,
    this.pelaporName,
    required this.upvoteCount,
    required this.upvoterIds,
    this.tanggapanJurusan,
    required this.status,
    required this.kategori,
    required this.createdAt,
  });

  String get labelKategori {
    switch (kategori) {
      case KategoriAspirasi.fasilitas:
        return 'FASILITAS';
      case KategoriAspirasi.akademik:
        return 'AKADEMIK';
      case KategoriAspirasi.himpunan:
        return 'HIMPUNAN';
      case KategoriAspirasi.umum:
        return 'UMUM';
    }
  }

  String get waktuRelatif {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    return '${diff.inDays} hari yang lalu';
  }

  static List<AspirasiModel> dummyList() => [
        AspirasiModel(
          id: 'asp-001',
          topik: 'AC di Ruang Kelas 302 Rusak',
          isiSaran:
              'Mohon segera diperbaiki karena mengganggu kenyamanan belajar...',
          isAnonymous: false,
          pelaporId: 'usr-002',
          pelaporName: 'Andi',
          upvoteCount: 124,
          upvoterIds: [],
          status: StatusAspirasi.open,
          kategori: KategoriAspirasi.fasilitas,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        AspirasiModel(
          id: 'asp-002',
          topik: 'Jadwal Praktikum Bentrok',
          isiSaran:
              'Terdapat bentrok jadwal antara praktikum Jaringan Komputer dan...',
          isAnonymous: false,
          pelaporId: 'usr-003',
          pelaporName: 'Rina',
          upvoteCount: 89,
          upvoterIds: [],
          status: StatusAspirasi.inReview,
          kategori: KategoriAspirasi.akademik,
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        AspirasiModel(
          id: 'asp-003',
          topik: 'Parkiran Motor Kurang Luas',
          isiSaran:
              'Area parkiran motor tidak cukup menampung kendaraan mahasiswa...',
          isAnonymous: true,
          upvoteCount: 67,
          upvoterIds: [],
          status: StatusAspirasi.open,
          kategori: KategoriAspirasi.fasilitas,
          createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        ),
      ];
}

// --------------- BOTTOM NAV MODEL ---------------
class BottomNavItemModel {
  final String label;
  final String iconName;
  final int index;

  const BottomNavItemModel({
    required this.label,
    required this.iconName,
    required this.index,
  });

  static List<BottomNavItemModel> items() => const [
        BottomNavItemModel(label: 'Home', iconName: 'home', index: 0),
        BottomNavItemModel(label: 'Layanan', iconName: 'grid_view', index: 1),
        BottomNavItemModel(label: 'Aspirasi', iconName: 'campaign', index: 2),
        BottomNavItemModel(label: 'Profil', iconName: 'person', index: 3),
      ];
}