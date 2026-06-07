import 'package:hive/hive.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/cloudinary_service.dart';

class TanggapanTugasService {
  static const _boxName = 'draft_tanggapan_tugas';
  static const _collection = 'analisa_kerusakan';
  final CloudinaryService _cloudinaryService = CloudinaryService();

  Future<Box<dynamic>> _box() => Hive.openBox<dynamic>(_boxName);

  Future<Map<String, dynamic>?> getDraft(String laporanId) async {
    final value = (await _box()).get(laporanId);
    if (value is! Map) return null;
    return Map<String, dynamic>.from(value);
  }

  Future<Map<String, Map<String, dynamic>>> getAllDrafts() async {
    final box = await _box();
    final drafts = <String, Map<String, dynamic>>{};
    for (final key in box.keys) {
      final value = box.get(key);
      if (value is Map) {
        drafts[key.toString()] = Map<String, dynamic>.from(value);
      }
    }
    return drafts;
  }

  Future<void> saveLocal(
    String laporanId,
    Map<String, dynamic> data, {
    required bool pendingSync,
  }) async {
    final box = await _box();
    final existing = box.get(laporanId);
    final existingMap = existing is Map
        ? Map<String, dynamic>.from(existing)
        : <String, dynamic>{};
    await box.put(laporanId, {
      ...existingMap,
      ...data,
      'pending_sync': pendingSync,
      'saved_at': DateTime.now().toIso8601String(),
    });
  }

  Future<void> sync(
    String laporanId,
    Map<String, dynamic> data, {
    required StatusLaporan status,
  }) async {
    final mongo = MonggoDBServices();
    await mongo.ensureConnected();

    final existing = await mongo.fetchByField(_collection, 'laporan_id', laporanId);
    final photoPaths = (data['foto_analisa_urls'] as List?)
            ?.map((item) => item.toString())
            .toList() ??
        const <String>[];
    final localDraft = await getDraft(laporanId);
    final uploadedPhotoMap = Map<String, String>.from(
      localDraft?['uploaded_photo_map'] as Map? ?? const {},
    );
    final photoUrls = <String>[];
    for (final path in photoPaths) {
      if (path.startsWith('http://') || path.startsWith('https://')) {
        photoUrls.add(path);
        continue;
      }
      final cachedUrl = uploadedPhotoMap[path];
      if (cachedUrl != null) {
        photoUrls.add(cachedUrl);
        continue;
      }
      final url = await _cloudinaryService.uploadImage(
        path,
        folder: 'simjtk/tanggapan_petugas',
      );
      uploadedPhotoMap[path] = url;
      photoUrls.add(url);
    }
    final syncedData = {
      ...data,
      'foto_analisa_urls': photoUrls,
      'uploaded_photo_map': uploadedPhotoMap,
      'laporan_id': laporanId,
      'sync_status': 'synced',
      'updated_at': DateTime.now(),
    };

    if (existing.isEmpty) {
      final newData = {
        ...syncedData,
        'created_at': DateTime.now(),
      };
      await mongo.insertData(_collection, newData);
    } else {
      await mongo.updateByField(_collection, 'laporan_id', laporanId, syncedData);
    }

    final laporanPatch = {
      'teknisi_id': data['teknisi_id'],
      'catatan_petugas': data['analisa_masalah'],
      'status': status.value,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    await mongo.updateById(
      'laporan_fasilitas',
      laporanId,
      laporanPatch,
    );

    await saveLocal(laporanId, syncedData, pendingSync: false);
  }

  Future<void> syncPendingDrafts() async {
    final box = await _box();
    for (final key in box.keys) {
      final value = box.get(key);
      if (value is! Map || value['pending_sync'] != true) continue;

      final data = Map<String, dynamic>.from(value);
      try {
        await sync(
          key.toString(),
          data,
          status: data['form_status'] == 'selesai'
              ? StatusLaporan.resolved
              : StatusLaporan.in_progress,
        );
      } catch (_) {
        // Tetap berada di antrean lokal dan dicoba lagi pada siklus berikutnya.
      }
    }
  }

  Future<Map<String, dynamic>?> getTanggapan(String laporanId) async {
    final local = await getDraft(laporanId);
    try {
      final mongo = MonggoDBServices();
      await mongo.ensureConnected();
      final rows = await mongo.fetchByField(
        _collection,
        'laporan_id',
        laporanId,
      );
      if (rows.isEmpty) return local;
      return {...rows.first, ...?local};
    } catch (_) {
      return local;
    }
  }
}
