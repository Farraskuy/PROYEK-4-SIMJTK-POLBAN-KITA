// ============================================================
// FILE: modules/home/teknisi/model/home_teknisi_model.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// Role: Staff / Teknisi JTK
// Sesuai entitas Laporan_Fasilitas & Tindakan_Fasilitas di PDF
// ============================================================

// --------------- TEKNISI USER MODEL ---------------
class TeknisiUserModel {
  final String id;
  final String name;
  final String nimNip;
  final String email;
  final String role;         // 'staff'
  final String spesialisasi; // Teknisi Jaringan | Hardware | Umum
  final bool isActive;

  const TeknisiUserModel({
    required this.id,
    required this.name,
    required this.nimNip,
    required this.email,
    required this.role,
    required this.spesialisasi,
    required this.isActive,
  });

  factory TeknisiUserModel.dummy() => const TeknisiUserModel(
        id: 'stf-001',
        name: 'Budi',
        nimNip: 'NIP-199001012015041001',
        email: 'budi.teknisi@jtk.polban.ac.id',
        role: 'staff',
        spesialisasi: 'Teknisi Jaringan',
        isActive: true,
      );
}

// --------------- ENUM STATUS LAPORAN ---------------
/// Sesuai field status di entitas Laporan_Fasilitas di PDF
enum StatusTugas { pending, assigned, inProgress, resolved, rejected }

extension StatusTugasExt on StatusTugas {
  String get label {
    switch (this) {
      case StatusTugas.pending:
        return 'Pending';
      case StatusTugas.assigned:
        return 'Ditugaskan';
      case StatusTugas.inProgress:
        return 'Dikerjakan';
      case StatusTugas.resolved:
        return 'Selesai';
      case StatusTugas.rejected:
        return 'Ditolak';
    }
  }
}

// --------------- ENUM PRIORITAS ---------------
/// Sesuai field prioritas di entitas Laporan_Fasilitas di PDF
/// Ditentukan Admin saat pendelegasian (UC-06)
enum PrioritasTugas { low, medium, high }

extension PrioritasTugasExt on PrioritasTugas {
  String get label {
    switch (this) {
      case PrioritasTugas.low:
        return 'Low Priority';
      case PrioritasTugas.medium:
        return 'Medium Priority';
      case PrioritasTugas.high:
        return 'High Priority';
    }
  }

  String get labelShort {
    switch (this) {
      case PrioritasTugas.low:
        return 'Low';
      case PrioritasTugas.medium:
        return 'Medium';
      case PrioritasTugas.high:
        return 'High';
    }
  }
}

// --------------- STATISTIK TUGAS MODEL ---------------
class StatistikTugasModel {
  /// Total tugas yang didelegasikan ke teknisi ini
  final int totalTugas;

  /// Tugas selesai hari ini (status: resolved)
  final int tugasSelesai;

  /// Tugas belum dikerjakan (status: assigned / pending)
  final int tugasPending;

  /// Tugas sedang dikerjakan (status: in_progress)
  final int tugasInProgress;

  const StatistikTugasModel({
    required this.totalTugas,
    required this.tugasSelesai,
    required this.tugasPending,
    required this.tugasInProgress,
  });

  factory StatistikTugasModel.dummy() => const StatistikTugasModel(
        totalTugas: 12,
        tugasSelesai: 8,
        tugasPending: 4,
        tugasInProgress: 2,
      );
}

// --------------- TUGAS TEKNISI MODEL ---------------
/// Merepresentasikan Laporan_Fasilitas yang sudah didelegasikan
/// ke teknisi ini (UC-07: Mengelola Tindakan Teknisi)
class TugasTeknisiModel {
  /// _id dari Laporan_Fasilitas (UUID v4)
  final String id;

  /// judul laporan
  final String judul;

  /// lokasiLabKelas
  final String lokasi;

  /// kategori fasilitas (Jaringan, Hardware, AC, dll)
  final String kategori;

  /// prioritas — ditentukan Admin saat delegasi (UC-06)
  final PrioritasTugas prioritas;

  /// status pengerjaan saat ini
  final StatusTugas status;

  /// estimasiSelesai — dapat diinput teknisi (UC-07)
  final DateTime? estimasiSelesai;

  /// syncStatus — untuk offline-first
  final bool isSynced;

  /// createdAt laporan
  final DateTime createdAt;

  /// Apakah mendesak (high priority & belum selesai)
  bool get isMendesak =>
      prioritas == PrioritasTugas.high &&
      status != StatusTugas.resolved;

  /// Format jam estimasi selesai
  String get jamEstimasi {
    if (estimasiSelesai == null) return '-';
    final h = estimasiSelesai!.hour.toString().padLeft(2, '0');
    final m = estimasiSelesai!.minute.toString().padLeft(2, '0');
    return '$h:$m AM';
  }

  const TugasTeknisiModel({
    required this.id,
    required this.judul,
    required this.lokasi,
    required this.kategori,
    required this.prioritas,
    required this.status,
    this.estimasiSelesai,
    required this.isSynced,
    required this.createdAt,
  });

  static List<TugasTeknisiModel> dummyList() {
    final now = DateTime.now();
    return [
      TugasTeknisiModel(
        id: 'lap-001',
        judul: 'Perbaikan Server AC Area 3',
        lokasi: 'Lantai 5 Gedung Utama',
        kategori: 'AC / Pendingin',
        prioritas: PrioritasTugas.high,
        status: StatusTugas.assigned,
        estimasiSelesai: now.copyWith(hour: 9, minute: 0),
        isSynced: true,
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      TugasTeknisiModel(
        id: 'lap-002',
        judul: 'Pengecekan Jaringan Fiber',
        lokasi: 'Ruang Rapat Eksekutif',
        kategori: 'Jaringan Internet',
        prioritas: PrioritasTugas.medium,
        status: StatusTugas.inProgress,
        estimasiSelesai: now.copyWith(hour: 11, minute: 30),
        isSynced: true,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
      TugasTeknisiModel(
        id: 'lap-003',
        judul: 'PC Lab 3 Tidak Menyala',
        lokasi: 'Lab Komputer 3, Gedung A',
        kategori: 'Perangkat PC',
        prioritas: PrioritasTugas.high,
        status: StatusTugas.assigned,
        estimasiSelesai: now.copyWith(hour: 13, minute: 0),
        isSynced: false, // offline
        createdAt: now.subtract(const Duration(hours: 2)),
      ),
      TugasTeknisiModel(
        id: 'lap-004',
        judul: 'Kebersihan Lab Multimedia',
        lokasi: 'Lab Multimedia, Gedung B',
        kategori: 'Kebersihan',
        prioritas: PrioritasTugas.low,
        status: StatusTugas.assigned,
        estimasiSelesai: now.copyWith(hour: 15, minute: 0),
        isSynced: true,
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      TugasTeknisiModel(
        id: 'lap-005',
        judul: 'Proyektor Ruang 201 Rusak',
        lokasi: 'Ruang Kelas 201, Gedung C',
        kategori: 'Listrik & Proyektor',
        prioritas: PrioritasTugas.medium,
        status: StatusTugas.resolved,
        estimasiSelesai: now.copyWith(hour: 10, minute: 30),
        isSynced: true,
        createdAt: now.subtract(const Duration(hours: 5)),
      ),
    ];
  }

  /// Tugas yang mendesak saja (high priority, belum selesai)
  static List<TugasTeknisiModel> dummyMendesak() =>
      dummyList().where((t) => t.isMendesak).toList();
}

// --------------- BOTTOM NAV TEKNISI MODEL ---------------
class TeknisiNavItemModel {
  final String label;
  final int index;

  const TeknisiNavItemModel({required this.label, required this.index});

  static List<TeknisiNavItemModel> items() => const [
        TeknisiNavItemModel(label: 'BERANDA', index: 0),
        TeknisiNavItemModel(label: 'TUGAS', index: 1),
        TeknisiNavItemModel(label: 'RIWAYAT', index: 2),
        TeknisiNavItemModel(label: 'PROFIL', index: 3),
      ];
}