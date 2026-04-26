// ============================================================
// FILE: modules/home/teknisi/tugas/model/daftar_tugas_model.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// Sesuai entitas Laporan_Fasilitas & Tindakan_Fasilitas di PDF
// ============================================================

// --------------- ENUM FILTER TAB ---------------
enum FilterTugas { semua, menunggu, diproses, selesai }

extension FilterTugasExt on FilterTugas {
  String get label {
    switch (this) {
      case FilterTugas.semua:
        return 'Semua';
      case FilterTugas.menunggu:
        return 'Menunggu';
      case FilterTugas.diproses:
        return 'Diproses';
      case FilterTugas.selesai:
        return 'Selesai';
    }
  }
}

// --------------- ENUM STATUS LAPORAN ---------------
/// Sesuai field status Laporan_Fasilitas di PDF
enum StatusLaporanTeknisi { pending, assigned, inProgress, resolved, rejected }

extension StatusLaporanTeknisiExt on StatusLaporanTeknisi {
  String get label {
    switch (this) {
      case StatusLaporanTeknisi.pending:
        return 'MENUNGGU';
      case StatusLaporanTeknisi.assigned:
        return 'MENUNGGU';
      case StatusLaporanTeknisi.inProgress:
        return 'DIPROSES';
      case StatusLaporanTeknisi.resolved:
        return 'SELESAI';
      case StatusLaporanTeknisi.rejected:
        return 'DITOLAK';
    }
  }

  /// Mapping ke FilterTugas untuk keperluan filter chip
  FilterTugas get filterGroup {
    switch (this) {
      case StatusLaporanTeknisi.pending:
      case StatusLaporanTeknisi.assigned:
        return FilterTugas.menunggu;
      case StatusLaporanTeknisi.inProgress:
        return FilterTugas.diproses;
      case StatusLaporanTeknisi.resolved:
        return FilterTugas.selesai;
      case StatusLaporanTeknisi.rejected:
        return FilterTugas.selesai;
    }
  }
}

// --------------- ENUM PRIORITAS ---------------
enum PrioritasLaporan { low, medium, high }

extension PrioritasLaporanExt on PrioritasLaporan {
  String get label {
    switch (this) {
      case PrioritasLaporan.low:
        return 'Low Priority';
      case PrioritasLaporan.medium:
        return 'Medium Priority';
      case PrioritasLaporan.high:
        return 'High Priority';
    }
  }
}

// --------------- ITEM TUGAS MODEL ---------------
/// Representasi satu laporan fasilitas yang didelegasikan
/// Sesuai skema Laporan_Fasilitas + join Kategori_Fasilitas di PDF
class ItemTugasModel {
  /// _id (UUID v4) — ditampilkan sebagai #REP-XXXX-XXX
  final String id;

  /// Nomor referensi yang tampil di UI
  final String nomorRef;

  /// judul laporan
  final String judul;

  /// lokasiLabKelas
  final String lokasi;

  /// namaKategori dari Kategori_Fasilitas
  final String kategori;

  /// status laporan (Enum sesuai PDF)
  final StatusLaporanTeknisi status;

  /// prioritas — ditentukan Admin saat delegasi (UC-06)
  final PrioritasLaporan prioritas;

  /// estimasiSelesai — bisa diinput teknisi (UC-07)
  final DateTime? estimasiSelesai;

  /// syncStatus — untuk offline-first sesuai PDF
  final bool isSynced;

  /// createdAt laporan asli
  final DateTime createdAt;

  /// updatedAt — terakhir diperbarui
  final DateTime updatedAt;

  const ItemTugasModel({
    required this.id,
    required this.nomorRef,
    required this.judul,
    required this.lokasi,
    required this.kategori,
    required this.status,
    required this.prioritas,
    this.estimasiSelesai,
    required this.isSynced,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Dummy data sesuai tampilan Figma + variasi data
  static List<ItemTugasModel> dummyList() {
    final now = DateTime.now();
    return [
      ItemTugasModel(
        id: 'lap-081',
        nomorRef: '#REP-2023-081',
        judul: 'Proyektor Berkedip & Mati Total',
        lokasi: 'Lab Komputer Dasar (Gedung A, Lt. 2)',
        kategori: 'Listrik & Proyektor',
        status: StatusLaporanTeknisi.assigned,
        prioritas: PrioritasLaporan.high,
        estimasiSelesai: now.copyWith(hour: 10, minute: 0),
        isSynced: true,
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 1)),
      ),
      ItemTugasModel(
        id: 'lap-085',
        nomorRef: '#REP-2023-085',
        judul: 'AC Bocor Meneteskan Air',
        lokasi: 'Ruang Rapat Dosen (Gedung B, Lt. 1)',
        kategori: 'AC / Pendingin',
        status: StatusLaporanTeknisi.inProgress,
        prioritas: PrioritasLaporan.high,
        estimasiSelesai: now.copyWith(hour: 13, minute: 30),
        isSynced: true,
        createdAt: now.subtract(const Duration(hours: 4)),
        updatedAt: now.subtract(const Duration(minutes: 30)),
      ),
      ItemTugasModel(
        id: 'lap-072',
        nomorRef: '#REP-2023-072',
        judul: 'Kabel Jaringan LAN Terputus',
        lokasi: 'Ruang Admin Jurusan',
        kategori: 'Jaringan Internet',
        status: StatusLaporanTeknisi.resolved,
        prioritas: PrioritasLaporan.medium,
        estimasiSelesai: now.copyWith(hour: 9, minute: 0),
        isSynced: true,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 3)),
      ),
      ItemTugasModel(
        id: 'lap-078',
        nomorRef: '#REP-2023-078',
        judul: 'PC Lab 4 Tidak Bisa Booting',
        lokasi: 'Lab Jaringan (Gedung A, Lt. 3)',
        kategori: 'Perangkat PC',
        status: StatusLaporanTeknisi.assigned,
        prioritas: PrioritasLaporan.medium,
        estimasiSelesai: now.copyWith(hour: 14, minute: 0),
        isSynced: false, // offline
        createdAt: now.subtract(const Duration(hours: 5)),
        updatedAt: now.subtract(const Duration(hours: 5)),
      ),
      ItemTugasModel(
        id: 'lap-069',
        nomorRef: '#REP-2023-069',
        judul: 'Lampu Ruang Kelas 305 Mati',
        lokasi: 'Ruang Kelas 305, Gedung C',
        kategori: 'Listrik & Proyektor',
        status: StatusLaporanTeknisi.resolved,
        prioritas: PrioritasLaporan.low,
        isSynced: true,
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 1)),
      ),
      ItemTugasModel(
        id: 'lap-090',
        nomorRef: '#REP-2023-090',
        judul: 'WiFi Area Selasar Tidak Terjangkau',
        lokasi: 'Selasar Gedung JTK, Lt. 1',
        kategori: 'Jaringan Internet',
        status: StatusLaporanTeknisi.inProgress,
        prioritas: PrioritasLaporan.high,
        estimasiSelesai: now.copyWith(hour: 16, minute: 0),
        isSynced: true,
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(minutes: 10)),
      ),
      ItemTugasModel(
        id: 'lap-063',
        nomorRef: '#REP-2023-063',
        judul: 'Kursi Lab Rusak Kaki Patah',
        lokasi: 'Lab Multimedia, Gedung B',
        kategori: 'Furnitur',
        status: StatusLaporanTeknisi.resolved,
        prioritas: PrioritasLaporan.low,
        isSynced: true,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}