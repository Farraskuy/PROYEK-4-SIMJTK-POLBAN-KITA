import 'package:proyek_4_poki_polban_kita/shared/services/hive_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/network_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/sync_queue_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/cloudinary_service.dart';

class LaporanFasilitasSyncService {
  static const String collectionName = 'laporan_fasilitas';

  static final LaporanFasilitasSyncService _instance =
      LaporanFasilitasSyncService._internal();

  LaporanFasilitasSyncService._internal();

  factory LaporanFasilitasSyncService() => _instance;

  bool _isSyncing = false;

  final MonggoDBServices _mongo = MonggoDBServices();
  final NetworkService _network = NetworkService();
  final SyncQueueService _queue = SyncQueueService();
  final CloudinaryService _cloudinary = CloudinaryService();

  Future<void> syncPending() async {
    if (_isSyncing || !await _network.isOnline) return;

    _isSyncing = true;
    try {
      await HiveService.init();
      await _mongo.ensureConnected();

      final items = await _queue.pendingItems(collection: collectionName);
      for (final item in items) {
        try {
          await _syncItem(item);
          await _queue.remove(item['id'].toString());
        } catch (e) {
          await _queue.markFailed(item, e);
        }
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _syncItem(Map<String, dynamic> item) async {
    final operation = SyncQueueOperation.fromValue(item['operation']);
    final documentId = item['documentId'].toString();
    final payload = Map<String, dynamic>.from(item['payload'] as Map? ?? {});

    // Upload local paths in foto_urls to Cloudinary first
    final fotoUrls = List<String>.from(payload['foto_urls'] as List? ?? []);
    final uploadedUrls = <String>[];
    bool hasChanges = false;
    for (final path in fotoUrls) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        uploadedUrls.add(path);
      } else {
        try {
          final remoteUrl = await _cloudinary.uploadImage(
            path,
            folder: 'simjtk/laporan_fasilitas',
          );
          uploadedUrls.add(remoteUrl);
          hasChanges = true;
        } catch (_) {
          uploadedUrls.add(path);
        }
      }
    }

    if (hasChanges) {
      payload['foto_urls'] = uploadedUrls;
      final localData = HiveService.laporanBox.get(documentId);
      if (localData is Map) {
        final updatedLocal = Map<String, dynamic>.from(localData);
        updatedLocal['foto_urls'] = uploadedUrls;
        await HiveService.laporanBox.put(documentId, updatedLocal);
      }
    }

    await _markLocal(documentId, 'syncing');

    switch (operation) {
      case SyncQueueOperation.create:
        await _upsert(documentId, payload);
        await _markLocal(documentId, 'synced');
        break;
      case SyncQueueOperation.update:
        await _mongo.updateById(collectionName, documentId, {
          ...payload,
          'syncStatus': 'synced',
        });
        await _markLocal(documentId, 'synced');
        break;
      case SyncQueueOperation.delete:
        await _mongo.deleteById(collectionName, documentId);
        await HiveService.laporanBox.delete(documentId);
        break;
    }
  }

  Future<void> _upsert(String documentId, Map<String, dynamic> payload) async {
    final existing = await _mongo.fetchByField(collectionName, '_id', documentId);
    final syncedPayload = {
      ...payload,
      '_id': documentId,
      'id': documentId,
      'syncStatus': 'synced',
    };

    if (existing.isEmpty) {
      await _mongo.insertData(collectionName, syncedPayload);
    } else {
      await _mongo.updateById(collectionName, documentId, syncedPayload);
    }
  }

  Future<void> _markLocal(String documentId, String syncStatus) async {
    final value = HiveService.laporanBox.get(documentId);
    if (value is! Map) return;

    await HiveService.laporanBox.put(documentId, {
      ...Map<String, dynamic>.from(value),
      'syncStatus': syncStatus,
    });
  }
}
