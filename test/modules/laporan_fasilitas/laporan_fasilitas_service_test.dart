import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_service.dart';

void main() {
  group('LaporanFasilitasService Tests', () {
    final service = LaporanFasilitasService();
    final laporanStore = <String, Map<String, dynamic>>{};

    setUp(() {
      laporanStore.clear();

      LaporanFasilitasService.fetchOverride = (collection, filter) async =>
          laporanStore.values.toList();
      
      LaporanFasilitasService.insertOverride = (collection, data) async {
        laporanStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      
      LaporanFasilitasService.updateOverride = (collection, filter, data) async {
        laporanStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      
      LaporanFasilitasService.deleteOverride = (collection, id) async {
        laporanStore.remove(id);
      };
    });

    tearDown(() {
      LaporanFasilitasService.fetchOverride = null;
      LaporanFasilitasService.insertOverride = null;
      LaporanFasilitasService.updateOverride = null;
      LaporanFasilitasService.deleteOverride = null;
    });

    test('create should add to database', () async {
      final laporan = LaporanFasilitasModel(
        id: 'lap-001',
        judul: 'AC Rusak',
        deskripsi: 'AC panas',
        lokasi: 'Lab Jaringan',
        foto_urls: [],
        pelapor_id: 'usr-001',
        status: StatusLaporan.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await service.create(laporan);
      expect(laporanStore.length, equals(1));
      expect(laporanStore['lap-001']?['judul'], equals('AC Rusak'));
    });

    test('getAll should return list of laporan', () async {
      laporanStore['lap-001'] = {'_id': 'lap-001', 'judul': 'A'};
      laporanStore['lap-002'] = {'_id': 'lap-002', 'judul': 'B'};

      final list = await service.getAll();
      expect(list.length, equals(2));
      expect(list.any((l) => l.id == 'lap-001'), isTrue);
    });

    test('update should modify existing laporan', () async {
      final oldModel = LaporanFasilitasModel(
        id: 'lap-001',
        judul: 'A',
        deskripsi: 'B',
        lokasi: 'C',
        foto_urls: [],
        pelapor_id: 'usr-1',
        status: StatusLaporan.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      laporanStore['lap-001'] = oldModel.toJson();

      final newModel = LaporanFasilitasModel.fromJson({
        ...oldModel.toJson(),
        'judul': 'A Baru',
      });

      await service.update(newModel);
      expect(laporanStore['lap-001']?['judul'], equals('A Baru'));
    });

    test('delete should remove laporan', () async {
      laporanStore['lap-001'] = {'_id': 'lap-001', 'judul': 'A'};

      await service.delete('lap-001');
      expect(laporanStore.containsKey('lap-001'), isFalse);
    });
  });
}
