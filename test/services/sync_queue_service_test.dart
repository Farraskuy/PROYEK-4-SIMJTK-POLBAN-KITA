import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/hive_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/sync_queue_service.dart';

void main() {
  late MonggoDBServices mongoService;
  final syncQueueService = SyncQueueService();
  bool isNetworkOnline = true;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    HttpOverrides.global = null;

    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('dev.fluttercommunity.plus/connectivity'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'check') {
          return isNetworkOnline ? ['wifi'] : ['none'];
        }
        return null;
      },
    );

    final tempDir = Directory.systemTemp.createTempSync('test_hive_sync_queue_');
    HiveService.testPath = tempDir.path;

    final envFile = File('.env');
    if (envFile.existsSync()) {
      dotenv.loadFromString(envString: envFile.readAsStringSync());
    }
    mongoService = MonggoDBServices();
    await mongoService.connect();
  });

  tearDownAll(() async {
    await mongoService.close();
    await Hive.close();
    try {
      final dir = Directory(HiveService.testPath!);
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  setUp(() async {
    isNetworkOnline = true;
    await mongoService.ensureConnected();
    await HiveService.init();
    await HiveService.queueBox.clear();
  });

  group('SyncQueueService Unit Tests', () {
    test('1. Enqueue and Retrieve pending items', () async {
      await syncQueueService.enqueue(
        collection: 'test_collection',
        operation: SyncQueueOperation.create,
        documentId: 'test-doc-123',
        payload: {'name': 'Test Item'},
      );

      final items = await syncQueueService.pendingItems(collection: 'test_collection');
      expect(items, hasLength(1));
      expect(items.first['documentId'], equals('test-doc-123'));
      expect(items.first['operation'], equals(SyncQueueOperation.create.name));
    });

    test('2. Update existing CREATE queue instead of adding duplicate', () async {
      await syncQueueService.enqueue(
        collection: 'test_collection',
        operation: SyncQueueOperation.create,
        documentId: 'test-doc-123',
        payload: {'name': 'Test Item v1'},
      );

      await syncQueueService.enqueue(
        collection: 'test_collection',
        operation: SyncQueueOperation.create,
        documentId: 'test-doc-123',
        payload: {'name': 'Test Item v2'},
      );

      final items = await syncQueueService.pendingItems(collection: 'test_collection');
      expect(items, hasLength(1));
      expect(items.first['payload']['name'], equals('Test Item v2'));
    });

    test('3. Remove queue item by ID', () async {
      await syncQueueService.enqueue(
        collection: 'test_collection',
        operation: SyncQueueOperation.create,
        documentId: 'test-doc-123',
        payload: {'name': 'Test Item'},
      );

      var items = await syncQueueService.pendingItems(collection: 'test_collection');
      expect(items, hasLength(1));

      final queueId = items.first['id'].toString();
      await syncQueueService.remove(queueId);

      items = await syncQueueService.pendingItems(collection: 'test_collection');
      expect(items, isEmpty);
    });

    test('4. Mark failed and verify attempt count incremented', () async {
      await syncQueueService.enqueue(
        collection: 'test_collection',
        operation: SyncQueueOperation.create,
        documentId: 'test-doc-123',
        payload: {'name': 'Test Item'},
      );

      final items = await syncQueueService.pendingItems(collection: 'test_collection');
      final item = items.first;

      await syncQueueService.markFailed(item, 'Network timeout');

      final updatedItems = await syncQueueService.pendingItems(collection: 'test_collection');
      expect(updatedItems.first['attemptCount'], equals(1));
      expect(updatedItems.first['lastError'], equals('Network timeout'));
    });
  });
}
