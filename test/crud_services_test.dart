import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:proyek_4_poki_polban_kita/modules/kategori_fasilitas/model/kategori_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/kategori_fasilitas/service/kategori_fasilitas_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/service/user_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

void main() {
  late MonggoDBServices mongoService;
  final userService = UserService();
  final laporanService = LaporanFasilitasService();
  final kategoriService = KategoriFasilitasService();

  setUpAll(() async {
    final envFile = File('.env');
    if (envFile.existsSync()) {
      dotenv.loadFromString(envString: envFile.readAsStringSync());
    }
    mongoService = MonggoDBServices();
    await mongoService.connect();
  });

  tearDownAll(() async {
    await mongoService.close();
  });

  setUp(() async {
    final envFile = File('.env');
    if (envFile.existsSync()) {
      dotenv.loadFromString(envString: envFile.readAsStringSync());
    }
    await mongoService.ensureConnected();
    try {
      await mongoService.getCollection('users').deleteMany({'_id': {'\$regex': '^test-crud-'}});
      await mongoService.getCollection('laporan_fasilitas').deleteMany({'_id': {'\$regex': '^test-crud-'}});
      await mongoService.getCollection('kategori_fasilitas').deleteMany({'_id': {'\$regex': '^test-crud-'}});
    } catch (_) {}
  });

  tearDown(() async {
    try {
      if (mongoService.isConnected) {
        await mongoService.getCollection('users').deleteMany({'_id': {'\$regex': '^test-crud-'}});
        await mongoService.getCollection('laporan_fasilitas').deleteMany({'_id': {'\$regex': '^test-crud-'}});
        await mongoService.getCollection('kategori_fasilitas').deleteMany({'_id': {'\$regex': '^test-crud-'}});
      }
    } catch (_) {}
  });

  group('CRUD service tests (Real Database)', () {
    test('users CRUD roundtrip', () async {
      final user = UserModel.fromJson({
        '_id': 'test-crud-usr-001',
        'nomor_induk': '241511010',
        'password_hash': 'hash',
        'name': 'Mahasiswa',
        'role': 'mahasiswa',
        'isActive': true,
      });

      await userService.create(user);
      final all = await userService.getAll();
      expect(all.any((u) => u.id == 'test-crud-usr-001'), isTrue);
      expect(
        (await userService.getById('test-crud-usr-001'))?.username,
        equals('241511010'),
      );

      final updated = UserModel.fromJson({
        '_id': 'test-crud-usr-001',
        'nomor_induk': '241511011',
        'password_hash': 'hash-2',
        'name': 'Mahasiswa Edit',
        'role': 'mahasiswa',
        'isActive': false,
      });
      await userService.update(updated);
      expect(
        (await userService.getById('test-crud-usr-001'))?.username,
        equals('241511011'),
      );

      await userService.delete('test-crud-usr-001');
      expect(await userService.getById('test-crud-usr-001'), isNull);
    });

    test('laporan fasilitas CRUD roundtrip', () async {
      final laporan = LaporanFasilitasModel(
        id: 'test-crud-lap-001',
        judul: 'Lampu Rusak',
        deskripsi: 'Lampu kelas mati',
        lokasi: 'Lab 1',
        foto_urls: const ['a.jpg'],
        pelapor_id: 'test-crud-usr-001',
        createdAt: DateTime.parse('2026-05-03T00:00:00.000Z'),
        updatedAt: DateTime.parse('2026-05-03T00:00:00.000Z'),
      );

      await laporanService.create(laporan);
      final all = await laporanService.getAll();
      expect(all.any((l) => l.id == 'test-crud-lap-001'), isTrue);
      expect(
        (await laporanService.getById('test-crud-lap-001'))?.judul,
        equals('Lampu Rusak'),
      );

      final updated = LaporanFasilitasModel.fromJson({
        ...laporan.toJson(),
        'judul': 'Lampu Rusak Update',
      });
      await laporanService.update(updated);
      expect(
        (await laporanService.getById('test-crud-lap-001'))?.judul,
        equals('Lampu Rusak Update'),
      );

      await laporanService.delete('test-crud-lap-001');
      expect(await laporanService.getById('test-crud-lap-001'), isNull);
    });

    test('kategori fasilitas CRUD roundtrip', () async {
      final kategori = KategoriFasilitasModel(
        id: 'test-crud-kat-001',
        namaKategori: 'Jaringan',
        iconUrl: 'wifi',
        deskripsi: 'Gangguan jaringan',
      );

      await kategoriService.create(kategori);
      final all = await kategoriService.getAll();
      expect(all.any((k) => k.id == 'test-crud-kat-001'), isTrue);
      expect(
        (await kategoriService.getById('test-crud-kat-001'))?.namaKategori,
        equals('Jaringan'),
      );

      final updated = KategoriFasilitasModel.fromJson({
        ...kategori.toJson(),
        'nama_kategori': 'Jaringan Internet',
      });
      await kategoriService.update(updated);
      expect(
        (await kategoriService.getById('test-crud-kat-001'))?.namaKategori,
        equals('Jaringan Internet'),
      );

      await kategoriService.delete('test-crud-kat-001');
      expect(await kategoriService.getById('test-crud-kat-001'), isNull);
    });
  });
}
