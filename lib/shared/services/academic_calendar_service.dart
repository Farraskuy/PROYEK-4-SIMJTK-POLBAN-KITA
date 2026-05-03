import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class AcademicCalendarEntry {
  const AcademicCalendarEntry({
    required this.dateLabel,
    required this.activity,
  });

  final String dateLabel;
  final String activity;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'dateLabel': dateLabel,
      'activity': activity,
    };
  }

  factory AcademicCalendarEntry.fromJson(Map<String, dynamic> json) {
    return AcademicCalendarEntry(
      dateLabel: (json['dateLabel'] ?? '').toString(),
      activity: (json['activity'] ?? '').toString(),
    );
  }
}

class AcademicCalendarData {
  const AcademicCalendarData({
    required this.pageUrl,
    required this.sourcePdfUrl,
    required this.updatedAt,
    required this.entries,
    required this.fromCache,
  });

  final String pageUrl;
  final String sourcePdfUrl;
  final DateTime updatedAt;
  final List<AcademicCalendarEntry> entries;
  final bool fromCache;
}

class _CalendarRowParts {
  const _CalendarRowParts({
    required this.dateLabel,
    required this.activity,
  });

  final String dateLabel;
  final String activity;
}

class AcademicCalendarService {
  AcademicCalendarService({
    http.Client? httpClient,
    Future<SharedPreferences> Function()? prefsFactory,
    DateTime Function()? now,
  })  : _httpClient = httpClient ?? http.Client(),
        _prefsFactory = prefsFactory ?? SharedPreferences.getInstance,
        _now = now ?? DateTime.now;

  static const String calendarPageUrl =
      'https://www.polban.ac.id/tentang-polban/kalender-akademik/';

  static const Duration refreshInterval = Duration(days: 30);

  static const String _cacheKeyPdfUrl = 'academic_calendar_pdf_url';
  static const String _cacheKeyUpdatedAt = 'academic_calendar_updated_at';
  static const String _cacheKeyEntries = 'academic_calendar_entries';

  final http.Client _httpClient;
  final Future<SharedPreferences> Function() _prefsFactory;
  final DateTime Function() _now;

  Future<AcademicCalendarData> getAcademicCalendar({
    bool forceRefresh = false,
  }) async {
    final prefs = await _prefsFactory();
    final cached = _readCache(prefs);

    final cacheStillValid = cached != null && _now().difference(cached.updatedAt) < refreshInterval;
    if (!forceRefresh && cacheStillValid) {
      return cached;
    }

    try {
      final pageResponse = await _httpClient.get(Uri.parse(calendarPageUrl));
      if (pageResponse.statusCode != 200) {
        throw Exception(
          'Gagal mengambil halaman kalender akademik (HTTP ${pageResponse.statusCode}).',
        );
      }

      final sourcePdfUrl = extractPdfSourceFromScript(pageResponse.body);
      if (sourcePdfUrl == null || sourcePdfUrl.isEmpty) {
        throw Exception('URL source PDF tidak ditemukan pada halaman kalender.');
      }

      final pdfResponse = await _httpClient.get(Uri.parse(sourcePdfUrl));
      if (pdfResponse.statusCode != 200) {
        throw Exception(
          'Gagal mengambil PDF kalender akademik (HTTP ${pdfResponse.statusCode}).',
        );
      }

      final entries = _parseEntriesFromPdfBytes(pdfResponse.bodyBytes);
      final fresh = AcademicCalendarData(
        pageUrl: calendarPageUrl,
        sourcePdfUrl: sourcePdfUrl,
        updatedAt: _now(),
        entries: entries,
        fromCache: false,
      );

      await _writeCache(prefs, fresh);
      return fresh;
    } catch (_) {
      if (cached != null) {
        return AcademicCalendarData(
          pageUrl: cached.pageUrl,
          sourcePdfUrl: cached.sourcePdfUrl,
          updatedAt: cached.updatedAt,
          entries: cached.entries,
          fromCache: true,
        );
      }
      rethrow;
    }
  }

  @visibleForTesting
  String? extractPdfSourceFromScript(String htmlDocument) {
    final document = html_parser.parse(htmlDocument);
    final scriptText = document.querySelector('.df-shortcode-script')?.text;
    if (scriptText == null || scriptText.trim().isEmpty) {
      return null;
    }

    final sourceRegex = RegExp(r'"source"\s*:\s*"([^"]+)"');
    final match = sourceRegex.firstMatch(scriptText);
    if (match == null) {
      return null;
    }

    final rawUrl = match.group(1)!;
    final cleanUrl = rawUrl.replaceAll(r'\/', '/');

    if (cleanUrl.startsWith('//')) {
      return 'https:$cleanUrl';
    }

    return cleanUrl;
  }

  @visibleForTesting
  List<AcademicCalendarEntry> extractEntriesFromPdfText(String pdfText) {
    return _extractEntriesFromPdfText(pdfText);
  }

  String formatEntriesAsTable(
    List<AcademicCalendarEntry> entries, {
    int maxDateWidth = 24,
    int maxActivityWidth = 72,
  }) {
    final dateHeader = 'Tanggal';
    final activityHeader = 'Kegiatan';

    final computedDateWidth = entries
        .map((entry) => entry.dateLabel.length)
        .fold(dateHeader.length, (prev, len) => len > prev ? len : prev);
    final computedActivityWidth = entries
        .map((entry) => entry.activity.length)
        .fold(activityHeader.length, (prev, len) => len > prev ? len : prev);

    final dateWidth = computedDateWidth.clamp(dateHeader.length, maxDateWidth);
    final activityWidth =
        computedActivityWidth.clamp(activityHeader.length, maxActivityWidth);

    String separator() {
      return '+-${'-' * dateWidth}-+-${'-' * activityWidth}-+';
    }

    String row(String left, String right) {
      return '| ${left.padRight(dateWidth)} | ${right.padRight(activityWidth)} |';
    }

    final buffer = StringBuffer();
    buffer.writeln(separator());
    buffer.writeln(row(dateHeader, activityHeader));
    buffer.writeln(separator());

    if (entries.isEmpty) {
      buffer.writeln(row('-', 'Data kalender akademik kosong'));
      buffer.writeln(separator());
      return buffer.toString().trimRight();
    }

    for (final entry in entries) {
      final dateLines = _wrapText(entry.dateLabel, dateWidth);
      final activityLines = _wrapText(entry.activity, activityWidth);
      final lineCount = dateLines.length > activityLines.length
          ? dateLines.length
          : activityLines.length;

      for (var i = 0; i < lineCount; i++) {
        final left = i < dateLines.length ? dateLines[i] : '';
        final right = i < activityLines.length ? activityLines[i] : '';
        buffer.writeln(row(left, right));
      }
      buffer.writeln(separator());
    }

    return buffer.toString().trimRight();
  }

  void printEntriesAsTable(
    List<AcademicCalendarEntry> entries, {
    void Function(Object? object) printer = print,
  }) {
    printer(formatEntriesAsTable(entries));
  }

  List<AcademicCalendarEntry> _parseEntriesFromPdfBytes(Uint8List pdfBytes) {
    final document = PdfDocument(inputBytes: pdfBytes);
    final extractor = PdfTextExtractor(document);

    final buffer = StringBuffer();
    for (var i = 0; i < document.pages.count; i++) {
      final pageText = extractor.extractText(startPageIndex: i, endPageIndex: i);
      if (pageText.trim().isEmpty) {
        continue;
      }
      buffer.writeln(pageText);
    }
    document.dispose();

    return _extractEntriesFromPdfText(buffer.toString());
  }

  List<String> _wrapText(String text, int width) {
    if (text.isEmpty) {
      return const <String>[''];
    }

    final words = text.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    final lines = <String>[];
    var currentLine = '';

    for (final word in words) {
      if (word.length > width) {
        if (currentLine.isNotEmpty) {
          lines.add(currentLine);
          currentLine = '';
        }
        var start = 0;
        while (start < word.length) {
          final end = (start + width < word.length) ? start + width : word.length;
          lines.add(word.substring(start, end));
          start = end;
        }
        continue;
      }

      final candidate = currentLine.isEmpty ? word : '$currentLine $word';
      if (candidate.length <= width) {
        currentLine = candidate;
      } else {
        lines.add(currentLine);
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      lines.add(currentLine);
    }

    return lines.isEmpty ? const <String>[''] : lines;
  }

  List<AcademicCalendarEntry> _extractEntriesFromPdfText(String pdfText) {
    final normalized = pdfText.replaceAll('\r', '\n');
    final lines = normalized
        .split('\n')
        .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
        .where((line) => line.isNotEmpty)
        .toList();

    final entries = <AcademicCalendarEntry>[];
    String? activeDateLabel;
    final activeActivity = StringBuffer();

    final rowRegex = RegExp(
      r'^(?<datePart>\d{1,2}(?:\s*[-–]\s*\d{1,2})?\s+(?:[A-Za-z][A-Za-z\/\.\-]*(?:\s*[-–]\s*[A-Za-z][A-Za-z\/\.\-]*)?)(?:\s+\d{4}(?:\s*[-–]\s*\d{4})?))(?<activity>\s+.*)?$',
      caseSensitive: false,
    );

    bool isSectionHeader(String line) {
      return RegExp(
        r'^(SEMESTER\s+(GANJIL|GENAP)\s+\d{4}(?:/\d{4})?|NO\.?|NOMOR\.?|TABEL\s+KALENDER|KALENDER\s+AKADEMIK)$',
        caseSensitive: false,
      ).hasMatch(line);
    }

    void flushEntry() {
      if (activeDateLabel == null) {
        return;
      }

      final activity = activeActivity.toString().trim();
      if (activity.isEmpty) {
        activeDateLabel = null;
        activeActivity.clear();
        return;
      }

      entries.add(
        AcademicCalendarEntry(
          dateLabel: activeDateLabel!,
          activity: activity,
        ),
      );

      activeDateLabel = null;
      activeActivity.clear();
    }

    for (final line in lines) {
      if (isSectionHeader(line)) {
        flushEntry();
        continue;
      }

      final rowMatch = rowRegex.firstMatch(line);
      if (rowMatch != null) {
        flushEntry();

        activeDateLabel = rowMatch.namedGroup('datePart')!.trim();
        final activityText = (rowMatch.namedGroup('activity') ?? '').trim();

        if (activityText.isNotEmpty) {
          activeActivity.write(activityText);
        }
        continue;
      }

      if (activeDateLabel != null) {
        if (activeActivity.isNotEmpty) {
          activeActivity.write(' ');
        }
        activeActivity.write(line);
      }
    }

    flushEntry();
    return entries;
  }

  AcademicCalendarData? _readCache(SharedPreferences prefs) {
    final sourcePdfUrl = prefs.getString(_cacheKeyPdfUrl);
    final updatedAtRaw = prefs.getString(_cacheKeyUpdatedAt);
    final entriesRaw = prefs.getString(_cacheKeyEntries);

    if (sourcePdfUrl == null || updatedAtRaw == null || entriesRaw == null) {
      return null;
    }

    final updatedAt = DateTime.tryParse(updatedAtRaw);
    if (updatedAt == null) {
      return null;
    }

    final decoded = jsonDecode(entriesRaw);
    if (decoded is! List) {
      return null;
    }

    final entries = decoded
        .whereType<Map>()
        .map(
          (item) => AcademicCalendarEntry.fromJson(
            item.map((k, v) => MapEntry(k.toString(), v)),
          ),
        )
        .where((entry) => entry.dateLabel.isNotEmpty && entry.activity.isNotEmpty)
        .toList();

    return AcademicCalendarData(
      pageUrl: calendarPageUrl,
      sourcePdfUrl: sourcePdfUrl,
      updatedAt: updatedAt,
      entries: entries,
      fromCache: true,
    );
  }

  Future<void> _writeCache(
    SharedPreferences prefs,
    AcademicCalendarData data,
  ) async {
    final encodedEntries = jsonEncode(
      data.entries.map((entry) => entry.toJson()).toList(),
    );

    await prefs.setString(_cacheKeyPdfUrl, data.sourcePdfUrl);
    await prefs.setString(_cacheKeyUpdatedAt, data.updatedAt.toIso8601String());
    await prefs.setString(_cacheKeyEntries, encodedEntries);
  }
}

