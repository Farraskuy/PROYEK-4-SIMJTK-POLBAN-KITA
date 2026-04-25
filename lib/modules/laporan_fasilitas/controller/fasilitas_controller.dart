import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import '../model/laporan_fasilitas_model.dart';

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
      return _allLaporan
          .where((l) => l.status == StatusLaporan.pending)
          .toList();
    }
    if (_filterStatus == 'ditugaskan') {
      return _allLaporan
          .where(
            (l) =>
                l.status == StatusLaporan.assigned ||
                l.status == StatusLaporan.inProgress,
          )
          .toList();
    }
    return _allLaporan.where((l) => l.status.value == _filterStatus).toList();
  }

  int get totalLaporan => _allLaporan.length;
  int get totalTeknisiAktif => _allTeknisi.where((t) => t.isActive).length;
  int get laporanPending =>
      _allLaporan.where((l) => l.status == StatusLaporan.pending).length;
  int get laporanInProgress =>
      _allLaporan.where((l) => l.status == StatusLaporan.inProgress).length;
  int get laporanResolved =>
      _allLaporan.where((l) => l.status == StatusLaporan.resolved).length;

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
      await Future.delayed(
        const Duration(milliseconds: 800),
      ); // simulate network

      final idx = _allLaporan.indexWhere((l) => l.id == laporanId);
      if (idx == -1) return false;

      _allLaporan[idx].handlerId = teknisiId;
      _allLaporan[idx].handlerName = teknisiName;
      _allLaporan[idx].prioritas = PrioritasLaporan.fromValue(prioritas);
      _allLaporan[idx].status = StatusLaporan.assigned;
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

      _allLaporan[idx].status = StatusLaporan.rejected;
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
        username: 'T-045',
        name: 'Budi Santoso',
        email: 'budi@polban.ac.id',
        role: 'staff',
        isActive: true,
      ),
      UserModel(
        id: 'user-t2',
        username: 'T-067',
        name: 'Dedi Hermawan',
        email: 'dedi@polban.ac.id',
        role: 'staff',
        isActive: true,
      ),
      UserModel(
        id: 'user-t3',
        username: 'T-089',
        name: 'Siti Rahayu',
        email: 'siti@polban.ac.id',
        role: 'staff',
        isActive: true,
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
