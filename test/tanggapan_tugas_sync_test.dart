import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mongo_dart/mongo_dart.dart' hide Box;
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/tanggapan_tugas_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

void main() {
  late Directory tempDir;
  late MonggoDBServices mongoService;
  final tanggapanService = TanggapanTugasService();

  const testLaporanId = 'test-lap-12345';
  const testTeknisiId = 'test-tek-12345';

  setUpAll(() async {
    // 1. Load env
    final envFile = File('.env');
    if (envFile.existsSync()) {
      dotenv.loadFromString(envString: envFile.readAsStringSync());
    }

    // 2. Initialize Hive in a temp directory to isolate test boxes
    tempDir = Directory.systemTemp.createTempSync('hive_test_');
    Hive.init(tempDir.path);

    // 3. Connect to MongoDB
    mongoService = MonggoDBServices();
    await mongoService.connect();

    // Clean up any previous test remnants first
    try {
      await mongoService.getCollection('laporan_fasilitas').deleteOne({'_id': testLaporanId});
      await mongoService.getCollection('analisa_kerusakan').deleteOne({'laporan_id': testLaporanId});
    } catch (_) {}

    // 4. Insert dummy report in MongoDB
    // TanggapanTugasService.sync updates 'laporan_fasilitas', so we need a report document
    await mongoService.insertData('laporan_fasilitas', {
      '_id': testLaporanId,
      'judul': 'Test Laporan Fasilitas',
      'deskripsi': 'Kerusakan lampu test',
      'lokasi': 'Test Room',
      'foto_urls': ['https://res.cloudinary.com/test.png'],
      'pelapor_id': 'test-pelapor',
      'status': StatusLaporan.pending.value,
      'vote_score': 0,
      'upvoter_ids': [],
      'downvoter_ids': [],
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });
  });

  tearDownAll(() async {
    // 1. Clean up MongoDB test data
    try {
      if (mongoService.isConnected) {
        await mongoService.getCollection('laporan_fasilitas').deleteOne({'_id': testLaporanId});
        await mongoService.getCollection('analisa_kerusakan').deleteOne({'laporan_id': testLaporanId});
      }
    } catch (e) {
      print('Gagal membersihkan database setelah pengujian: $e');
    }

    // 2. Close MongoDB
    await mongoService.close();

    // 3. Close Hive and delete temp folder
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('TanggapanTugasService - Offline & Online CRUD Integration Test', () {
    test('1. Offline CRUD: Menyimpan draf tanggapan ke Hive lokal', () async {
      final localData = {
        'analisa_masalah': 'Kabel terputus di plafon',
        'estimasi_waktu': '2 jam',
        // Menggunakan URL http/https agar memintas Cloudinary upload di unit test
        'foto_analisa_urls': ['https://res.cloudinary.com/test_analisa.jpg'],
        'teknisi_id': testTeknisiId,
        'form_status': 'proses',
      };

      // Simpan draf dengan pendingSync = true (merepresentasikan kondisi offline)
      await tanggapanService.saveLocal(
        testLaporanId,
        localData,
        pendingSync: true,
      );

      // Ambil kembali draf dari Hive
      final draft = await tanggapanService.getDraft(testLaporanId);

      expect(draft, isNotNull);
      expect(draft!['analisa_masalah'], equals('Kabel terputus di plafon'));
      expect(draft['pending_sync'], isTrue);
      expect(draft['teknisi_id'], equals(testTeknisiId));
    });

    test('2. Online Sync: Sinkronisasi draf dari Hive ke MongoDB', () async {
      // Pastikan data ada di Hive lokal dari test sebelumnya
      final draftSebelum = await tanggapanService.getDraft(testLaporanId);
      expect(draftSebelum, isNotNull);
      expect(draftSebelum!['pending_sync'], isTrue);

      // Jalankan sinkronisasi (TanggapanTugasService akan membaca draf berstatus pending_sync = true)
      await tanggapanService.syncPendingDrafts();

      // 1. Verifikasi status sinkronisasi di Hive lokal (sekarang pending_sync harus false)
      final draftSesudah = await tanggapanService.getDraft(testLaporanId);
      expect(draftSesudah, isNotNull);
      expect(draftSesudah!['pending_sync'], isFalse);
      expect(draftSesudah['sync_status'], equals('synced'));

      // 2. Verifikasi data terunggah di MongoDB Atlas (analisa_kerusakan)
      final databaseRows = await mongoService.fetch(
        'analisa_kerusakan',
        where.eq('laporan_id', testLaporanId),
      );
      expect(databaseRows.length, equals(1));
      expect(databaseRows.first['analisa_masalah'], equals('Kabel terputus di plafon'));
      expect(databaseRows.first['teknisi_id'], equals(testTeknisiId));

      // 3. Verifikasi update status di laporan_fasilitas di MongoDB
      final laporanRow = await mongoService.fetch(
        'laporan_fasilitas',
        where.eq('_id', testLaporanId),
      );
      expect(laporanRow.length, equals(1));
      // Status laporan harus ter-update menjadi 'in_progress' karena form_status = 'proses'
      expect(laporanRow.first['status'], equals(StatusLaporan.in_progress.value));
      expect(laporanRow.first['teknisi_id'], equals(testTeknisiId));
    });
  });
}
