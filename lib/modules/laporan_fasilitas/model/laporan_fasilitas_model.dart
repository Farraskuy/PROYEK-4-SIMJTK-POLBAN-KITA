enum StatusLaporan {
  pending('pending', 'Menunggu'),
  assigned('assigned', 'Ditugaskan'),
  inProgress('in_progress', 'Sedang Dikerjakan'),
  resolved('resolved', 'Selesai'),
  rejected('rejected', 'Ditolak');

  const StatusLaporan(this.value, this.label);

  final String value;
  final String label;

  static StatusLaporan fromValue(Object? value) {
    final normalized = value.toString().trim().toLowerCase();
    return StatusLaporan.values.firstWhere(
      (status) => status.value == normalized || status.name == normalized,
      orElse: () => StatusLaporan.pending,
    );
  }
}

enum PrioritasLaporan {
  low('low'),
  medium('medium'),
  high('high');

  const PrioritasLaporan(this.value);

  final String value;

  static PrioritasLaporan fromValue(Object? value) {
    final normalized = value.toString().trim().toLowerCase();
    return PrioritasLaporan.values.firstWhere(
      (prioritas) =>
          prioritas.value == normalized || prioritas.name == normalized,
      orElse: () => PrioritasLaporan.medium,
    );
  }
}

enum SyncStatus {
  local('local'),
  synced('synced');

  const SyncStatus(this.value);

  final String value;

  static SyncStatus fromValue(Object? value) {
    final normalized = value.toString().trim().toLowerCase();
    return SyncStatus.values.firstWhere(
      (status) => status.value == normalized || status.name == normalized,
      orElse: () => SyncStatus.synced,
    );
  }
}

enum RoleUser { mahasiswa, staff, admin }

class KategoriFasilitasModel {
  final String id;
  final String namaKategori;
  final String deskripsi;
  final String iconUrl;

  const KategoriFasilitasModel({
    required this.id,
    required this.namaKategori,
    required this.deskripsi,
    required this.iconUrl,
  });

  String get iconName => iconUrl;

  static List<KategoriFasilitasModel> dummyList() => const [
    KategoriFasilitasModel(
      id: 'kat-001',
      namaKategori: 'Jaringan Internet',
      deskripsi: 'Masalah koneksi WiFi atau LAN di area JTK',
      iconUrl: 'wifi',
    ),
    KategoriFasilitasModel(
      id: 'kat-002',
      namaKategori: 'Perangkat PC',
      deskripsi: 'Kerusakan komputer, monitor, keyboard, atau mouse',
      iconUrl: 'computer',
    ),
    KategoriFasilitasModel(
      id: 'kat-003',
      namaKategori: 'AC / Pendingin',
      deskripsi: 'AC mati atau tidak berfungsi dengan baik',
      iconUrl: 'ac_unit',
    ),
    KategoriFasilitasModel(
      id: 'kat-004',
      namaKategori: 'Kebersihan',
      deskripsi: 'Masalah kebersihan di lab atau ruang kelas',
      iconUrl: 'cleaning_services',
    ),
    KategoriFasilitasModel(
      id: 'kat-005',
      namaKategori: 'Furnitur',
      deskripsi: 'Kursi, meja, atau lemari rusak',
      iconUrl: 'chair',
    ),
    KategoriFasilitasModel(
      id: 'kat-006',
      namaKategori: 'Listrik & Proyektor',
      deskripsi: 'Masalah listrik, lampu padam, atau proyektor rusak',
      iconUrl: 'electrical_services',
    ),
    KategoriFasilitasModel(
      id: 'kat-007',
      namaKategori: 'Lainnya',
      deskripsi: 'Kerusakan fasilitas lain yang tidak tercantum di atas',
      iconUrl: 'build',
    ),
  ];
}

class TindakanFasilitas {
  final String id;
  final String laporanId;
  final String aktorId;
  final String aktivitas;
  final String? catatanPengerjaan;
  final List<String>? fotoBuktiUrls;
  final DateTime timestamp;

  // Nama aktor hanya untuk kebutuhan tampilan sementara.
  final String? aktorNama;

  const TindakanFasilitas({
    required this.id,
    required this.laporanId,
    required this.aktorId,
    required this.aktivitas,
    this.catatanPengerjaan,
    this.fotoBuktiUrls,
    required this.timestamp,
    this.aktorNama,
  });
}

class LaporanFasilitasModel {
  final String id;
  final String judul;
  final String deskripsi;
  final String kategoriId;
  final String lokasiLabKelas;
  final List<String> fotoUrls;
  StatusLaporan status;
  PrioritasLaporan prioritas;
  final String pelaporId;
  String? handlerId;
  DateTime? estimasiSelesai;
  final SyncStatus syncStatus;
  final DateTime createdAt;
  DateTime updatedAt;
  final List<TindakanFasilitas> tindakan;

  // Field tampilan sementara sampai data relasi User/Kategori di-resolve.
  final String? namaKategori;
  final String? nomorMejaPc;
  final String? pelaporNama;
  String? handlerNama;

  LaporanFasilitasModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.kategoriId,
    required this.lokasiLabKelas,
    required this.fotoUrls,
    Object status = StatusLaporan.pending,
    Object? prioritas,
    required this.pelaporId,
    this.handlerId,
    this.estimasiSelesai,
    Object syncStatus = SyncStatus.synced,
    required this.createdAt,
    required this.updatedAt,
    List<TindakanFasilitas>? tindakan,
    List<TindakanFasilitas>? riwayat,
    this.namaKategori,
    this.nomorMejaPc,
    String? pelaporNama,
    String? pelaporName,
    String? handlerNama,
    String? handlerName,
  }) : status = StatusLaporan.fromValue(status),
       prioritas = PrioritasLaporan.fromValue(prioritas),
       syncStatus = SyncStatus.fromValue(syncStatus),
       tindakan = tindakan ?? riwayat ?? const [],
       pelaporNama = pelaporNama ?? pelaporName,
       handlerNama = handlerNama ?? handlerName;

  String get statusLabel => status.label;
  String get statusValue => status.value;
  String get prioritasValue => prioritas.value;
  List<TindakanFasilitas> get riwayat => tindakan;

  String get pelaporName => pelaporNama ?? pelaporId;
  String get pelaporDisplayName => pelaporNama ?? pelaporId;

  String? get handlerName => handlerNama;
  set handlerName(String? value) => handlerNama = value;
}

typedef LaporanFasilitas = LaporanFasilitasModel;

class LaporanFasilitasFormInput {
  final KategoriFasilitasModel? kategori;
  final String lokasiLabKelas;
  final String nomorMejaPc;
  final String deskripsi;
  final List<String> fotoPaths;

  const LaporanFasilitasFormInput({
    this.kategori,
    this.lokasiLabKelas = '',
    this.nomorMejaPc = '',
    this.deskripsi = '',
    this.fotoPaths = const [],
  });

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
