// ============================================================
// FILE: modules/admin/dashboard/model/admin_dashboard_model.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// Role: Admin JTK — dispatcher, moderator, statistik layanan
// Sesuai dokumen pengajuan topik Kelompok A7
// ============================================================

// --------------- ADMIN USER MODEL ---------------
class AdminUserModel {
  final String id;
  final String name;
  final String nimNip;
  final String email;
  final String role; // 'admin'
  final String? avatarUrl;

  const AdminUserModel({
    required this.id,
    required this.name,
    required this.nimNip,
    required this.email,
    required this.role,
    this.avatarUrl,
  });

  factory AdminUserModel.dummy() => const AdminUserModel(
        id: 'adm-001',
        name: 'Bapak Admin',
        nimNip: 'NIP-198501012010011001',
        email: 'admin@jtk.polban.ac.id',
        role: 'admin',
      );
}

// --------------- STATISTIK LAPORAN MODEL ---------------
/// Merepresentasikan data pantau statistik layanan oleh Admin
/// sesuai hak akses Admin di dokumen pengajuan topik
class StatistikLaporanModel {
  /// Total seluruh laporan fasilitas
  final int totalLaporan;

  /// Persentase perubahan dari bulan lalu (bisa negatif)
  final double persenDariBulanLalu;

  /// Laporan menunggu delegasi (status: pending)
  final int laporanPending;

  /// Laporan sedang dikerjakan teknisi (status: in_progress)
  final int laporanInProgress;

  /// Laporan selesai bulan ini (status: resolved)
  final int laporanResolved;

  /// Laporan ditolak (status: rejected)
  final int laporanRejected;

  const StatistikLaporanModel({
    required this.totalLaporan,
    required this.persenDariBulanLalu,
    required this.laporanPending,
    required this.laporanInProgress,
    required this.laporanResolved,
    required this.laporanRejected,
  });

  /// Persentase teks dengan tanda + / -
  String get persenLabel {
    final sign = persenDariBulanLalu >= 0 ? '+' : '';
    return '$sign${persenDariBulanLalu.toStringAsFixed(0)}% dari bulan lalu';
  }

  bool get isPositif => persenDariBulanLalu >= 0;

  factory StatistikLaporanModel.dummy() => const StatistikLaporanModel(
        totalLaporan: 1248,
        persenDariBulanLalu: 12,
        laporanPending: 24,
        laporanInProgress: 37,
        laporanResolved: 1165,
        laporanRejected: 22,
      );
}

// --------------- STATISTIK RINGKASAN MODEL ---------------
/// Dua kartu kecil di bawah kartu utama
class StatistikRingkasanModel {
  /// Jumlah staff / teknisi yang aktif (isActive: true)
  final int teknisiAktif;

  /// Saran/masukan dengan status open / in_review yang belum direspons
  final int aspirasiTertunda;

  /// Lost & Found menunggu moderasi admin (status: waiting_approval)
  final int lostFoundTertunda;

  /// Kalender akademik — agenda bulan ini
  final int agendaBulanIni;

  const StatistikRingkasanModel({
    required this.teknisiAktif,
    required this.aspirasiTertunda,
    required this.lostFoundTertunda,
    required this.agendaBulanIni,
  });

  factory StatistikRingkasanModel.dummy() => const StatistikRingkasanModel(
        teknisiAktif: 42,
        aspirasiTertunda: 18,
        lostFoundTertunda: 7,
        agendaBulanIni: 5,
      );
}

// --------------- AKTIVITAS TERBARU MODEL ---------------
enum TipeAktivitas {
  perbaikan,      // Teknisi selesai — dari Tindakan_Fasilitas
  laporanBaru,    // Mahasiswa buat laporan baru — dari Laporan_Fasilitas
  aspirasiBaru,   // Mahasiswa kirim aspirasi — dari Saran_Masukan
  lostFound,      // Barang ditemukan/hilang — dari Lost & Found
  delegasi,       // Admin mendelegasikan laporan ke teknisi
}

extension TipeAktivitasExt on TipeAktivitas {
  String get label {
    switch (this) {
      case TipeAktivitas.perbaikan:
        return 'PERBAIKAN';
      case TipeAktivitas.laporanBaru:
        return 'LAPORAN BARU';
      case TipeAktivitas.aspirasiBaru:
        return 'ASPIRASI';
      case TipeAktivitas.lostFound:
        return 'LOST & FOUND';
      case TipeAktivitas.delegasi:
        return 'DELEGASI';
    }
  }
}

class AktivitasTerbaruModel {
  final String id;

  /// Tipe aktivitas untuk menentukan ikon & warna
  final TipeAktivitas tipe;

  /// Judul singkat aktivitas
  final String judul;

  /// Deskripsi singkat
  final String deskripsi;

  /// Waktu kejadian
  final DateTime timestamp;

  /// ID referensi entitas terkait (untuk deep-link)
  /// Sesuai field targetId pada entitas Notifikasi di PDF
  final String? targetId;

  const AktivitasTerbaruModel({
    required this.id,
    required this.tipe,
    required this.judul,
    required this.deskripsi,
    required this.timestamp,
    this.targetId,
  });

  /// Format jam HH:MM
  String get jamLabel {
    final h = timestamp.hour.toString().padLeft(2, '0');
    final m = timestamp.minute.toString().padLeft(2, '0');
    return '$h:$m AM';
  }

  static List<AktivitasTerbaruModel> dummyList() {
    final now = DateTime.now();
    return [
      AktivitasTerbaruModel(
        id: 'akt-001',
        tipe: TipeAktivitas.perbaikan,
        judul: 'AC Ruang 302 Selesai',
        deskripsi: 'Teknisi Budi telah menyelesaikan tugas.',
        timestamp: now.copyWith(hour: 10, minute: 42),
        targetId: 'lap-001',
      ),
      AktivitasTerbaruModel(
        id: 'akt-002',
        tipe: TipeAktivitas.laporanBaru,
        judul: 'Proyektor Rusak',
        deskripsi: 'Dilaporkan di Aula Utama.',
        timestamp: now.copyWith(hour: 9, minute: 15),
        targetId: 'lap-002',
      ),
      AktivitasTerbaruModel(
        id: 'akt-003',
        tipe: TipeAktivitas.aspirasiBaru,
        judul: 'Aspirasi Baru Masuk',
        deskripsi: 'Penambahan dispenser air minum di Gedung B.',
        timestamp: now.copyWith(hour: 8, minute: 50),
        targetId: 'asp-001',
      ),
      AktivitasTerbaruModel(
        id: 'akt-004',
        tipe: TipeAktivitas.lostFound,
        judul: 'Kunci Motor Ditemukan',
        deskripsi: 'Menunggu moderasi di selasar Gedung JTK.',
        timestamp: now.copyWith(hour: 8, minute: 20),
        targetId: 'lf-001',
      ),
      AktivitasTerbaruModel(
        id: 'akt-005',
        tipe: TipeAktivitas.delegasi,
        judul: 'Laporan Didelegasikan',
        deskripsi: 'PC Lab 3 Mati → Teknisi Andi (Hardware).',
        timestamp: now.copyWith(hour: 7, minute: 55),
        targetId: 'lap-003',
      ),
    ];
  }
}

// --------------- TINDAKAN CEPAT MODEL ---------------
enum TindakanCepatType { tugaskan, siarkan, moderasi, tambahAgenda }

class TindakanCepatModel {
  final String label;
  final TindakanCepatType type;
  final String iconName;

  const TindakanCepatModel({
    required this.label,
    required this.type,
    required this.iconName,
  });

  static List<TindakanCepatModel> list() => const [
        TindakanCepatModel(
          label: 'Tugaskan',
          type: TindakanCepatType.tugaskan,
          iconName: 'assignment_ind',
        ),
        TindakanCepatModel(
          label: 'Siarkan',
          type: TindakanCepatType.siarkan,
          iconName: 'campaign',
        ),
        TindakanCepatModel(
          label: 'Moderasi',
          type: TindakanCepatType.moderasi,
          iconName: 'verified_user',
        ),
        TindakanCepatModel(
          label: 'Tambah\nAgenda',
          type: TindakanCepatType.tambahAgenda,
          iconName: 'calendar_add_on',
        ),
      ];
}

// --------------- BOTTOM NAV ADMIN MODEL ---------------
class AdminNavItemModel {
  final String label;
  final String iconName;
  final int index;

  const AdminNavItemModel({
    required this.label,
    required this.iconName,
    required this.index,
  });

  static List<AdminNavItemModel> items() => const [
        AdminNavItemModel(label: 'DASHBOARD', iconName: 'dashboard', index: 0),
        AdminNavItemModel(label: 'FACILITIES', iconName: 'apartment', index: 1),
        AdminNavItemModel(label: 'ASPIRATIONS', iconName: 'campaign', index: 2),
        AdminNavItemModel(label: 'USERS', iconName: 'group', index: 3),
      ];
}