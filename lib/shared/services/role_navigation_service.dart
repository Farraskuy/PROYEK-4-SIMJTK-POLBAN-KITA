import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/role_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/main_layout_shell.dart';

enum HomeDestination {
  mahasiswa,
  dosen,
  teknisi,
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
      case AccessControlService.roleAdmin:
        return HomeDestination.admin;
      default:
        return HomeDestination.unknown;
    }
  }

  static Widget buildHomeByRole(String? role) {
    final dest = resolveDestination(role);
    if (dest == HomeDestination.unknown) {
      return UnknownRoleView(role: role);
    }
    
    final userRole = UserRole.fromString(role);
    if (userRole == null) {
      return UnknownRoleView(role: role);
    }
    
    return MainLayoutShell(userRole: userRole);
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
