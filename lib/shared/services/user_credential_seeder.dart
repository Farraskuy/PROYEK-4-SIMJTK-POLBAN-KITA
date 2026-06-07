import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/foundation.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/log_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/role_service.dart';

class SeedUserCredential {
  final String username;
  final String password;
  final String name;
  final String role;
  final String programStudy;

  const SeedUserCredential({
    required this.username,
    required this.password,
    required this.name,
    required this.role,
    this.programStudy = '',
  });
}

class UserCredentialSeeder {
  static const String _usersCollection = 'users';

  static const List<SeedUserCredential> defaultCredentials = [
    SeedUserCredential(
      username: '2415110001',
      password: 'Mhs@12345',
      name: 'Seed Mahasiswa',
      role: AccessControlService.roleMahasiswa,
      programStudy: 'D4 Teknik Informatika',
    ),
    SeedUserCredential(
      username: 'DSN001',
      password: 'Dosen@12345',
      name: 'Seed Dosen',
      role: AccessControlService.roleDosen,
      programStudy: 'D4 Teknik Informatika',
    ),
    SeedUserCredential(
      username: 'TKS001',
      password: 'Teknisi@12345',
      name: 'Seed Teknisi',
      role: AccessControlService.roleTeknisi,
      programStudy: 'Unit Sarana',
    ),
    SeedUserCredential(
      username: 'TU001',
      password: 'TU@12345',
      name: 'Seed TU',
      role: AccessControlService.roleTu,
      programStudy: 'Tata Usaha',
    ),
    SeedUserCredential(
      username: 'ADM001',
      password: 'Admin@12345',
      name: 'Seed Admin',
      role: AccessControlService.roleAdmin,
      programStudy: 'Administrator',
    ),
  ];

  @visibleForTesting
  static Future<void> Function()? seedOverride;

  static Future<void> seedDefaults() async {
    final override = seedOverride;
    if (override != null) {
      await override();
      return;
    }

    final mongo = MonggoDBServices();
    await mongo.ensureConnected();

    for (final item in defaultCredentials) {
      await _upsertAndDedupeOne(mongo, item);
    }

    await LogService.writeLog(
      'SEED: Kredensial default role berhasil diupsert tanpa duplikasi.',
      source: 'user_credential_seeder.dart',
      level: 2,
    );
  }

  static Future<void> _upsertAndDedupeOne(
    MonggoDBServices mongo,
    SeedUserCredential credential,
  ) async {
    final now = DateTime.now().toIso8601String();
    final hashedPassword = BCrypt.hashpw(credential.password, BCrypt.gensalt());

    final existing = await mongo.fetchByAnyField(_usersCollection, {
      'username': credential.username,
      'nomor_induk': credential.username,
    });

    final patch = {
      'username': credential.username,
      'nomor_induk': credential.username,
      'name': credential.name,
      'programStudy': credential.programStudy,
      'photoUrl': '',
      'password_hash': hashedPassword,
      'password': hashedPassword,
      'role': credential.role,
      'source': 'seed',
      'isActive': true,
      'updatedAt': now,
      'lastLoginAt': now,
    };

    if (existing.isEmpty) {
      final newDoc = {'_id': credential.username, ...patch, 'createdAt': now};
      await mongo.insertData(_usersCollection, newDoc);
      return;
    }

    final keeper = _pickKeeper(existing, credential.username);
    final keeperId = keeper['_id'];

    if (keeperId != null) {
      await mongo.updateById(_usersCollection, keeperId, patch);
    }

    if (existing.length > 1) {
      final duplicates = existing.where((item) => item['_id'] != keeperId);
      for (final duplicate in duplicates) {
        final duplicateId = duplicate['_id'];
        if (duplicateId != null) {
          await mongo.deleteById(_usersCollection, duplicateId);
        }
      }
    }
  }

  static Map<String, dynamic> _pickKeeper(
    List<Map<String, dynamic>> existing,
    String username,
  ) {
    return existing.firstWhere(
      (item) => item['_id'] == username,
      orElse: () => existing.first,
    );
  }
}
