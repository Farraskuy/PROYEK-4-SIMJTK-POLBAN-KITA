import 'package:uuid/uuid.dart';

import 'hive_service.dart';

enum SyncQueueOperation {
  create,
  update,
  delete;

  static SyncQueueOperation fromValue(Object? value) {
    final normalized = value?.toString().trim().toLowerCase();
    return SyncQueueOperation.values.firstWhere(
      (item) => item.name == normalized,
      orElse: () => SyncQueueOperation.update,
    );
  }
}

class SyncQueueService {
  static final SyncQueueService _instance = SyncQueueService._internal();

  SyncQueueService._internal();

  factory SyncQueueService() => _instance;

  final Uuid _uuid = const Uuid();

  Future<void> enqueue({
    required String collection,
    required SyncQueueOperation operation,
    required String documentId,
    required Map<String, dynamic> payload,
  }) async {
    await HiveService.init();

    if (operation == SyncQueueOperation.delete) {
      await _removeQueuedDocumentOperations(collection, documentId);
    } else {
      final existingCreate = _findQueue(
        collection: collection,
        documentId: documentId,
        operation: SyncQueueOperation.create,
      );
      if (existingCreate != null) {
        await HiveService.queueBox.put(existingCreate['id'], {
          ...existingCreate,
          'payload': payload,
          'updatedAt': DateTime.now().toIso8601String(),
          'lastError': null,
        });
        return;
      }

      final existingUpdate = _findQueue(
        collection: collection,
        documentId: documentId,
        operation: SyncQueueOperation.update,
      );
      if (existingUpdate != null) {
        await HiveService.queueBox.put(existingUpdate['id'], {
          ...existingUpdate,
          'payload': payload,
          'updatedAt': DateTime.now().toIso8601String(),
          'lastError': null,
        });
        return;
      }
    }

    final now = DateTime.now().toIso8601String();
    final id = _uuid.v4();
    await HiveService.queueBox.put(id, {
      'id': id,
      'collection': collection,
      'operation': operation.name,
      'documentId': documentId,
      'payload': payload,
      'createdAt': now,
      'updatedAt': now,
      'attemptCount': 0,
      'lastError': null,
    });
  }

  Future<List<Map<String, dynamic>>> pendingItems({String? collection}) async {
    await HiveService.init();

    final items = HiveService.queueBox.values
        .whereType<Map>()
        .map((item) => Map<String, dynamic>.from(item))
        .where((item) => collection == null || item['collection'] == collection)
        .toList();

    items.sort((a, b) {
      final left = DateTime.tryParse(a['createdAt']?.toString() ?? '');
      final right = DateTime.tryParse(b['createdAt']?.toString() ?? '');
      return (left ?? DateTime(1970)).compareTo(right ?? DateTime(1970));
    });
    return items;
  }

  Future<void> remove(String queueId) async {
    await HiveService.init();
    await HiveService.queueBox.delete(queueId);
  }

  Future<void> markFailed(Map<String, dynamic> item, Object error) async {
    await HiveService.init();
    final attemptCount = (item['attemptCount'] as int? ?? 0) + 1;
    await HiveService.queueBox.put(item['id'], {
      ...item,
      'attemptCount': attemptCount,
      'updatedAt': DateTime.now().toIso8601String(),
      'lastError': error.toString(),
    });
  }

  Future<void> _removeQueuedDocumentOperations(
    String collection,
    String documentId,
  ) async {
    final items = await pendingItems(collection: collection);
    for (final item in items) {
      if (item['documentId'] == documentId) {
        await HiveService.queueBox.delete(item['id']);
      }
    }
  }

  Map<String, dynamic>? _findQueue({
    required String collection,
    required String documentId,
    required SyncQueueOperation operation,
  }) {
    for (final value in HiveService.queueBox.values.whereType<Map>()) {
      final item = Map<String, dynamic>.from(value);
      if (item['collection'] == collection &&
          item['documentId'] == documentId &&
          item['operation'] == operation.name) {
        return item;
      }
    }
    return null;
  }
}
