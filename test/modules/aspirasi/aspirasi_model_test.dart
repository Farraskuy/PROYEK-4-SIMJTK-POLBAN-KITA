import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/model/aspirasi_model.dart';

void main() {
  group('AspirasiModel Tests', () {
    test('fromJson and toJson roundtrip', () {
      final json = <String, dynamic>{
        '_id': 'asp-001',
        'topik': 'Topik Test',
        'isiSaran': 'Isi saran test yang lumayan panjang',
        'pelaporId': 'usr-1',
        'pelaporName': 'Tester',
        'pelaporProdi': 'D4 TI',
        'upvoteCount': 5,
        'downvoteCount': 1,
        'upvoterIds': ['usr-2', 'usr-3'],
        'downvoterIds': ['usr-4'],
        'status': 'open',
        'kategori': 'fasilitas',
        'createdAt': '2026-05-03T00:00:00.000Z',
      };

      final model = AspirasiModel.fromJson(json);

      expect(model.id, equals('asp-001'));
      expect(model.topik, equals('Topik Test'));
      expect(model.isiSaran, equals('Isi saran test yang lumayan panjang'));
      expect(model.status, equals(StatusAspirasi.open));
      expect(model.kategori, equals(KategoriAspirasi.fasilitas));
      expect(model.netVote, equals(4)); // 5 - 1
      expect(model.upvoterIds.length, equals(2));

      final generatedJson = model.toJson();
      
      expect(generatedJson['_id'], equals('asp-001'));
      expect(generatedJson['status'], equals('open'));
      expect(generatedJson['kategori'], equals('fasilitas'));
      expect(generatedJson['upvoteCount'], equals(5));
      expect(generatedJson['createdAt'], equals('2026-05-03T00:00:00.000Z'));
    });

    test('copyWith updates fields correctly', () {
      final model = AspirasiModel(
        id: 'asp-001',
        topik: 'Topik',
        isiSaran: 'Saran',
        upvoteCount: 0,
        upvoterIds: [],
        status: StatusAspirasi.open,
        kategori: KategoriAspirasi.umum,
        createdAt: DateTime.now(),
      );

      final updatedModel = model.copyWith(
        topik: 'Topik Edited',
        status: StatusAspirasi.inReview,
        upvoteCount: 1,
      );

      expect(updatedModel.id, equals('asp-001'));
      expect(updatedModel.topik, equals('Topik Edited'));
      expect(updatedModel.isiSaran, equals('Saran'));
      expect(updatedModel.status, equals(StatusAspirasi.inReview));
      expect(updatedModel.upvoteCount, equals(1));
    });

    test('Helper properties return correct values', () {
      final model = AspirasiModel(
        id: 'asp-001',
        topik: 'T',
        isiSaran: 'S',
        pelaporName: 'Budi Santoso',
        upvoteCount: 10,
        downvoteCount: 2,
        upvoterIds: [],
        status: StatusAspirasi.open,
        kategori: KategoriAspirasi.umum,
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      expect(model.initials, equals('BS'));
      expect(model.netVote, equals(8));
      expect(model.waktuRelatif, contains('jam lalu'));
    });
  });
}
