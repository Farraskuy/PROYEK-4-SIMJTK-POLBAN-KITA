import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/role_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/user_credential_seeder.dart';

void main() {
  test('seed credential unik dan mencakup semua role utama', () {
    final credentials = UserCredentialSeeder.defaultCredentials;

    final usernames = credentials.map((item) => item.username).toSet();
    final roles = credentials.map((item) => item.role).toSet();

    expect(credentials.length, equals(5));
    expect(usernames.length, equals(credentials.length));
    expect(roles, containsAll(<String>{
      AccessControlService.roleMahasiswa,
      AccessControlService.roleDosen,
      AccessControlService.roleTeknisi,
      AccessControlService.roleTu,
      AccessControlService.roleAdmin,
    }));
  });
}