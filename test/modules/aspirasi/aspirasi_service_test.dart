import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/service/aspirasi_service.dart';

void main() {
  group('AspirasiService Tests', () {
    final aspirasiService = AspirasiService();
    final aspirasiStore = <String, Map<String, dynamic>>{};

    setUp(() {
      aspirasiStore.clear();

      AspirasiService.fetchOverride = (collection, filter) async =>
          aspirasiStore.values.toList();
      
      AspirasiService.insertOverride = (collection, data) async {
        aspirasiStore[data['_id'].toString()] = Map<String, dynamic>.from(data);
      };
      
      AspirasiService.updateOverride = (collection, id, data) async {
        aspirasiStore[id.toString()] = Map<String, dynamic>.from(data);
      };
      
      AspirasiService.deleteOverride = (collection, id) async {
        aspirasiStore.remove(id);
      };
    });

    tearDown(() {
      AspirasiService.fetchOverride = null;
      AspirasiService.insertOverride = null;
      AspirasiService.updateOverride = null;
      AspirasiService.deleteOverride = null;
    });

    test('createAspirasi should add to database', () async {
      final aspirasi = AspirasiModel(
        id: 'asp-001',
        topik: 'Topik Baru',
        isiSaran: 'Saran Baru',
        upvoteCount: 0,
        upvoterIds: [],
        status: StatusAspirasi.open,
        kategori: KategoriAspirasi.fasilitas,
        createdAt: DateTime.now(),
      );

      await aspirasiService.createAspirasi(aspirasi);
      expect(aspirasiStore.length, equals(1));
      expect(aspirasiStore['asp-001']?['topik'], equals('Topik Baru'));
    });

    test('fetchAllAspirasi should return list of aspirasi', () async {
      aspirasiStore['asp-001'] = {'_id': 'asp-001', 'topik': 'Topik 1'};
      aspirasiStore['asp-002'] = {'_id': 'asp-002', 'topik': 'Topik 2'};

      final list = await aspirasiService.fetchAllAspirasi();
      expect(list.length, equals(2));
      expect(list.any((a) => a.id == 'asp-001'), isTrue);
      expect(list.any((a) => a.id == 'asp-002'), isTrue);
    });

    test('updateAspirasi should modify existing aspirasi', () async {
      final initialAspirasi = AspirasiModel(
        id: 'asp-001',
        topik: 'Topik Lama',
        isiSaran: 'Saran Lama',
        upvoteCount: 0,
        upvoterIds: [],
        status: StatusAspirasi.open,
        kategori: KategoriAspirasi.fasilitas,
        createdAt: DateTime.now(),
      );
      
      aspirasiStore['asp-001'] = initialAspirasi.toJson();

      final updatedAspirasi = initialAspirasi.copyWith(topik: 'Topik Baru');

      await aspirasiService.updateAspirasi(updatedAspirasi);
      expect(aspirasiStore['asp-001']?['topik'], equals('Topik Baru'));
    });
  });
}
