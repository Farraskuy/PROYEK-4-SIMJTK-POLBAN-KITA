import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/log_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

void main() {
  const String sourceFile = "connection_test.dart";

  setUpAll(() async {
    // Memuat env sekali di awal untuk semua test
    // Dalam flutter_test, assets tidak dimuat otomatis. Kita harus baca filenya secara langsung.
    final String envFileString = File('.env').readAsStringSync();
    dotenv.loadFromString(envString: envFileString);
  });

  test(
    'Memastikan koneksi ke MongoDB Atlas berhasil via MongoService',
    () async {
      final mongoService = MonggoDBServices();

      // Memanfaatkan LogService baru yang sudah pakai dev.log dan print berwarna
      await LogService.writeLog(
        "--- START CONNECTION TEST ---",
        source: sourceFile,
      );

      try {
        // Mengetes koneksi
        await mongoService.connect();

        // Ekspektasi: URI tidak null dan koneksi berhasil
        expect(dotenv.env['MONGODB_URI'], isNotNull);

        expect(mongoService.isConnected, isTrue);

        await LogService.writeLog(
          "SUCCESS: Koneksi Atlas Terverifikasi",
          source: sourceFile,
          level: 2, // INFO (Hijau)
        );
      } catch (e) {
        await LogService.writeLog(
          "ERROR: Kegagalan koneksi - $e",
          source: sourceFile,
          level: 1, // ERROR (Merah)
        );
        fail("Koneksi gagal: $e");
      } finally {
        // Selalu tutup koneksi agar tidak menggantung di dashboard Atlas
        await mongoService.close();
        await LogService.writeLog("--- END TEST ---", source: sourceFile);
      }
    },
  );

  test(
    'mendapatkan users collection setelah koneksi',
    () async {
      final mongoService = MonggoDBServices();

      await LogService.writeLog(
        "--- START COLLECTION TEST ---",
        source: sourceFile,
      );

      try {
        await mongoService.connect();
        final usersCollection = mongoService.getCollection('users');

        // Ekspektasi: Collection berhasil diakses
        expect(usersCollection, isNotNull);
        expect(usersCollection.collectionName, equals('users'));

        await LogService.writeLog(
          "SUCCESS: Akses collection users berhasil",
          source: sourceFile,
          level: 2, // INFO (Hijau)
        );
      } catch (e) {
        await LogService.writeLog(
          "ERROR: Gagal akses collection - $e",
          source: sourceFile,
          level: 1, // ERROR (Merah)
        );
        fail("Gagal akses collection: $e");
        
      } finally {
        await mongoService.close();
        await LogService.writeLog("--- END TEST ---", source: sourceFile);
      }
    },
  );

  test('insert data user', () async {
    final mongoService = MonggoDBServices();

    await LogService.writeLog(
      "--- START INSERT TEST ---",
      source: sourceFile,
    );

    try {
      await mongoService.connect();
      final usersCollection = mongoService.getCollection('users');

      final newUser = {
        'username': 'testuser',
        'name': 'Test User',
        'programStudy': 'Teknik Informatika',
        'photoUrl': '',
        'password': 'hashed_password',
        'role': 'mahasiswa',
        'source': 'website',
        'updatedAt': DateTime.now(),
        'lastLoginAt': DateTime.now(),
      };

      final insertedId = await usersCollection.insertOne(newUser);

      // Ekspektasi: ID hasil insert tidak null
      expect(insertedId, isNotNull);

      await LogService.writeLog(
        "SUCCESS: Insert user berhasil dengan ID $insertedId",
        source: sourceFile,
        level: 2, // INFO (Hijau)
      );
    } catch (e) {
      await LogService.writeLog(
        "ERROR: Gagal insert data - $e",
        source: sourceFile,
        level: 1, // ERROR (Merah)
      );
      fail("Gagal insert data: $e");
    } finally {
      await mongoService.close();
      await LogService.writeLog("--- END TEST ---", source: sourceFile);
    }
   });

  test('delete data user', () async {
    final mongoService = MonggoDBServices();

    await LogService.writeLog(
      "--- START DELETE TEST ---",
      source: sourceFile,
    );

    try {
      await mongoService.connect();
      final usersCollection = mongoService.getCollection('users');

      await usersCollection.deleteOne({'username': 'testuser'});

      final user = await usersCollection.findOne({'username': 'testuser'});

      // Ekspektasi: Dokumen berhasil dihapus
      expect(user, isNull);

      await LogService.writeLog(
        "SUCCESS: Delete user berhasil",
        source: sourceFile,
        level: 2, // INFO (Hijau)
      );
    } catch (e) {
      await LogService.writeLog(
        "ERROR: Gagal delete data - $e",
        source: sourceFile,
        level: 1, // ERROR (Merah)
      );
      fail("Gagal delete data: $e");
    } finally {
      await mongoService.close();
      await LogService.writeLog("--- END TEST ---", source: sourceFile);
    }
  });

}
