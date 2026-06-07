import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/admin/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/teknisi/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/admin_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/admin_aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/mahasiswa_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/riwayat_tugas/view/riwayat_tugas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/profile/view/role_profile_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/teknisi_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/role_service.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/teknisi/controller/home_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/teknisi_laporan_fasilitas_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/riwayat_tugas/controller/riwayat_tugas_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/admin_laporan_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/controller/aspirasi_controller.dart';

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
    final destination = resolveDestination(role);
    if (destination == HomeDestination.unknown) {
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

enum UserRole {
  admin,
  mahasiswa,
  teknisi;

  static UserRole? fromString(String? role) {
    switch (AccessControlService.normalizeRole(role)) {
      case 'admin':
        return UserRole.admin;
      case 'mahasiswa':
        return UserRole.mahasiswa;
      case 'teknisi':
        return UserRole.teknisi;
      default:
        return null;
    }
  }
}

class MainLayoutShell extends StatefulWidget {
  final UserRole userRole;

  const MainLayoutShell({super.key, required this.userRole});

  @override
  State<MainLayoutShell> createState() => _MainLayoutShellState();
}

class _MainLayoutShellState extends State<MainLayoutShell> {
  int _currentIndex = 0;

  List<Widget> _getPagesForRole() {
    switch (widget.userRole) {
      case UserRole.admin:
        return const [
          AdminDashboardView(),
          AdminLaporanFasilitasView(),
          AdminAspirasiView(),
        ];
      case UserRole.mahasiswa:
        return const [
          HomeView(),
          MahasiswaLaporanFasilitasView(),
          AspirasiView(),
          RoleProfileView(role: 'mahasiswa'),
        ];
      case UserRole.teknisi:
        return const [
          HomeTeknisiView(),
          TeknisiLaporanFasilitasView(),
          RiwayatTugasView(),
          RoleProfileView(role: 'teknisi'),
        ];
    }
  }

  List<BottomNavigationBarItem> _getNavBarItemsForRole() {
    switch (widget.userRole) {
      case UserRole.admin:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.apartment_rounded), label: 'Layanan'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_rounded), label: 'Aspirasi'),
        ];
      case UserRole.mahasiswa:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Layanan'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_rounded), label: 'Aspirasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ];
      case UserRole.teknisi:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Tugas'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ];
    }
  }

  Future<void> _refreshSelectedPage(int index) async {
    if (widget.userRole == UserRole.admin) {
      if (index == 1 && Get.isRegistered<AdminLaporanController>()) {
        await Get.find<AdminLaporanController>().fetchLaporan();
      } else if (index == 2 && Get.isRegistered<AspirasiController>()) {
        await Get.find<AspirasiController>().onRefresh();
      }
      return;
    }
    if (widget.userRole != UserRole.teknisi) return;

    switch (index) {
      case 0:
        if (Get.isRegistered<HomeTeknisiController>()) {
          await Get.find<HomeTeknisiController>().onRefresh();
        }
        break;
      case 1:
        if (Get.isRegistered<TeknisiLaporanFasilitasController>()) {
          await Get.find<TeknisiLaporanFasilitasController>().fetchTugas();
        }
        break;
      case 2:
        if (Get.isRegistered<RiwayatTugasController>()) {
          await Get.find<RiwayatTugasController>().onRefresh();
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil data dinamis sesuai role saat ini
    final pages = _getPagesForRole();
    final navBarItems = _getNavBarItemsForRole();

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3A5F),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _refreshSelectedPage(index);
        },
        items: navBarItems,
      ),
    );
  }
}
