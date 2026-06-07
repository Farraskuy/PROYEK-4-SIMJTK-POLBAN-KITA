import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_secure_storage/test/test_flutter_secure_storage_platform.dart';
import 'package:flutter_secure_storage_platform_interface/flutter_secure_storage_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/user_credential_seeder.dart';

void main() {
  setUpAll(() async {
    final envFile = File('.env');
    if (!envFile.existsSync()) {
      throw Exception('File .env tidak ditemukan untuk DB integration test.');
    }

    dotenv.loadFromString(envString: envFile.readAsStringSync());
    FlutterSecureStoragePlatform.instance = TestFlutterSecureStoragePlatform(
      <String, String>{},
    );
    await MonggoDBServices().connect();
  });

  tearDownAll(() async {
    await MonggoDBServices().close();
  });

  test('seeder default role idempotent dan tanpa duplikasi username', () async {
    final usersCollection = MonggoDBServices().getCollection('users');

    // Clean up first to avoid conflicting with actual data or previous test runs
    for (final credential in UserCredentialSeeder.defaultCredentials) {
      await usersCollection.deleteOne({'username': credential.username});
    }

    try {
      await UserCredentialSeeder.seedDefaults();
      await UserCredentialSeeder.seedDefaults();

      for (final credential in UserCredentialSeeder.defaultCredentials) {
        final users = await usersCollection
            .find(where.eq('username', credential.username))
            .toList();

        expect(users.length, equals(1));
        expect(users.first['role'], equals(credential.role));
        expect(users.first['password_hash'], isNotNull);
        expect(users.first['isActive'], isTrue);
      }
    } finally {
      // Clean up after test
      for (final credential in UserCredentialSeeder.defaultCredentials) {
        await usersCollection.deleteOne({'username': credential.username});
      }
    }
  });
}
