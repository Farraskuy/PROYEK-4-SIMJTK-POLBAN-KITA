import 'package:flutter_test/flutter_test.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/admin/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/dosen/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/teknisi/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/tu/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/role_navigation_service.dart';

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
      RoleNavigationService.resolveDestination('tu'),
      equals(HomeDestination.tu),
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
    expect(RoleNavigationService.buildHomeByRole('mahasiswa'), isA<HomeView>());
    expect(RoleNavigationService.buildHomeByRole('dosen'), isA<HomeDosenView>());
    expect(RoleNavigationService.buildHomeByRole('teknisi'), isA<HomeTeknisiView>());
    expect(RoleNavigationService.buildHomeByRole('tu'), isA<HomeTuView>());
    expect(RoleNavigationService.buildHomeByRole('admin'), isA<AdminDashboardView>());
  });

  test('role tidak dikenal memakai fallback', () {
    final widget = RoleNavigationService.buildHomeByRole('operator');

    expect(RoleNavigationService.resolveDestination('operator'), equals(HomeDestination.unknown));
    expect(widget, isA<UnknownRoleView>());
  });
}