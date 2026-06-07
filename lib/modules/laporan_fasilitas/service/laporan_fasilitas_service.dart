import 'package:flutter/foundation.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_sync_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/hive_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/network_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/sync_queue_service.dart';

class LaporanFasilitasService {
  static const String collectionName = 'laporan_fasilitas';
  final SyncQueueService _queue = SyncQueueService();
  final LaporanFasilitasSyncService _sync = LaporanFasilitasSyncService();
  final NetworkService _network = NetworkService();

  Future<LaporanFasilitasModel> create(LaporanFasilitasModel laporan) async {
    final local = laporan.copyWith(syncStatus: 'pending');
    await _saveLocal(local);
    await _queue.enqueue(
      collection: collectionName,
      operation: SyncQueueOperation.create,
      documentId: local.id,
      payload: local.toJson(),
    );
    await _trySyncPending();
    return _readLocalById(local.id) ?? local;
  }

  Future<List<LaporanFasilitasModel>> getAll() async {
    await HiveService.init();
    await _trySyncPending();

    final local = _readLocalAll();
    if (!await _network.isOnline) return local;

    try {
      final rows = await _fetchAll();
      await _replaceLocalFromRemote(rows);
      return _readLocalAll();
    } catch (e) {
      debugPrint('Gagal refresh laporan dari MongoDB, memakai Hive: $e');
      return local;
    }
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
    await HiveService.init();
    await _trySyncPending();

    final local = _readLocalById(id);
    if (!await _network.isOnline) return local;

    try {
      final rows = await _fetchById(id);
      if (rows.isEmpty) return local;
      final remote = LaporanFasilitasModel.fromJson(rows.first)
          .copyWith(syncStatus: 'synced');
      await _saveLocal(remote);
      return _readLocalById(id);
    } catch (_) {
      return local;
    }
  }

  Future<LaporanFasilitasModel> update(LaporanFasilitasModel laporan) async {
    final local = laporan.copyWith(syncStatus: 'pending');
    await _saveLocal(local);
    await _queue.enqueue(
      collection: collectionName,
      operation: SyncQueueOperation.update,
      documentId: local.id,
      payload: local.toJson(),
    );
    await _trySyncPending();
    return _readLocalById(local.id) ?? local;
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
    await HiveService.init();
    final existing = _readLocalById(id);
    if (existing != null) {
      await _saveLocal(existing.copyWith(syncStatus: 'deleted'));
    }
    await _queue.enqueue(
      collection: collectionName,
      operation: SyncQueueOperation.delete,
      documentId: id,
      payload: {'_id': id, 'id': id},
    );
    await _trySyncPending();
  }

  Future<void> _updateById(String id, Map<String, dynamic> data) async {
    final existing = await getById(id);
    if (existing == null) return;

    final merged = {
      ...existing.toJson(),
      ...data,
      '_id': id,
      'id': id,
      'syncStatus': 'pending',
    };
    final local = LaporanFasilitasModel.fromJson(merged);
    await _saveLocal(local);
    await _queue.enqueue(
      collection: collectionName,
      operation: SyncQueueOperation.update,
      documentId: id,
      payload: local.toJson(),
    );
    await _trySyncPending();
  }

  Future<List<Map<String, dynamic>>> _fetchAll({
    String? sortBy,
    bool descending = false,
  }) async {
    final mongo = MonggoDBServices();
    final rawRows = await mongo.fetchAll(
      collectionName,
      sortBy: sortBy,
      descending: descending,
    );

    return _enrichWithUserNames(mongo, rawRows);
  }

  Future<List<Map<String, dynamic>>> _fetchById(String id) async {
    final mongo = MonggoDBServices();
    final rawRows = await mongo.fetchByField(collectionName, '_id', id);

    return _enrichWithUserNames(mongo, rawRows);
  }

  Future<List<Map<String, dynamic>>> _enrichWithUserNames(
    MonggoDBServices mongo,
    List<Map<String, dynamic>> rawRows,
  ) async {
    if (rawRows.isEmpty) return rawRows;

    // --- PROSES MENGAMBIL NAMA USER DARI KOLEKSI 'users' ---
    final enrichedRows = <Map<String, dynamic>>[];
    try {
      final userIds = rawRows
          .map((r) => r['pelapor_id']?.toString())
          .where((id) => id != null && id.isNotEmpty)
          .toSet()
          .toList();

      Map<String, String> userMap = {};

      if (userIds.isNotEmpty) {
        final usersData = await mongo.fetchOneFrom('users', '_id', userIds);
        
        for (var u in usersData) {
          final uId = u['_id']?.toString();
          final uName = u['name']?.toString();
          if (uId != null && uName != null) {
            userMap[uId] = uName;
          }
        }
      }

      for (var row in rawRows) {
        final newRow = Map<String, dynamic>.from(row);
        final pid = newRow['pelapor_id']?.toString();
        
        if (pid != null && userMap.containsKey(pid)) {
          newRow['pelapor_nama'] = userMap[pid]; 
        }
        
        enrichedRows.add(newRow);
      }
      return enrichedRows;
      
    } catch (e) {
      debugPrint('Gagal melakukan join data user: $e');
      return rawRows; 
    }
  }

  Future<List<LaporanFasilitasModel>> fetchAll() async {
    final rows = await getAll();
    return rows..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> _saveLocal(LaporanFasilitasModel laporan) async {
    await HiveService.init();
    await HiveService.laporanBox.put(laporan.id, laporan.toJson());
  }

  LaporanFasilitasModel? _readLocalById(String id) {
    final value = HiveService.laporanBox.get(id);
    if (value is! Map) return null;
    final data = Map<String, dynamic>.from(value);
    if (data['syncStatus'] == 'deleted') return null;
    return LaporanFasilitasModel.fromJson(data);
  }

  List<LaporanFasilitasModel> _readLocalAll() {
    return HiveService.laporanBox.values
        .whereType<Map>()
        .map((item) => LaporanFasilitasModel.fromJson(
              Map<String, dynamic>.from(item),
            ))
        .where((laporan) => laporan.syncStatus != 'deleted')
        .toList();
  }

  Future<void> _replaceLocalFromRemote(List<Map<String, dynamic>> rows) async {
    final pendingIds = (await _queue.pendingItems(collection: collectionName))
        .map((item) => item['documentId']?.toString())
        .whereType<String>()
        .toSet();

    for (final row in rows) {
      final laporan = LaporanFasilitasModel.fromJson(row)
          .copyWith(syncStatus: 'synced');
      if (!pendingIds.contains(laporan.id)) {
        await _saveLocal(laporan);
      }
    }
  }

  Future<void> _trySyncPending() async {
    if (!await _network.isOnline) return;
    try {
      await _sync.syncPending();
    } catch (e) {
      debugPrint('Gagal sync pending laporan fasilitas: $e');
    }
  }
}
