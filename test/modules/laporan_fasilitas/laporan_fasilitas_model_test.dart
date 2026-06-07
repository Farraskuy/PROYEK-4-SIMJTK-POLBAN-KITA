import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';

void main() {
  group('LaporanFasilitasModel Tests', () {
    test('fromJson and toJson roundtrip', () {
      final json = <String, dynamic>{
        '_id': 'lap-001',
        'judul': 'Lampu Rusak',
        'deskripsi': 'Lampu depan kelas mati',
        'lokasi': 'Gedung A',
        'foto_urls': ['https://example.test/foto1.png'],
        'pelapor_id': 'usr-001',
        'teknisi_id': 'tek-001',
        'status': 'in_progress',
        'vote_score': 10,
        'upvoter_ids': ['usr-2'],
        'downvoter_ids': [],
        'created_at': '2026-05-01T00:00:00.000Z',
        'updated_at': '2026-05-02T00:00:00.000Z',
        'catatan_petugas': 'Akan diperbaiki besok',
      };

      final model = LaporanFasilitasModel.fromJson(json);

      expect(model.id, equals('lap-001'));
      expect(model.judul, equals('Lampu Rusak'));
      expect(model.deskripsi, equals('Lampu depan kelas mati'));
      expect(model.lokasi, equals('Gedung A'));
      expect(model.foto_urls, contains('https://example.test/foto1.png'));
      expect(model.status, equals(StatusLaporan.in_progress));
      expect(model.vote_score, equals(10));

      final generatedJson = model.toJson();
      
      expect(generatedJson['_id'], equals('lap-001'));
      expect(generatedJson['judul'], equals('Lampu Rusak'));
      expect(generatedJson['status'], equals('in_progress'));
      expect(generatedJson['catatan_petugas'], equals('Akan diperbaiki besok'));
    });

    test('Helper functions check correct status', () {
      final model = LaporanFasilitasModel(
        id: 'lap-001',
        judul: 'A',
        deskripsi: 'B',
        lokasi: 'C',
        foto_urls: [],
        pelapor_id: 'usr-1',
        status: StatusLaporan.escalated_to_upt.value,
        printedAt: '2026-05-01',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(model.diajukanKeTu, isTrue);
      expect(model.sudahDicetak, isTrue);
    });
  });
}
