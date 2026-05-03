import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/modules/kategori_fasilitas/model/kategori_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/kategori_fasilitas/service/kategori_fasilitas_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/log_harian_teknis/model/log_harian_teknis_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/log_harian_teknis/service/log_harian_teknis_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/service/user_service.dart';

void main() {
  group('CRUD service tests', () {
    final userService = UserService();
    final laporanService = LaporanFasilitasService();
    final kategoriService = KategoriFasilitasService();
    final logService = LogHarianTeknisService();

    final userStore = <String, Map<String, dynamic>>{};
    final laporanStore = <String, Map<String, dynamic>>{};
    final kategoriStore = <String, Map<String, dynamic>>{};
    final logStore = <String, Map<String, dynamic>>{};

    setUp(() {
      userStore.clear();
      laporanStore.clear();
      kategoriStore.clear();
      logStore.clear();

      UserService.fetchOverride = (collection, filter) async => userStore.values.toList();
      UserService.insertOverride = (collection, data) async {
        userStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      UserService.updateOverride = (collection, filter, data) async {
        userStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      UserService.deleteOverride = (collection, id) async {
        userStore.remove(id);
      };

      LaporanFasilitasService.fetchOverride = (collection, filter) async => laporanStore.values.toList();
      LaporanFasilitasService.insertOverride = (collection, data) async {
        laporanStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      LaporanFasilitasService.updateOverride = (collection, filter, data) async {
        laporanStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      LaporanFasilitasService.deleteOverride = (collection, id) async {
        laporanStore.remove(id);
      };

      KategoriFasilitasService.fetchOverride = (collection, filter) async => kategoriStore.values.toList();
      KategoriFasilitasService.insertOverride = (collection, data) async {
        kategoriStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      KategoriFasilitasService.updateOverride = (collection, filter, data) async {
        kategoriStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      KategoriFasilitasService.deleteOverride = (collection, id) async {
        kategoriStore.remove(id);
      };

      LogHarianTeknisService.fetchOverride = (collection, filter) async => logStore.values.toList();
      LogHarianTeknisService.insertOverride = (collection, data) async {
        logStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      LogHarianTeknisService.updateOverride = (collection, filter, data) async {
        logStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      LogHarianTeknisService.deleteOverride = (collection, id) async {
        logStore.remove(id);
      };
    });

    tearDown(() {
      UserService.fetchOverride = null;
      UserService.insertOverride = null;
      UserService.updateOverride = null;
      UserService.deleteOverride = null;

      LaporanFasilitasService.fetchOverride = null;
      LaporanFasilitasService.insertOverride = null;
      LaporanFasilitasService.updateOverride = null;
      LaporanFasilitasService.deleteOverride = null;

      KategoriFasilitasService.fetchOverride = null;
      KategoriFasilitasService.insertOverride = null;
      KategoriFasilitasService.updateOverride = null;
      KategoriFasilitasService.deleteOverride = null;

      LogHarianTeknisService.fetchOverride = null;
      LogHarianTeknisService.insertOverride = null;
      LogHarianTeknisService.updateOverride = null;
      LogHarianTeknisService.deleteOverride = null;
    });

    test('users CRUD roundtrip', () async {
      final user = UserModel.fromJson({
        '_id': 'usr-001',
        'nomor_induk': '241511010',
        'password_hash': 'hash',
        'name': 'Mahasiswa',
        'role': 'mahasiswa',
        'isActive': true,
      });

      await userService.create(user);
      expect((await userService.getAll()).length, equals(1));
      expect((await userService.getById('usr-001'))?.username, equals('241511010'));

      final updated = UserModel.fromJson({
        '_id': 'usr-001',
        'nomor_induk': '241511011',
        'password_hash': 'hash-2',
        'name': 'Mahasiswa Edit',
        'role': 'mahasiswa',
        'isActive': false,
      });
      await userService.update(updated);
      expect((await userService.getById('usr-001'))?.username, equals('241511011'));

      await userService.delete('usr-001');
      expect(await userService.getById('usr-001'), isNull);
    });

    test('laporan fasilitas CRUD roundtrip', () async {
      final laporan = LaporanFasilitasModel(
        id: 'lap-001',
        judul: 'Lampu Rusak',
        deskripsi: 'Lampu kelas mati',
        kategoriId: 'kat-001',
        lokasiLabKelas: 'Lab 1',
        fotoUrls: const ['a.jpg'],
        pelaporId: 'usr-001',
        createdAt: DateTime.parse('2026-05-03T00:00:00.000Z'),
        updatedAt: DateTime.parse('2026-05-03T00:00:00.000Z'),
      );

      await laporanService.create(laporan);
      expect((await laporanService.getAll()).length, equals(1));
      expect((await laporanService.getById('lap-001'))?.judul, equals('Lampu Rusak'));

      final updated = LaporanFasilitasModel.fromJson({
        ...laporan.toJson(),
        'judul': 'Lampu Rusak Update',
      });
      await laporanService.update(updated);
      expect((await laporanService.getById('lap-001'))?.judul, equals('Lampu Rusak Update'));

      await laporanService.delete('lap-001');
      expect(await laporanService.getById('lap-001'), isNull);
    });

    test('kategori fasilitas CRUD roundtrip', () async {
      final kategori = KategoriFasilitasModel(
        id: 'kat-001',
        namaKategori: 'Jaringan',
        iconUrl: 'wifi',
        deskripsi: 'Gangguan jaringan',
      );

      await kategoriService.create(kategori);
      expect((await kategoriService.getAll()).length, equals(1));
      expect((await kategoriService.getById('kat-001'))?.namaKategori, equals('Jaringan'));

      final updated = KategoriFasilitasModel.fromJson({
        ...kategori.toJson(),
        'nama_kategori': 'Jaringan Internet',
      });
      await kategoriService.update(updated);
      expect((await kategoriService.getById('kat-001'))?.namaKategori, equals('Jaringan Internet'));

      await kategoriService.delete('kat-001');
      expect(await kategoriService.getById('kat-001'), isNull);
    });

    test('log harian teknis CRUD roundtrip', () async {
      final log = LogHarianTeknisModel(
        id: 'log-001',
        teknisiId: 'user-t1',
        tanggal: DateTime.parse('2026-05-03T00:00:00.000Z'),
        kegiatan: 'Perbaikan AC',
        lokasi: 'Ruang 101',
        keterangan: 'AC kembali dingin',
        createdAt: DateTime.parse('2026-05-03T00:00:00.000Z'),
      );

      await logService.create(log);
      expect((await logService.getAll()).length, equals(1));
      expect((await logService.getById('log-001'))?.kegiatan, equals('Perbaikan AC'));

      final updated = LogHarianTeknisModel.fromJson({
        ...log.toJson(),
        'kegiatan': 'Perbaikan AC dan pembersihan filter',
      });
      await logService.update(updated);
      expect(
        (await logService.getById('log-001'))?.kegiatan,
        equals('Perbaikan AC dan pembersihan filter'),
      );

      await logService.delete('log-001');
      expect(await logService.getById('log-001'), isNull);
    });
  });
}