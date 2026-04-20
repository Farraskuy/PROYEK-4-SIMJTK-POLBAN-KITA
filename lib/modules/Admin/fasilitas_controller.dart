import 'package:flutter/material.dart';

// ── Mock Models (temporary, replace with real models later) ──────────────────

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

class UserModel {
  final String id;
  final String name;
  final String nimNip;
  final String email;
  final String role;
  final bool isActive;

  const UserModel({
    required this.id,
    required this.name,
    required this.nimNip,
    required this.email,
    required this.role,
    this.isActive = true,
  });
}

// ── Controller ───────────────────────────────────────────────────────────────

class AdminFasilitasController extends ChangeNotifier {
  List<LaporanFasilitas> _allLaporan = [];
  List<UserModel> _allTeknisi = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _filterStatus = 'semua';

  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String get filterStatus => _filterStatus;
  List<UserModel> get allTeknisi => _allTeknisi;

  List<LaporanFasilitas> get filteredLaporan {
    if (_filterStatus == 'semua') return _allLaporan;
    if (_filterStatus == 'baru') {
      return _allLaporan.where((l) => l.status == 'pending').toList();
    }
    if (_filterStatus == 'ditugaskan') {
      return _allLaporan
          .where((l) => l.status == 'assigned' || l.status == 'in_progress')
          .toList();
    }
    return _allLaporan.where((l) => l.status == _filterStatus).toList();
  }

  int get totalLaporan => _allLaporan.length;
  int get totalTeknisiAktif => _allTeknisi.where((t) => t.isActive).length;
  int get laporanPending => _allLaporan.where((l) => l.status == 'pending').length;
  int get laporanInProgress => _allLaporan.where((l) => l.status == 'in_progress').length;
  int get laporanResolved => _allLaporan.where((l) => l.status == 'resolved').length;

  Future<void> loadData() async {
    _setLoading(true);
    await Future.delayed(const Duration(milliseconds: 400)); // simulate load
    _seedMockData();
    _setLoading(false);
  }

  Future<bool> delegasikanLaporan({
    required String laporanId,
    required String teknisiId,
    required String prioritas,
    DateTime? deadline,
    String? catatan,
    required String adminId,
    required String adminName,
    required String teknisiName,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 800)); // simulate network

      final idx = _allLaporan.indexWhere((l) => l.id == laporanId);
      if (idx == -1) return false;

      _allLaporan[idx].handlerId = teknisiId;
      _allLaporan[idx].handlerName = teknisiName;
      _allLaporan[idx].prioritas = prioritas;
      _allLaporan[idx].status = 'assigned';
      _allLaporan[idx].estimasiSelesai = deadline;
      _allLaporan[idx].updatedAt = DateTime.now();

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal mendelegasikan: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> tolakLaporan({
    required String laporanId,
    required String alasan,
    required String adminId,
    required String adminName,
  }) async {
    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final idx = _allLaporan.indexWhere((l) => l.id == laporanId);
      if (idx == -1) return false;

      _allLaporan[idx].status = 'rejected';
      _allLaporan[idx].updatedAt = DateTime.now();

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Gagal menolak laporan: $e';
      notifyListeners();
      return false;
    }
  }

  void setFilter(String status) {
    _filterStatus = status;
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  void _seedMockData() {
    final now = DateTime.now();

    _allTeknisi = const [
      UserModel(
        id: 'user-t1',
        name: 'Budi Santoso',
        nimNip: 'T-045',
        email: 'budi@polban.ac.id',
        role: 'staff',
      ),
      UserModel(
        id: 'user-t2',
        name: 'Dedi Hermawan',
        nimNip: 'T-067',
        email: 'dedi@polban.ac.id',
        role: 'staff',
      ),
      UserModel(
        id: 'user-t3',
        name: 'Siti Rahayu',
        nimNip: 'T-089',
        email: 'siti@polban.ac.id',
        role: 'staff',
      ),
    ];

    if (_allLaporan.isEmpty) {
      _allLaporan = [
        LaporanFasilitas(
          id: 'lap-001',
          judul: 'Projector Bracket Failure',
          deskripsi:
              'Braket proyektor di Auditorium Utama terlepas dari plafon dan membahayakan keselamatan.',
          kategoriId: 'kat-5',
          namaKategori: 'Proyektor',
          lokasiLabKelas: 'Auditorium Utama, Gd. A',
          fotoUrls: [],
          status: 'pending',
          prioritas: 'high',
          pelaporId: 'mhs-001',
          pelaporName: 'Kim y.teu',
          createdAt: now.subtract(const Duration(hours: 2)),
          updatedAt: now.subtract(const Duration(hours: 2)),
        ),
        LaporanFasilitas(
          id: 'lap-002',
          judul: 'AC Bocor di Ruang Dosen',
          deskripsi: 'AC menetes air cukup deras, sudah terjadi 3 hari.',
          kategoriId: 'kat-3',
          namaKategori: 'AC & Pendingin',
          lokasiLabKelas: 'Ruang Dosen 402, Gd. B',
          fotoUrls: [],
          status: 'assigned',
          prioritas: 'medium',
          pelaporId: 'mhs-002',
          pelaporName: 'Rina Sari',
          handlerId: 'user-t1',
          handlerName: 'Budi Santoso',
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 2)),
        ),
        LaporanFasilitas(
          id: 'lap-003',
          judul: 'Pintu Lab Komputer Rusak',
          deskripsi: 'Engsel pintu patah, pintu tidak bisa ditutup rapat.',
          kategoriId: 'kat-4',
          namaKategori: 'Mebel',
          lokasiLabKelas: 'Lab Komputer C, Gd. C',
          fotoUrls: [],
          status: 'pending',
          prioritas: 'low',
          pelaporId: 'mhs-003',
          pelaporName: 'Ahmad',
          createdAt: now.subtract(const Duration(days: 3)),
          updatedAt: now.subtract(const Duration(days: 3)),
        ),
        LaporanFasilitas(
          id: 'lap-004',
          judul: 'AC Ruang Kelas 10A Rusak',
          deskripsi:
              'Pendingin ruangan tidak berfungsi sejak pagi hari, air menetes dari unit indoor.',
          kategoriId: 'kat-3',
          namaKategori: 'AC & Pendingin',
          lokasiLabKelas: 'Gedung B, Lt.2',
          fotoUrls: [],
          status: 'pending',
          prioritas: 'high',
          pelaporId: 'mhs-004',
          pelaporName: 'Dewi',
          createdAt: now.subtract(const Duration(hours: 4)),
          updatedAt: now.subtract(const Duration(hours: 4)),
        ),
      ];
    }
  }
}