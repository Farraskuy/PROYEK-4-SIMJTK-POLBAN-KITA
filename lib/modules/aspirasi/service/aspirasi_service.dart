// ============================================================
// FILE: modules/aspirasi/service/aspirasi_service.dart
// ============================================================

import 'package:flutter/foundation.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/service/aspirasi_sync_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/hive_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/network_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/sync_queue_service.dart';

class AspirasiService {
  static const String collectionName = 'aspirasi';
  final SyncQueueService _queue = SyncQueueService();
  final AspirasiSyncService _sync = AspirasiSyncService();
  final NetworkService _network = NetworkService();

  /// Mengambil semua data aspirasi (mencoba sync, lalu menyajikan data lokal/remote)
  Future<List<AspirasiModel>> fetchAllAspirasi() async {
    await HiveService.init();
    await _trySyncPending();

    final local = _readLocalAll();
    if (!await _network.isOnline) return local;

    try {
      final rows = await MonggoDBServices().fetchAll(collectionName);
      await _replaceLocalFromRemote(rows);
      return _readLocalAll();
    } catch (e) {
      debugPrint('Gagal refresh aspirasi dari MongoDB, memakai Hive: $e');
      return local;
    }
  }

  /// Menyimpan aspirasi baru (tulis lokal, antre sync)
  Future<void> createAspirasi(AspirasiModel aspirasi) async {
    final local = aspirasi.copyWith(syncStatus: 'pending');
    await _saveLocal(local);
    await _queue.enqueue(
      collection: collectionName,
      operation: SyncQueueOperation.create,
      documentId: local.id,
      payload: local.toJson(),
    );
    await _trySyncPending();
  }

  /// Memperbarui aspirasi (tulis lokal, antre sync)
  Future<void> updateAspirasi(AspirasiModel aspirasi) async {
    final local = aspirasi.copyWith(syncStatus: 'pending');
    await _saveLocal(local);
    await _queue.enqueue(
      collection: collectionName,
      operation: SyncQueueOperation.update,
      documentId: local.id,
      payload: local.toJson(),
    );
    await _trySyncPending();
  }

  /// Menghapus aspirasi (tanda lokal dihapus, antre sync)
  Future<void> deleteAspirasi(String id) async {
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

  // Helper Methods

  Future<void> _saveLocal(AspirasiModel aspirasi) async {
    await HiveService.init();
    await HiveService.aspirasiBox.put(aspirasi.id, aspirasi.toJson());
  }

  AspirasiModel? _readLocalById(String id) {
    final value = HiveService.aspirasiBox.get(id);
    if (value is! Map) return null;
    final data = Map<String, dynamic>.from(value);
    if (data['syncStatus'] == 'deleted') return null;
    return AspirasiModel.fromJson(data);
  }

  List<AspirasiModel> _readLocalAll() {
    return HiveService.aspirasiBox.values
        .whereType<Map>()
        .map((item) => AspirasiModel.fromJson(Map<String, dynamic>.from(item)))
        .where((aspirasi) => aspirasi.syncStatus != 'deleted')
        .toList();
  }

  Future<void> _replaceLocalFromRemote(List<Map<String, dynamic>> rows) async {
    final pendingIds = (await _queue.pendingItems(collection: collectionName))
        .map((item) => item['documentId']?.toString())
        .whereType<String>()
        .toSet();

    for (final row in rows) {
      final aspirasi = AspirasiModel.fromJson(row).copyWith(syncStatus: 'synced');
      if (!pendingIds.contains(aspirasi.id)) {
        await _saveLocal(aspirasi);
      }
    }
  }

  Future<void> _trySyncPending() async {
    if (!await _network.isOnline) return;
    try {
      await _sync.syncPending();
    } catch (e) {
      debugPrint('Gagal sync pending aspirasi: $e');
    }
  }
}
