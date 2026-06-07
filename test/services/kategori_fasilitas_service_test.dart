import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:proyek_4_poki_polban_kita/modules/kategori_fasilitas/model/kategori_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/kategori_fasilitas/service/kategori_fasilitas_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/hive_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

void main() {
  late MonggoDBServices mongoService;
  final kategoriService = KategoriFasilitasService();
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

    final tempDir = Directory.systemTemp.createTempSync('test_hive_kategori_');
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
      await mongoService.getCollection('kategori_fasilitas').deleteMany({'_id': {'\$regex': '^test-katsv-'}});
    } catch (_) {}
    await HiveService.init();
    await HiveService.kategoriBox.clear();
  });

  tearDown(() async {
    try {
      if (mongoService.isConnected) {
        await mongoService.getCollection('kategori_fasilitas').deleteMany({'_id': {'\$regex': '^test-katsv-'}});
      }
    } catch (_) {}
  });

  group('KategoriFasilitasService - Local Caching & Fallback Tests', () {
    test('getAll online pulls from remote and populates Hive, offline reads from Hive cache', () async {
      final sample = KategoriFasilitasModel(
        id: 'test-katsv-001',
        namaKategori: 'Kategori Tes',
        iconUrl: 'build',
        deskripsi: 'Deskripsi kategori tes.',
      );

      // Save directly to MongoDB to simulate remote seed
      await mongoService.insertData('kategori_fasilitas', sample.toJson());

      // Fetch online -> should pull from remote and populate Hive
      isNetworkOnline = true;
      final onlineData = await kategoriService.getAll();
      expect(onlineData.any((k) => k.id == 'test-katsv-001'), isTrue);

      // Now verify Hive contains the cached item
      final cachedVal = HiveService.kategoriBox.get(sample.id);
      expect(cachedVal, isNotNull);
      expect(cachedVal['nama_kategori'], equals('Kategori Tes'));

      // Go offline -> should fetch fallback from local Hive
      isNetworkOnline = false;
      final offlineData = await kategoriService.getAll();
      expect(offlineData.any((k) => k.id == 'test-katsv-001'), isTrue);
    });

    test('create, update, and delete updates both remote and local box', () async {
      final sample = KategoriFasilitasModel(
        id: 'test-katsv-002',
        namaKategori: 'Kategori Crud',
        iconUrl: 'settings',
        deskripsi: 'Deskripsi crud.',
      );

      // Test create
      isNetworkOnline = true;
      await kategoriService.create(sample);

      // Verify stored in remote
      final remoteSearch = await mongoService.fetchByField('kategori_fasilitas', '_id', sample.id);
      expect(remoteSearch, isNotEmpty);

      // Verify stored in local box
      final cached = HiveService.kategoriBox.get(sample.id);
      expect(cached, isNotNull);
      expect(cached['nama_kategori'], equals('Kategori Crud'));

      // Test update
      final updated = KategoriFasilitasModel(
        id: sample.id,
        namaKategori: 'Kategori Crud Edited',
        iconUrl: 'settings',
        deskripsi: 'Deskripsi edited.',
      );
      await kategoriService.update(updated);

      // Verify updated remote and local
      final remoteUpdated = await mongoService.fetchByField('kategori_fasilitas', '_id', sample.id);
      expect(remoteUpdated.first['nama_kategori'], equals('Kategori Crud Edited'));

      final cachedUpdated = HiveService.kategoriBox.get(sample.id);
      expect(cachedUpdated['nama_kategori'], equals('Kategori Crud Edited'));

      // Test delete
      await kategoriService.delete(sample.id);

      // Verify deleted from both remote and local
      final remoteDeleted = await mongoService.fetchByField('kategori_fasilitas', '_id', sample.id);
      expect(remoteDeleted, isEmpty);

      final cachedDeleted = HiveService.kategoriBox.get(sample.id);
      expect(cachedDeleted, isNull);
    });
  });
}
