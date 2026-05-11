import 'package:flutter/foundation.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

class LaporanFasilitasService {
  static const String collectionName = 'laporan_fasilitas';

  @visibleForTesting
  static Future<List<Map<String, dynamic>>> Function(
    String collection,
    SelectorBuilder filter,
  )?
  fetchOverride;

  @visibleForTesting
  static Future<void> Function(String collection, Map<String, dynamic> data)?
  insertOverride;

  @visibleForTesting
  static Future<void> Function(
    String collection,
    SelectorBuilder filter,
    Map<String, dynamic> data,
  )?
  updateOverride;

  @visibleForTesting
  static Future<void> Function(String collection, String id)? deleteOverride;

  Future<LaporanFasilitasModel> create(LaporanFasilitasModel laporan) async {
    final data = laporan.toJson();
    final override = insertOverride;
    if (override != null) {
      await override(collectionName, data);
      return laporan;
    }

    await MonggoDBServices().insertData(collectionName, data);
    return laporan;
  }

  Future<List<LaporanFasilitasModel>> getAll() async {
    final rows = await _fetchByFilter(where.exists('_id'));
    return rows.map(LaporanFasilitasModel.fromJson).toList();
  }

  Future<List<LaporanFasilitasModel>> getForRole(String role) async {
    final normalized = role.toLowerCase();
    final all = await getAll();

    if (normalized == 'tu') {
      return all.where((laporan) => laporan.diajukanKeTu).toList()
        ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }

    if (normalized == 'teknisi' || normalized == 'petugas') {
      return all
          .where(
            (laporan) =>
                laporan.status == StatusLaporan.pending ||
                laporan.status == StatusLaporan.in_progress ||
                laporan.status == StatusLaporan.escalated_to_upt,
          )
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return all..sort((a, b) => b.vote_score.compareTo(a.vote_score));
  }

  Future<LaporanFasilitasModel?> getById(String id) async {
    final rows = await _fetchByFilter(where.eq('_id', id));
    if (rows.isEmpty) return null;
    return LaporanFasilitasModel.fromJson(rows.first);
  }

  Future<LaporanFasilitasModel> update(LaporanFasilitasModel laporan) async {
    final override = updateOverride;
    final data = laporan.toJson();
    if (override != null) {
      await override(collectionName, where.eq('_id', laporan.id), data);
      return laporan;
    }

    await MonggoDBServices().updateOneByFilter(
      collectionName,
      where.eq('_id', laporan.id),
      data,
    );
    return laporan;
  }

  Future<void> tanggapiPetugas({
    required String laporanId,
    required String teknisiId,
    required String catatan,
    bool ajukanKeTu = false,
    String? kebutuhanTu,
  }) async {
    final data = {
      'teknisi_id': teknisiId,
      'catatan_petugas': catatan,
      'status': ajukanKeTu
          ? StatusLaporan.escalated_to_upt.value
          : StatusLaporan.in_progress.value,
      'kebutuhan_tu': ajukanKeTu ? kebutuhanTu : null,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await _updateById(laporanId, data);
  }

  Future<void> tandaiDicetak({
    required String laporanId,
    required String printedBy,
  }) async {
    await _updateById(laporanId, {
      'status': StatusLaporan.resolved.value,
      'printedAt': DateTime.now().toIso8601String(),
      'printedBy': printedBy,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> delete(String id) async {
    final override = deleteOverride;
    if (override != null) {
      await override(collectionName, id);
      return;
    }

    await MonggoDBServices().deleteData(collectionName, id);
  }

  Future<void> _updateById(String id, Map<String, dynamic> data) async {
    final override = updateOverride;
    if (override != null) {
      await override(collectionName, where.eq('_id', id), data);
      return;
    }
    await MonggoDBServices().updateOneByFilter(
      collectionName,
      where.eq('_id', id),
      data,
    );
  }

  Future<List<Map<String, dynamic>>> _fetchByFilter(
    SelectorBuilder filter,
  ) async {
    final override = fetchOverride;
    if (override != null) return override(collectionName, filter);
    return MonggoDBServices().fetch(collectionName, filter);
  }
}
