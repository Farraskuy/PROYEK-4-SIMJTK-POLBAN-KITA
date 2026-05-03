import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/academic_calendar_service.dart';

void main() {
  final service = AcademicCalendarService();

  test('extract source PDF dari .df-shortcode-script', () {
    const html = '''
      <html>
        <body>
          <script class="df-shortcode-script">
            window.option_df_21365 = {"webgl":"true","source":"https:\\/\\/www.polban.ac.id\\/wp-content\\/uploads\\/2025\\/10\\/Kalender_Akademik_Semester_Ganjil_dan_Genap_TA_2025-2026.pdf"};
          </script>
        </body>
      </html>
    ''';

    final cleanUrl = service.extractPdfSourceFromScript(html);

    expect(cleanUrl, isNotNull);
    expect(
      cleanUrl,
      equals(
        'https://www.polban.ac.id/wp-content/uploads/2025/10/Kalender_Akademik_Semester_Ganjil_dan_Genap_TA_2025-2026.pdf',
      ),
    );
  });

  test('analisis tabel kalender akademik dari teks PDF', () {
    const pdfLikeText = '''
      No Tanggal Kegiatan
      1 1 - 5 Juli 2025 Registrasi Administrasi Mahasiswa
      2 8 Juli 2025 Awal Perkuliahan Semester Ganjil
      3 17 Agustus 2025 Libur Nasional Hari Kemerdekaan Republik Indonesia
    ''';

    final entries = service.extractEntriesFromPdfText(pdfLikeText);

    expect(entries.length, equals(3));
    expect(entries[0].dateLabel, equals('1 - 5 Juli 2025'));
    expect(entries[0].activity, contains('Registrasi Administrasi Mahasiswa'));

    expect(entries[1].dateLabel, equals('8 Juli 2025'));
    expect(entries[1].activity, contains('Awal Perkuliahan Semester Ganjil'));

    expect(entries[2].dateLabel, equals('17 Agustus 2025'));
    expect(
      entries[2].activity,
      contains('Libur Nasional Hari Kemerdekaan Republik Indonesia'),
    );

    final tableOutput = service.formatEntriesAsTable(entries);
    expect(tableOutput, contains('Tanggal'));
    expect(tableOutput, contains('Kegiatan'));
    expect(tableOutput, contains('1 - 5 Juli 2025'));

    // Menampilkan hasil akhir dalam bentuk tabel pada output test.
    service.printEntriesAsTable(entries);
  });
}
