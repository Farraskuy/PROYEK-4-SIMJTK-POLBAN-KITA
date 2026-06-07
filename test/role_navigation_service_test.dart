import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/role_navigation_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/main_layout_shell.dart';

void main() {
  test('role dikenal diarahkan ke destination yang benar', () {
    expect(
      RoleNavigationService.resolveDestination('mahasiswa'),
      equals(HomeDestination.mahasiswa),
    );
    expect(
      RoleNavigationService.resolveDestination('dosen'),
      equals(HomeDestination.dosen),
    );
    expect(
      RoleNavigationService.resolveDestination('teknisi'),
      equals(HomeDestination.teknisi),
    );
    expect(
      RoleNavigationService.resolveDestination('admin'),
      equals(HomeDestination.admin),
    );
    expect(
      RoleNavigationService.resolveDestination('staff'),
      equals(HomeDestination.teknisi),
    );
  });

  test('role dikenal membangun widget home yang sesuai', () {
    final mahasiswaWidget = RoleNavigationService.buildHomeByRole('mahasiswa');
    expect(mahasiswaWidget, isA<MainLayoutShell>());
    expect((mahasiswaWidget as MainLayoutShell).userRole, equals(UserRole.mahasiswa));

    final dosenWidget = RoleNavigationService.buildHomeByRole('dosen');
    expect(dosenWidget, isA<MainLayoutShell>());
    expect((dosenWidget as MainLayoutShell).userRole, equals(UserRole.dosen));

    final teknisiWidget = RoleNavigationService.buildHomeByRole('teknisi');
    expect(teknisiWidget, isA<MainLayoutShell>());
    expect((teknisiWidget as MainLayoutShell).userRole, equals(UserRole.teknisi));

    final adminWidget = RoleNavigationService.buildHomeByRole('admin');
    expect(adminWidget, isA<MainLayoutShell>());
    expect((adminWidget as MainLayoutShell).userRole, equals(UserRole.admin));
  });

  test('role tidak dikenal memakai fallback', () {
    final widget = RoleNavigationService.buildHomeByRole('operator');

    expect(RoleNavigationService.resolveDestination('operator'), equals(HomeDestination.unknown));
    expect(widget, isA<UnknownRoleView>());
  });
}