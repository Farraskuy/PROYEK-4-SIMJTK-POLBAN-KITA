// --------------- ENUM STATUS LAPORAN ---------------
enum StatusLaporan { pending, assigned, inProgress, resolved, rejected }

extension StatusLaporanExt on StatusLaporan {
  String get label {
    switch (this) {
      case StatusLaporan.pending:
        return 'Menunggu';
      case StatusLaporan.assigned:
        return 'Ditugaskan';
      case StatusLaporan.inProgress:
        return 'Sedang Dikerjakan';
      case StatusLaporan.resolved:
        return 'Selesai';
      case StatusLaporan.rejected:
        return 'Ditolak';
    }
  }
}

// --------------- ENUM PRIORITAS ---------------
enum PrioritasLaporan { low, medium, high }

// --------------- ENUM SYNC STATUS ---------------
enum SyncStatus { local, synced }

// --------------- KATEGORI FASILITAS MODEL ---------------
class KategoriFasilitasModel {
  final String id;
  final String namaKategori;
  final String deskripsi;
  final String iconName; // Nama icon untuk UI

  const KategoriFasilitasModel({
    required this.id,
    required this.namaKategori,
    required this.deskripsi,
    required this.iconName,
  });

  /// Dummy data kategori berdasarkan dokumen pengajuan topik
  static List<KategoriFasilitasModel> dummyList() => const [
        KategoriFasilitasModel(
          id: 'kat-001',
          namaKategori: 'Jaringan Internet',
          deskripsi: 'Masalah koneksi WiFi atau LAN di area JTK',
          iconName: 'wifi',
        ),
        KategoriFasilitasModel(
          id: 'kat-002',
          namaKategori: 'Perangkat PC',
          deskripsi: 'Kerusakan komputer, monitor, keyboard, atau mouse',
          iconName: 'computer',
        ),
        KategoriFasilitasModel(
          id: 'kat-003',
          namaKategori: 'AC / Pendingin',
          deskripsi: 'AC mati atau tidak berfungsi dengan baik',
          iconName: 'ac_unit',
        ),
        KategoriFasilitasModel(
          id: 'kat-004',
          namaKategori: 'Kebersihan',
          deskripsi: 'Masalah kebersihan di lab atau ruang kelas',
          iconName: 'cleaning_services',
        ),
        KategoriFasilitasModel(
          id: 'kat-005',
          namaKategori: 'Furnitur',
          deskripsi: 'Kursi, meja, atau lemari rusak',
          iconName: 'chair',
        ),
        KategoriFasilitasModel(
          id: 'kat-006',
          namaKategori: 'Listrik & Proyektor',
          deskripsi: 'Masalah listrik, lampu padam, atau proyektor rusak',
          iconName: 'electrical_services',
        ),
        KategoriFasilitasModel(
          id: 'kat-007',
          namaKategori: 'Lainnya',
          deskripsi: 'Kerusakan fasilitas lain yang tidak tercantum di atas',
          iconName: 'build',
        ),
      ];
}

// --------------- LAPORAN FASILITAS MODEL ---------------
/// Model utama sesuai skema database di dokumen pengajuan topik
class LaporanFasilitasModel {
  final String id; // UUID v4
  final String judul;
  final String deskripsi;
  final String kategoriId; // FK ke KategoriFasilitas
  final String lokasiLabKelas;
  final String? nomorMejaPc; // Opsional
  final List<String> fotoUrls;
  final StatusLaporan status;
  final PrioritasLaporan? prioritas; // Ditentukan Admin saat pendelegasian
  final String pelaporId; // FK ke User
  final String? handlerId; // FK ke User (Teknisi), nullable
  final DateTime? estimasiSelesai; // Diinput Teknisi, nullable
  final SyncStatus syncStatus;
  final DateTime createdAt;
  final DateTime updatedAt;

  const LaporanFasilitasModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.kategoriId,
    required this.lokasiLabKelas,
    this.nomorMejaPc,
    required this.fotoUrls,
    required this.status,
    this.prioritas,
    required this.pelaporId,
    this.handlerId,
    this.estimasiSelesai,
    required this.syncStatus,
    required this.createdAt,
    required this.updatedAt,
  });
}

// --------------- FORM INPUT MODEL ---------------
/// Model sementara untuk menampung input form sebelum dikirim
class LaporanFasilitasFormInput {
  final KategoriFasilitasModel? kategori;
  final String lokasiLabKelas;
  final String nomorMejaPc;
  final String deskripsi;
  final List<String> fotoPaths; // Path lokal file foto

  const LaporanFasilitasFormInput({
    this.kategori,
    this.lokasiLabKelas = '',
    this.nomorMejaPc = '',
    this.deskripsi = '',
    this.fotoPaths = const [],
  });

  /// Cek apakah field wajib sudah terisi
  bool get isValid =>
      kategori != null &&
      lokasiLabKelas.trim().isNotEmpty &&
      deskripsi.trim().isNotEmpty;

  LaporanFasilitasFormInput copyWith({
    KategoriFasilitasModel? kategori,
    String? lokasiLabKelas,
    String? nomorMejaPc,
    String? deskripsi,
    List<String>? fotoPaths,
  }) {
    return LaporanFasilitasFormInput(
      kategori: kategori ?? this.kategori,
      lokasiLabKelas: lokasiLabKelas ?? this.lokasiLabKelas,
      nomorMejaPc: nomorMejaPc ?? this.nomorMejaPc,
      deskripsi: deskripsi ?? this.deskripsi,
      fotoPaths: fotoPaths ?? this.fotoPaths,
    );
  }
}

// --------------- HASIL SUBMIT MODEL ---------------
enum SubmitResult { success, failed, offline }

class SubmitLaporanResult {
  final SubmitResult result;
  final String message;
  final LaporanFasilitasModel? laporan;

  const SubmitLaporanResult({
    required this.result,
    required this.message,
    this.laporan,
  });
}