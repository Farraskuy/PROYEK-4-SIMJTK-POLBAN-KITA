// lib/modules/laporan_fasilitas/service/detail_laporan_fasilitas_service.dart

import 'package:mongo_dart/mongo_dart.dart';
import '../model/laporan_fasilitas_model.dart';
import '../../../shared/services/mongodb_service.dart';

class DetailLaporanFasilitasService {
  static const String collectionName = 'laporan_fasilitas';

  /// Mengambil data laporan secara spesifik berdasarkan ID (_id)
  Future<LaporanFasilitasModel?> getLaporanById(String id) async {
    try {
      // Menggunakan fetch dengan filter selector pada field _id
      final result = await MonggoDBServices().fetch(
        collectionName,
        where.eq('_id', id),
      );

      if (result.isNotEmpty) {
        return LaporanFasilitasModel.fromJson(result.first);
      }
      return null;
    } catch (e) {
      throw Exception('Gagal mengambil detail laporan: $e');
    }
  }

  /// Melakukan update pada teknisi_id dan status (delegasi)[cite: 8, 9]
  Future<void> delegasikanLaporan(String laporanId, String teknisiId) async {
    try {
      // Data yang di-update disesuaikan dengan skema snake_case[cite: 8]
      final updateData = {
        'teknisi_id': teknisiId,
        'status': StatusLaporan.in_progress.value,
        'updatedAt': DateTime.now().toIso8601String(),
      };

      await MonggoDBServices().updateOneByFilter(
        collectionName,
        where.eq('_id', laporanId),
        updateData,
      );
    } catch (e) {
      throw Exception('Gagal mendelegasikan laporan: $e');
    }
  }

  /* 
  // [Komentar]: Kode lama yang menggunakan data dummy dihapus 
  // agar sinkron dengan database MongoDB.
  */
}
