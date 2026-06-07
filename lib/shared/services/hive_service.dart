import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String laporanFasilitasBox = 'laporan_fasilitas_box';
  static const String syncQueueBox = 'sync_queue_box';

  static bool _isInitialized = false;

  static Future<void> init() async {
    if (_isInitialized) return;

    await Hive.initFlutter();
    await Hive.openBox(laporanFasilitasBox);
    await Hive.openBox(syncQueueBox);

    _isInitialized = true;
  }

  static Box get laporanBox => Hive.box(laporanFasilitasBox);
  static Box get queueBox => Hive.box(syncQueueBox);
}
