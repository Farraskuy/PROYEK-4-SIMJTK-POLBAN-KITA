import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/admin/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/dosen/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/teknisi/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/tu/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/role_service.dart';

enum HomeDestination {
  mahasiswa,
  dosen,
  teknisi,
  tu,
  admin,
  unknown,
}

class RoleNavigationService {
  const RoleNavigationService._();

  static HomeDestination resolveDestination(String? role) {
    final normalizedRole = AccessControlService.normalizeRole(role);
    switch (normalizedRole) {
      case AccessControlService.roleMahasiswa:
        return HomeDestination.mahasiswa;
      case AccessControlService.roleDosen:
        return HomeDestination.dosen;
      case AccessControlService.roleTeknisi:
        return HomeDestination.teknisi;
      case AccessControlService.roleTu:
        return HomeDestination.tu;
      case AccessControlService.roleAdmin:
        return HomeDestination.admin;
      default:
        return HomeDestination.unknown;
    }
  }

  static Widget buildHomeByRole(String? role) {
    switch (resolveDestination(role)) {
      case HomeDestination.mahasiswa:
        return const HomeView();
      case HomeDestination.dosen:
        return const HomeDosenView();
      case HomeDestination.teknisi:
        return const HomeTeknisiView();
      case HomeDestination.tu:
        return const HomeTuView();
      case HomeDestination.admin:
        return const AdminDashboardView();
      case HomeDestination.unknown:
        return UnknownRoleView(role: role);
    }
  }
}

class UnknownRoleView extends StatelessWidget {
  const UnknownRoleView({super.key, this.role});

  final String? role;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Role "${role ?? '-'}" belum didukung pada aplikasi ini.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
