// lib/modules/teknisi/analisa_kerusakan/service/analisa_kerusakan_service.dart

import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import '../model/analisa_kerusakan_model.dart';

class AnalisaKerusakanService {
  // Memanggil instance Singleton dari MongoDB Service Anda
  final MonggoDBServices _dbService = MonggoDBServices();
  
  // Nama collection di dalam database MongoDB Anda
  final String collectionName = 'analisa_kerusakan';

  /// Mengambil semua data analisa kerusakan dari database MongoDB
  Future<List<AnalisaKerusakanModel>> getAll() async {
    try {
      await _dbService.ensureConnected();

      // Mengambil data dan mengurutkannya dari yang terbaru (descending)
      final List<Map<String, dynamic>> rawData = await _dbService.fetchAll(
        collectionName,
        sortBy: 'created_at',
        descending: true,
      );

      // Memetakan raw JSON ke dalam List objek Model
      return rawData.map((json) => AnalisaKerusakanModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data Analisa: $e');
    }
  }

  /// Menyimpan data formulir analisa baru ke MongoDB
  Future<void> create(AnalisaKerusakanModel data) async {
    try {
      await _dbService.ensureConnected();

      // Mengubah objek Dart menjadi format Map/JSON yang dipahami MongoDB
      Map<String, dynamic> dataMap = data.toMap();

      // Menyesuaikan format ID untuk MongoDB
      if (dataMap['id'] != null && dataMap['id'].toString().isNotEmpty) {
        dataMap['_id'] = dataMap['id'];
        dataMap.remove('id');
      }

      await _dbService.insertData(collectionName, dataMap);
    } catch (e) {
      throw Exception('Gagal menyimpan data Analisa: $e');
    }
  }

  /// Mengambil analisa spesifik berdasarkan ID Laporan
  Future<List<AnalisaKerusakanModel>> getByLaporanId(String laporanId) async {
    try {
      await _dbService.ensureConnected();

      final List<Map<String, dynamic>> rawData = await _dbService.fetchByField(
        collectionName,
        'laporan_id',
        laporanId,
        sortBy: 'created_at',
        descending: true,
      );

      return rawData.map((json) => AnalisaKerusakanModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Gagal mengambil data Analisa berdasarkan Laporan: $e');
    }
  }
}
