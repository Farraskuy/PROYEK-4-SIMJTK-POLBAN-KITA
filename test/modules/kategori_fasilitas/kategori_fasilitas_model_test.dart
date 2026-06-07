import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/modules/kategori_fasilitas/model/kategori_fasilitas_model.dart';

void main() {
  group('KategoriFasilitasModel Tests', () {
    test('fromJson and toJson roundtrip', () {
      final json = <String, dynamic>{
        '_id': 'kat-001',
        'nama_kategori': 'Jaringan',
        'icon_url': 'wifi',
        'deskripsi': 'Masalah jaringan internet dan intranet',
        'created_at': '2026-05-01T00:00:00.000Z',
        'updated_at': '2026-05-01T00:00:00.000Z',
      };

      final model = KategoriFasilitasModel.fromJson(json);

      expect(model.id, equals('kat-001'));
      expect(model.namaKategori, equals('Jaringan'));
      expect(model.iconUrl, equals('wifi'));
      expect(model.deskripsi, equals('Masalah jaringan internet dan intranet'));

      final generatedJson = model.toJson();
      
      expect(generatedJson['_id'], equals('kat-001'));
      expect(generatedJson['nama_kategori'], equals('Jaringan'));
      expect(generatedJson['icon_url'], equals('wifi'));
      expect(generatedJson['deskripsi'], equals('Masalah jaringan internet dan intranet'));
    });

    test('dummyList returns a list of dummy data', () {
      final list = KategoriFasilitasModel.dummyList();
      expect(list, isNotEmpty);
      expect(list.first.id, isNotEmpty);
      expect(list.first.namaKategori, isNotEmpty);
    });
  });
}
