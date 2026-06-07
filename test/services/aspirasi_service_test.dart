import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/service/aspirasi_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/service/aspirasi_sync_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/hive_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/sync_queue_service.dart';

void main() {
  late MonggoDBServices mongoService;
  final aspirasiService = AspirasiService();
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

    final tempDir = Directory.systemTemp.createTempSync('test_hive_aspirasi_');
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
    try {
      await mongoService.getCollection('aspirasi').deleteMany({'_id': {'\$regex': '^test-aspsv-'}});
    } catch (_) {}
    await HiveService.init();
    await HiveService.aspirasiBox.clear();
    await HiveService.queueBox.clear();
  });

  tearDown(() async {
    try {
      if (mongoService.isConnected) {
        await mongoService.getCollection('aspirasi').deleteMany({'_id': {'\$regex': '^test-aspsv-'}});
      }
    } catch (_) {}
  });

  group('AspirasiService - Offline & Sync Integration Tests', () {
    test('fetchAllAspirasi offline read and online sync/caching', () async {
      final sample = AspirasiModel(
        id: 'test-aspsv-001',
        topik: 'Topik Tes',
        isiSaran: 'Saran ini panjang sekali agar lolos validasi input.',
        pelaporId: 'usr-1',
        upvoteCount: 5,
        upvoterIds: const [],
        status: StatusAspirasi.open,
        kategori: KategoriAspirasi.umum,
        createdAt: DateTime.now(),
      );

      // Save directly to MongoDB to simulate remote data
      await mongoService.insertData('aspirasi', sample.toJson());

      // Fetch online -> should pull from remote and populate local Hive
      isNetworkOnline = true;
      final onlineData = await aspirasiService.fetchAllAspirasi();
      expect(onlineData.any((a) => a.id == 'test-aspsv-001'), isTrue);

      // Now go offline and verify it reads from Hive cache
      isNetworkOnline = false;
      final offlineData = await aspirasiService.fetchAllAspirasi();
      expect(offlineData.any((a) => a.id == 'test-aspsv-001'), isTrue);
    });

    test('createAspirasi offline queuing and online synchronization', () async {
      final sample = AspirasiModel(
        id: 'test-aspsv-002',
        topik: 'Topik Offline',
        isiSaran: 'Saran offline ini juga panjang sekali agar lolos.',
        pelaporId: 'usr-2',
        upvoteCount: 0,
        upvoterIds: const [],
        status: StatusAspirasi.open,
        kategori: KategoriAspirasi.umum,
        createdAt: DateTime.now(),
      );

      // Go offline and create
      isNetworkOnline = false;
      await aspirasiService.createAspirasi(sample);

      // Verify cached in Hive as pending
      final cached = HiveService.aspirasiBox.get(sample.id);
      expect(cached, isNotNull);
      expect(cached['syncStatus'], equals('pending'));

      // Verify queued in SyncQueueService
      final queueItems = await syncQueueService.pendingItems(collection: 'aspirasi');
      expect(queueItems.length, equals(1));
      expect(queueItems.first['documentId'], equals(sample.id));

      // Verify not yet in MongoDB
      final remoteSearch = await mongoService.fetchByField('aspirasi', '_id', sample.id);
      expect(remoteSearch, isEmpty);

      // Go online and trigger sync
      isNetworkOnline = true;
      await AspirasiSyncService().syncPending();

      // Verify queue is processed
      final updatedQueue = await syncQueueService.pendingItems(collection: 'aspirasi');
      expect(updatedQueue, isEmpty);

      // Verify saved in MongoDB and local box updated to synced
      final remoteSearchSynced = await mongoService.fetchByField('aspirasi', '_id', sample.id);
      expect(remoteSearchSynced, isNotEmpty);
      expect(remoteSearchSynced.first['syncStatus'], equals('synced'));

      final cachedSynced = HiveService.aspirasiBox.get(sample.id);
      expect(cachedSynced['syncStatus'], equals('synced'));
    });

    test('updateAspirasi (voting) offline queuing and online sync', () async {
      final sample = AspirasiModel(
        id: 'test-aspsv-003',
        topik: 'Topik Vote',
        isiSaran: 'Isi saran ini dibuat panjang juga demi kenyamanan.',
        pelaporId: 'usr-3',
        upvoteCount: 0,
        upvoterIds: const [],
        status: StatusAspirasi.open,
        kategori: KategoriAspirasi.umum,
        createdAt: DateTime.now(),
      );

      // Save initial state online
      isNetworkOnline = true;
      await aspirasiService.createAspirasi(sample);

      // Verify no queue and synced
      expect(await syncQueueService.pendingItems(collection: 'aspirasi'), isEmpty);

      // Go offline and update (simulate upvote)
      isNetworkOnline = false;
      final updated = sample.copyWith(
        upvoteCount: 1,
        upvoterIds: ['usr-test'],
      );
      await aspirasiService.updateAspirasi(updated);

      // Verify Hive is updated to pending
      final cached = HiveService.aspirasiBox.get(sample.id);
      expect(cached['upvoteCount'], equals(1));
      expect(cached['syncStatus'], equals('pending'));

      // Go online and sync
      isNetworkOnline = true;
      await AspirasiSyncService().syncPending();

      // Verify MongoDB updated
      final remote = await mongoService.fetchByField('aspirasi', '_id', sample.id);
      expect(remote, isNotEmpty);
      expect(remote.first['upvoteCount'], equals(1));
      expect(remote.first['syncStatus'], equals('synced'));
    });

    test('deleteAspirasi offline queuing and online sync', () async {
      final sample = AspirasiModel(
        id: 'test-aspsv-004',
        topik: 'Topik Hapus',
        isiSaran: 'Isi saran ini panjang agar lolos pengujian hapus.',
        pelaporId: 'usr-4',
        upvoteCount: 0,
        upvoterIds: const [],
        status: StatusAspirasi.open,
        kategori: KategoriAspirasi.umum,
        createdAt: DateTime.now(),
      );

      // Save initial state online
      isNetworkOnline = true;
      await aspirasiService.createAspirasi(sample);

      // Go offline and delete
      isNetworkOnline = false;
      await aspirasiService.deleteAspirasi(sample.id);

      // Verify marked as deleted locally
      final cached = HiveService.aspirasiBox.get(sample.id);
      expect(cached['syncStatus'], equals('deleted'));

      // Verify not yet deleted in MongoDB
      final remote = await mongoService.fetchByField('aspirasi', '_id', sample.id);
      expect(remote, isNotEmpty);

      // Go online and sync
      isNetworkOnline = true;
      await AspirasiSyncService().syncPending();

      // Verify completely deleted from MongoDB and Hive
      final remoteDeleted = await mongoService.fetchByField('aspirasi', '_id', sample.id);
      expect(remoteDeleted, isEmpty);

      final cachedDeleted = HiveService.aspirasiBox.get(sample.id);
      expect(cachedDeleted, isNull);
    });
  });
}
