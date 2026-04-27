// ============================================================
// FILE: modules/home/teknisi/riwayat/model/riwayat_tugas_model.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// Sesuai entitas Laporan_Fasilitas & Tindakan_Fasilitas di PDF
// ============================================================

// --------------- ENUM FILTER WAKTU ---------------
enum FilterRiwayat { semua, mingguIni, bulanIni }

extension FilterRiwayatExt on FilterRiwayat {
  String get label {
    switch (this) {
      case FilterRiwayat.semua:
        return 'Semua';
      case FilterRiwayat.mingguIni:
        return 'Minggu Ini';
      case FilterRiwayat.bulanIni:
        return 'Bulan Ini';
    }
  }
}

// --------------- ITEM RIWAYAT MODEL ---------------
/// Representasi laporan fasilitas yang sudah diselesaikan (status: resolved)
/// Sesuai Laporan_Fasilitas + Tindakan_Fasilitas di PDF
class ItemRiwayatModel {
  /// _id dari Laporan_Fasilitas
  final String id;

  /// Nomor ID yang tampil di UI (format: TK-XXXX)
  final String nomorId;

  /// judul laporan
  final String judul;

  /// lokasiLabKelas
  final String lokasi;

  /// kategori fasilitas
  final String kategori;

  /// Waktu diselesaikan — dari Tindakan_Fasilitas.timestamp (UC-07)
  final DateTime selesaiAt;

  /// Catatan pengerjaan teknisi (catatanPengerjaan di Tindakan_Fasilitas)
  final String? catatanPengerjaan;

  /// URL foto bukti — wajib saat resolved (fotoBuktiUrls di PDF)
  final List<String> fotoBuktiUrls;

  const ItemRiwayatModel({
    required this.id,
    required this.nomorId,
    required this.judul,
    required this.lokasi,
    required this.kategori,
    required this.selesaiAt,
    this.catatanPengerjaan,
    this.fotoBuktiUrls = const [],
  });

  /// Format tanggal & jam: "12 Okt 2023, 14:30"
  String get tanggalLabel {
    const bulan = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
      'Jul', 'Agt', 'Sep', 'Okt', 'Nov', 'Des'
    ];
    final h = selesaiAt.hour.toString().padLeft(2, '0');
    final m = selesaiAt.minute.toString().padLeft(2, '0');
    return '${selesaiAt.day} ${bulan[selesaiAt.month]} ${selesaiAt.year}, $h:$m';
  }

  /// Apakah diselesaikan minggu ini
  bool get isMingguIni {
    final now = DateTime.now();
    final startOfWeek =
        now.subtract(Duration(days: now.weekday - 1));
    final start = DateTime(
        startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return selesaiAt.isAfter(start);
  }

  /// Apakah diselesaikan bulan ini
  bool get isBulanIni {
    final now = DateTime.now();
    return selesaiAt.month == now.month &&
        selesaiAt.year == now.year;
  }

  static List<ItemRiwayatModel> dummyList() => [
        ItemRiwayatModel(
          id: 'lap-9021',
          nomorId: 'TK-9021',
          judul: 'Instalasi Jaringan Fiber Optik',
          lokasi: 'Lab Jaringan, Gedung A Lt. 3',
          kategori: 'Jaringan Internet',
          selesaiAt: DateTime(2023, 10, 12, 14, 30),
          catatanPengerjaan:
              'Instalasi kabel fiber selesai, koneksi stabil 1 Gbps.',
          fotoBuktiUrls: ['bukti_9021_1.jpg', 'bukti_9021_2.jpg'],
        ),
        ItemRiwayatModel(
          id: 'lap-8842',
          nomorId: 'TK-8842',
          judul: 'Perbaikan Router Utama Area Barat',
          lokasi: 'Ruang Server, Gedung B',
          kategori: 'Jaringan Internet',
          selesaiAt: DateTime(2023, 10, 10, 9, 15),
          catatanPengerjaan:
              'Router diganti dengan unit baru, konfigurasi ulang VLAN.',
          fotoBuktiUrls: ['bukti_8842_1.jpg'],
        ),
        ItemRiwayatModel(
          id: 'lap-8710',
          nomorId: 'TK-8710',
          judul: 'Pengecekan Rutin Server Room B',
          lokasi: 'Server Room B, Gedung Utama',
          kategori: 'Perangkat PC',
          selesaiAt: DateTime(2023, 10, 5, 16, 45),
          catatanPengerjaan:
              'Pengecekan suhu, debu, dan koneksi kabel. Semua normal.',
          fotoBuktiUrls: [
            'bukti_8710_1.jpg',
            'bukti_8710_2.jpg',
            'bukti_8710_3.jpg'
          ],
        ),
        ItemRiwayatModel(
          id: 'lap-8601',
          nomorId: 'TK-8601',
          judul: 'AC Ruang 302 Tidak Dingin',
          lokasi: 'Ruang Kelas 302, Gedung C',
          kategori: 'AC / Pendingin',
          selesaiAt: DateTime(2023, 9, 28, 11, 0),
          catatanPengerjaan: 'Freon diisi ulang, AC kembali normal.',
          fotoBuktiUrls: ['bukti_8601_1.jpg'],
        ),
        ItemRiwayatModel(
          id: 'lap-8542',
          nomorId: 'TK-8542',
          judul: 'Proyektor Lab Multimedia Mati',
          lokasi: 'Lab Multimedia, Gedung B Lt. 2',
          kategori: 'Listrik & Proyektor',
          selesaiAt: DateTime(2023, 9, 22, 13, 30),
          fotoBuktiUrls: ['bukti_8542_1.jpg'],
        ),
        ItemRiwayatModel(
          id: 'lap-8401',
          nomorId: 'TK-8401',
          judul: 'Switch Jaringan Lab Komputer Mati',
          lokasi: 'Lab Komputer Dasar, Gedung A',
          kategori: 'Jaringan Internet',
          selesaiAt: DateTime(2023, 9, 15, 10, 0),
          catatanPengerjaan:
              'Switch diganti, semua port aktif kembali.',
          fotoBuktiUrls: ['bukti_8401_1.jpg'],
        ),
      ];
}