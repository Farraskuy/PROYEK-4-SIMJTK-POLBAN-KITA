import 'package:hive_flutter/hive_flutter.dart';

class HiveService {
  static const String laporanFasilitasBox = 'laporan_fasilitas_box';
  static const String syncQueueBox = 'sync_queue_box';
  static const String aspirasiBoxName = 'aspirasi_box';
  static const String kategoriFasilitasBoxName = 'kategori_fasilitas_box';

  static bool _isInitialized = false;
  static String? testPath;

  static Future<void> init() async {
    if (_isInitialized) return;

    if (testPath != null) {
      Hive.init(testPath!);
    } else {
      await Hive.initFlutter();
    }
    
    await Hive.openBox(laporanFasilitasBox);
    await Hive.openBox(syncQueueBox);
    await Hive.openBox(aspirasiBoxName);
    await Hive.openBox(kategoriFasilitasBoxName);

    _isInitialized = true;
  }

  static Box get laporanBox => Hive.box(laporanFasilitasBox);
  static Box get queueBox => Hive.box(syncQueueBox);
  static Box get aspirasiBox => Hive.box(aspirasiBoxName);
  static Box get kategoriBox => Hive.box(kategoriFasilitasBoxName);
}

