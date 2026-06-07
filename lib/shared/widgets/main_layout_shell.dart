import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/controller/aspirasi_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/admin_aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/admin/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/teknisi/controller/home_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/teknisi/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/admin_laporan_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/teknisi_laporan_fasilitas_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/admin_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/mahasiswa_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/teknisi_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/profile/view/role_profile_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/riwayat_tugas/controller/riwayat_tugas_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/riwayat_tugas/view/riwayat_tugas_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/role_service.dart';


enum UserRole {
  admin,
  mahasiswa,
  teknisi;

  static UserRole fromString(String? role) {
    // Memanfaatkan AccessControlService yang sudah kamu buat
    final normalized = AccessControlService.normalizeRole(role);
    switch (normalized) {
      case 'admin': return UserRole.admin;
      case 'mahasiswa': return UserRole.mahasiswa;
      case 'teknisi': return UserRole.teknisi;
      default: return UserRole.mahasiswa; // Default ke mahasiswa jika role tidak dikenali
    }
  }
}

class MainLayoutShell extends StatefulWidget {
  final String userRole;
  const MainLayoutShell({super.key, required this.userRole});

  @override
  State<MainLayoutShell> createState() => _MainLayoutShellState();
}

class _MainLayoutShellState extends State<MainLayoutShell> {
  int _currentIndex = 0;
  
  // Ubah menjadi late agar diinisialisasi SEKALI saja di initState
  late final List<Widget> _pages;
  late final List<BottomNavigationBarItem> _navBarItems;

  UserRole role = UserRole.mahasiswa;


  @override
  void initState() {
    super.initState();
    _initializeRoleAssets();
  }

  void _initializeRoleAssets() {
    role = UserRole.fromString(widget.userRole);

    switch (role) {
      case UserRole.admin:
        _pages = const [
          AdminDashboardView(),
          AdminLaporanFasilitasView(),
          AdminAspirasiView(),
          RoleProfileView(role: 'admin'),
        ];
        _navBarItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.apartment_rounded), label: 'Layanan'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_rounded), label: 'Aspirasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ];
        break;
      case UserRole.mahasiswa:
        _pages = const [
          HomeView(),
          MahasiswaLaporanFasilitasView(),
          AspirasiView(),
          RoleProfileView(role: 'mahasiswa'),
        ];
        _navBarItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), label: 'Layanan'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_rounded), label: 'Aspirasi'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ];
        break;
      case UserRole.teknisi:
        _pages = const [
          HomeTeknisiView(),
          TeknisiLaporanFasilitasView(),
          RiwayatTugasView(),
          RoleProfileView(role: 'teknisi'),
        ];
        _navBarItems = const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment_rounded), label: 'Tugas'),
          BottomNavigationBarItem(icon: Icon(Icons.history_rounded), label: 'Riwayat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
        ];
        break;
    }
  }

  void _refreshSelectedPage(int index) {
    if (role == UserRole.admin) {
      if (index == 1) _safeFindAndRefresh<AdminLaporanController>((c) => c.fetchLaporan());
      if (index == 2) _safeFindAndRefresh<AspirasiController>((c) => c.onRefresh());
    } else if (role == UserRole.teknisi) {
      if (index == 0) _safeFindAndRefresh<HomeTeknisiController>((c) => c.onRefresh());
      if (index == 1) _safeFindAndRefresh<TeknisiLaporanFasilitasController>((c) => c.fetchTugas());
      if (index == 2) _safeFindAndRefresh<RiwayatTugasController>((c) => c.onRefresh());
    }
  }

  void _safeFindAndRefresh<T>(Function(T) refreshAction) {
    if (Get.isRegistered<T>()) {
      refreshAction(Get.find<T>());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: IndexedStack(
        index: _currentIndex,
        children: _pages, 
      ),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1E3A5F),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (_currentIndex == index) return; 
          setState(() {
            _currentIndex = index;
          });
          _refreshSelectedPage(index);
        },
        items: _navBarItems,
      ),
    );
  }
}