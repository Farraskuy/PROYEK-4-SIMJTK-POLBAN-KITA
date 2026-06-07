import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/modules/kategori_fasilitas/model/kategori_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/kategori_fasilitas/service/kategori_fasilitas_service.dart';

void main() {
  group('KategoriFasilitasService Tests', () {
    final service = KategoriFasilitasService();
    final kategoriStore = <String, Map<String, dynamic>>{};

    setUp(() {
      kategoriStore.clear();

      KategoriFasilitasService.fetchOverride = (collection, filter) async =>
          kategoriStore.values.toList();
      
      KategoriFasilitasService.insertOverride = (collection, data) async {
        kategoriStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      
      KategoriFasilitasService.updateOverride = (collection, filter, data) async {
        kategoriStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      
      KategoriFasilitasService.deleteOverride = (collection, id) async {
        kategoriStore.remove(id);
      };
    });

    tearDown(() {
      KategoriFasilitasService.fetchOverride = null;
      KategoriFasilitasService.insertOverride = null;
      KategoriFasilitasService.updateOverride = null;
      KategoriFasilitasService.deleteOverride = null;
    });

    test('create should add new kategori to database', () async {
      final kategori = KategoriFasilitasModel(
        id: 'kat-001',
        namaKategori: 'Jaringan',
        iconUrl: 'wifi',
        deskripsi: 'Deskripsi Jaringan',
      );

      await service.create(kategori);
      expect(kategoriStore.length, equals(1));
      expect(kategoriStore['kat-001']?['nama_kategori'], equals('Jaringan'));
    });

    test('getAll should return list of kategori', () async {
      kategoriStore['kat-001'] = {'_id': 'kat-001', 'nama_kategori': 'Jaringan'};
      kategoriStore['kat-002'] = {'_id': 'kat-002', 'nama_kategori': 'Listrik'};

      final list = await service.getAll();
      expect(list.length, equals(2));
      expect(list.any((k) => k.id == 'kat-001'), isTrue);
    });

    test('getById should return specific kategori', () async {
      kategoriStore['kat-001'] = {'_id': 'kat-001', 'nama_kategori': 'Jaringan'};

      final result = await service.getById('kat-001');
      expect(result, isNotNull);
      expect(result?.namaKategori, equals('Jaringan'));
    });

    test('update should modify existing kategori', () async {
      final initialKategori = KategoriFasilitasModel(
        id: 'kat-001',
        namaKategori: 'Lama',
        iconUrl: 'icon',
        deskripsi: 'desc',
      );
      
      kategoriStore['kat-001'] = initialKategori.toJson();

      final updatedKategori = KategoriFasilitasModel.fromJson({
        ...initialKategori.toJson(),
        'nama_kategori': 'Baru',
      });

      await service.update(updatedKategori);
      expect(kategoriStore['kat-001']?['nama_kategori'], equals('Baru'));
    });

    test('delete should remove kategori from database', () async {
      kategoriStore['kat-001'] = {'_id': 'kat-001', 'nama_kategori': 'Jaringan'};

      await service.delete('kat-001');
      expect(kategoriStore.containsKey('kat-001'), isFalse);
    });
  });
}
