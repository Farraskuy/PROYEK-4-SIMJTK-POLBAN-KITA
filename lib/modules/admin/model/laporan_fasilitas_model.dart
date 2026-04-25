class LaporanFasilitas {
  final String id;
  final String judul;
  final String deskripsi;
  final String kategoriId;
  final String? namaKategori;
  final String lokasiLabKelas;
  final List<String> fotoUrls;
  String status;
  String prioritas;
  final String pelaporId;
  final String pelaporName;
  String? handlerId;
  String? handlerName;
  DateTime? estimasiSelesai;
  final DateTime createdAt;
  DateTime updatedAt;

  LaporanFasilitas({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.kategoriId,
    this.namaKategori,
    required this.lokasiLabKelas,
    required this.fotoUrls,
    required this.status,
    required this.prioritas,
    required this.pelaporId,
    required this.pelaporName,
    this.handlerId,
    this.handlerName,
    this.estimasiSelesai,
    required this.createdAt,
    required this.updatedAt,
  });
}

