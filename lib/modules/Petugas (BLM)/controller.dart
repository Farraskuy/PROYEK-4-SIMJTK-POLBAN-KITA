// import 'package:flutter/material.dart';
// import '../../shared/models/laporan_fasilitas_model.dart';
// import '../../shared/models/tindakan_fasilitas_model.dart';
// import '../../shared/services/hive_service.dart';
// import 'package:uuid/uuid.dart';

// class PetugasController extends ChangeNotifier {
//   List<LaporanFasilitas> _myTasks = [];
//   bool _isLoading = false;
//   String _errorMessage = '';
//   String _filterStatus = 'semua'; // semua, menunggu, diproses, selesai

//   bool get isLoading => _isLoading;
//   String get errorMessage => _errorMessage;
//   String get filterStatus => _filterStatus;

//   List<LaporanFasilitas> get filteredTasks {
//     if (_filterStatus == 'semua') return _myTasks;
//     if (_filterStatus == 'menunggu') {
//       return _myTasks.where((t) => t.status == 'assigned').toList();
//     }
//     if (_filterStatus == 'diproses') {
//       return _myTasks.where((t) => t.status == 'in_progress').toList();
//     }
//     if (_filterStatus == 'selesai') {
//       return _myTasks.where((t) => t.status == 'resolved').toList();
//     }
//     return _myTasks;
//   }

//   List<LaporanFasilitas> get urgentTasks => _myTasks
//       .where((t) =>
//           t.prioritas == 'high' &&
//           (t.status == 'assigned' || t.status == 'in_progress'))
//       .toList();

//   int get tasksToday =>
//       _myTasks.where((t) => _isToday(t.createdAt)).length;
//   int get tasksPending =>
//       _myTasks.where((t) => t.status == 'assigned').length;
//   int get tasksCompleted =>
//       _myTasks.where((t) => t.status == 'resolved').length;
//   int get tasksInProgress =>
//       _myTasks.where((t) => t.status == 'in_progress').length;

//   Future<void> loadData(String petugasId) async {
//     _setLoading(true);
//     try {
//       _myTasks = HiveService.getLaporanByHandler(petugasId)
//         ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
//     } catch (e) {
//       _errorMessage = 'Gagal memuat data: $e';
//     } finally {
//       _setLoading(false);
//     }
//   }

//   /// Start working on a task (assigned → in_progress)
//   Future<bool> mulaiKerjakan({
//     required String laporanId,
//     required String petugasId,
//     required String petugasName,
//   }) async {
//     try {
//       final laporan = HiveService.getLaporanById(laporanId);
//       if (laporan == null) return false;

//       laporan.status = 'in_progress';
//       laporan.updatedAt = DateTime.now();
//       await HiveService.saveLaporan(laporan);

//       final tindakan = TindakanFasilitas(
//         id: const Uuid().v4(),
//         laporanId: laporanId,
//         aktorId: petugasId,
//         aktivitas: 'Teknisi mulai mengerjakan tugas',
//         timestamp: DateTime.now(),
//         aktorName: petugasName,
//         aktorRole: 'staff',
//       );
//       await HiveService.saveTindakan(tindakan);

//       await loadData(petugasId);
//       return true;
//     } catch (e) {
//       _errorMessage = 'Gagal memulai tugas: $e';
//       notifyListeners();
//       return false;
//     }
//   }

//   /// Complete a task (in_progress → resolved)
//   Future<bool> selesaikanTugas({
//     required String laporanId,
//     required String petugasId,
//     required String petugasName,
//     required String catatan,
//     required List<String> fotoBuktiUrls,
//     int? durasiMenit,
//   }) async {
//     try {
//       final laporan = HiveService.getLaporanById(laporanId);
//       if (laporan == null) return false;

//       laporan.status = 'resolved';
//       laporan.updatedAt = DateTime.now();
//       await HiveService.saveLaporan(laporan);

//       final tindakan = TindakanFasilitas(
//         id: const Uuid().v4(),
//         laporanId: laporanId,
//         aktorId: petugasId,
//         aktivitas: 'Perbaikan selesai${durasiMenit != null ? ' dalam $durasiMenit menit' : ''}',
//         catatanPengerjaan: catatan,
//         fotoBuktiUrls: fotoBuktiUrls,
//         timestamp: DateTime.now(),
//         aktorName: petugasName,
//         aktorRole: 'staff',
//       );
//       await HiveService.saveTindakan(tindakan);

//       await loadData(petugasId);
//       return true;
//     } catch (e) {
//       _errorMessage = 'Gagal menyelesaikan tugas: $e';
//       notifyListeners();
//       return false;
//     }
//   }

//   List<TindakanFasilitas> getTindakanForLaporan(String laporanId) =>
//       HiveService.getTindakanByLaporan(laporanId);

//   void setFilter(String status) {
//     _filterStatus = status;
//     notifyListeners();
//   }

//   void _setLoading(bool val) {
//     _isLoading = val;
//     notifyListeners();
//   }

//   bool _isToday(DateTime dt) {
//     final now = DateTime.now();
//     return dt.year == now.year && dt.month == now.month && dt.day == now.day;
//   }
// }