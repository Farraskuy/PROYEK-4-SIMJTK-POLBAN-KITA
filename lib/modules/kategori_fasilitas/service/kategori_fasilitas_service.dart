import 'package:flutter/foundation.dart';
import 'package:proyek_4_poki_polban_kita/modules/kategori_fasilitas/model/kategori_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/hive_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/network_service.dart';

class KategoriFasilitasService {
  static const String collectionName = 'kategori_fasilitas';
  final NetworkService _network = NetworkService();

  Future<KategoriFasilitasModel> create(KategoriFasilitasModel kategori) async {
    await HiveService.init();
    if (await _network.isOnline) {
      await MonggoDBServices().insertData(collectionName, kategori.toJson());
    }
    await HiveService.kategoriBox.put(kategori.id, kategori.toJson());
    return kategori;
  }

  Future<List<KategoriFasilitasModel>> getAll() async {
    await HiveService.init();
    
    // Read local cache first
    final local = HiveService.kategoriBox.values
        .whereType<Map>()
        .map((item) => KategoriFasilitasModel.fromJson(Map<String, dynamic>.from(item)))
        .toList();

    if (!await _network.isOnline) {
      return local;
    }

    try {
      final rows = await MonggoDBServices().fetchAll(collectionName);
      
      // Update local cache
      await HiveService.kategoriBox.clear();
      for (final row in rows) {
        final kategori = KategoriFasilitasModel.fromJson(row);
        await HiveService.kategoriBox.put(kategori.id, kategori.toJson());
      }

      return rows.map(KategoriFasilitasModel.fromJson).toList();
    } catch (e) {
      debugPrint('Gagal refresh kategori dari MongoDB, memakai Hive: $e');
      return local;
    }
  }

  Future<KategoriFasilitasModel?> getById(String id) async {
    await HiveService.init();

    if (!await _network.isOnline) {
      final val = HiveService.kategoriBox.get(id);
      if (val is Map) {
        return KategoriFasilitasModel.fromJson(Map<String, dynamic>.from(val));
      }
      return null;
    }

    try {
      final rows = await MonggoDBServices().fetchByField(
        collectionName,
        '_id',
        id,
      );
      if (rows.isEmpty) {
        return null;
      }
      final kategori = KategoriFasilitasModel.fromJson(rows.first);
      await HiveService.kategoriBox.put(kategori.id, kategori.toJson());
      return kategori;
    } catch (e) {
      final val = HiveService.kategoriBox.get(id);
      if (val is Map) {
        return KategoriFasilitasModel.fromJson(Map<String, dynamic>.from(val));
      }
      return null;
    }
  }

  Future<KategoriFasilitasModel> update(KategoriFasilitasModel kategori) async {
    await HiveService.init();
    if (await _network.isOnline) {
      await MonggoDBServices().updateById(
        collectionName,
        kategori.id,
        kategori.toJson(),
      );
    }
    await HiveService.kategoriBox.put(kategori.id, kategori.toJson());
    return kategori;
  }

  Future<void> delete(String id) async {
    await HiveService.init();
    if (await _network.isOnline) {
      await MonggoDBServices().deleteData(collectionName, id);
    }
    await HiveService.kategoriBox.delete(id);
  }
}
