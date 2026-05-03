import 'package:proyek_4_poki_polban_kita/modules/kategori_fasilitas/model/kategori_fasilitas_model.dart';

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

  factory LaporanFasilitasModel.fromJson(Map<String, dynamic> json) {
    final rawFotoUrls = json['foto_urls'] ?? json['fotoUrls'] ?? const <dynamic>[];
    final List<TindakanFasilitas> tindakanList = (json['tindakan'] as List<dynamic>?)
        ?.map((item) => tindakanFasilitasFromJson(
                  Map<String, dynamic>.from(item as Map),
                ))
            .toList() ??
        <TindakanFasilitas>[];

    return LaporanFasilitasModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      judul: (json['judul'] ?? '').toString(),
      deskripsi: (json['deskripsi'] ?? '').toString(),
      kategoriId: (json['kategori_id'] ?? json['kategoriId'] ?? '').toString(),
      lokasiLabKelas:
          (json['lokasi'] ?? json['lokasiLabKelas'] ?? '').toString(),
        fotoUrls: (rawFotoUrls as List<dynamic>)
          .map((value) => value.toString())
          .toList(),
      status: json['status'] ?? StatusLaporan.pending,
      prioritas: json['prioritas'],
      pelaporId: (json['pelapor_id'] ?? json['pelaporId'] ?? '').toString(),
      handlerId: (json['teknisi_id'] ?? json['handlerId'] ?? '').toString().trim().isEmpty
          ? null
          : (json['teknisi_id'] ?? json['handlerId']).toString(),
      estimasiSelesai: _parseDateTime(json['estimasi_selesai'] ?? json['estimasiSelesai']),
      syncStatus: json['syncStatus'] ?? json['sync_status'],
      createdAt: _parseDateTime(json['createdAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt: _parseDateTime(json['updatedAt']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      tindakan: tindakanList,
      namaKategori: (json['namaKategori'] ?? '').toString().isEmpty
          ? null
          : (json['namaKategori'] ?? '').toString(),
      nomorMejaPc: (json['nomorMejaPc'] ?? '').toString().isEmpty
          ? null
          : (json['nomorMejaPc'] ?? '').toString(),
      pelaporNama: (json['pelaporNama'] ?? '').toString().isEmpty
          ? null
          : (json['pelaporNama'] ?? '').toString(),
      handlerNama: (json['handlerNama'] ?? '').toString().isEmpty
          ? null
          : (json['handlerNama'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'kategori_id': kategoriId,
      'kategoriId': kategoriId,
      'lokasi': lokasiLabKelas,
      'lokasiLabKelas': lokasiLabKelas,
      'foto_urls': fotoUrls,
      'fotoUrls': fotoUrls,
      'status': status.value,
      'prioritas': prioritas.value,
      'pelapor_id': pelaporId,
      'pelaporId': pelaporId,
      'teknisi_id': handlerId,
      'handlerId': handlerId,
      'estimasi_selesai': estimasiSelesai?.toIso8601String(),
      'syncStatus': syncStatus.value,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'tindakan': tindakan.map((item) => item.toJson()).toList(),
      'namaKategori': namaKategori,
      'nomorMejaPc': nomorMejaPc,
      'pelaporNama': pelaporNama,
      'handlerNama': handlerNama,
    };
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value == null) {
      return null;
    }

    final text = value.toString().trim();
    if (text.isEmpty) {
      return null;
    }

    return DateTime.tryParse(text);
  }
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

TindakanFasilitas tindakanFasilitasFromJson(Map<String, dynamic> json) {
  return TindakanFasilitas(
    id: (json['_id'] ?? json['id'] ?? '').toString(),
    laporanId: (json['laporanId'] ?? json['laporan_id'] ?? '').toString(),
    aktorId: (json['aktorId'] ?? json['aktor_id'] ?? '').toString(),
    aktivitas: (json['aktivitas'] ?? '').toString(),
    catatanPengerjaan: (json['catatanPengerjaan'] ?? '').toString().isEmpty
        ? null
        : (json['catatanPengerjaan'] ?? '').toString(),
    fotoBuktiUrls: (json['fotoBuktiUrls'] as List<dynamic>?)
        ?.map((value) => value.toString())
        .toList(),
    timestamp: DateTime.tryParse((json['timestamp'] ?? '').toString()) ??
        DateTime.fromMillisecondsSinceEpoch(0),
    aktorNama: (json['aktorNama'] ?? '').toString().isEmpty
        ? null
        : (json['aktorNama'] ?? '').toString(),
  );
}

extension TindakanFasilitasJson on TindakanFasilitas {
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'laporanId': laporanId,
      'laporan_id': laporanId,
      'aktorId': aktorId,
      'aktor_id': aktorId,
      'aktivitas': aktivitas,
      'catatanPengerjaan': catatanPengerjaan,
      'fotoBuktiUrls': fotoBuktiUrls,
      'timestamp': timestamp.toIso8601String(),
      'aktorNama': aktorNama,
    };
  }
}
