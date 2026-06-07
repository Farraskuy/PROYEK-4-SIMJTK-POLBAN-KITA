import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/admin/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/dosen/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/teknisi/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/laporan_fasilitas_mahasiswa_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/admin_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/admin_aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/view/admin_user_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/riwayat_tugas/view/riwayat_tugas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/profile/view/role_profile_view.dart';

// 1. Definisikan Enum Role agar kode aman dari typo (Prinsip KISS)
enum UserRole { 
  admin, 
  dosen, 
  mahasiswa, 
  teknisi;

  static UserRole? fromString(String? role) {
    if (role == null) return null;
    switch (role.trim().toLowerCase()) {
      case 'admin':
        return UserRole.admin;
      case 'dosen':
        return UserRole.dosen;
      case 'mahasiswa':
        return UserRole.mahasiswa;
      case 'teknisi':
      case 'staff':
        return UserRole.teknisi;
      default:
        return null;
    }
  }
}

class MainLayoutShell extends StatefulWidget {
  final UserRole userRole; // Role ini didapat setelah user login

  const MainLayoutShell({super.key, required this.userRole});

  @override
  State<MainLayoutShell> createState() => _MainLayoutShellState();
}

class _MainLayoutShellState extends State<MainLayoutShell> {
  int _currentIndex = 0;

  // 2. Fungsi untuk mengambil daftar halaman berdasarkan Role (Prinsip SRP)
  List<Widget> _getPagesForRole() {
    switch (widget.userRole) {
      case UserRole.admin:
        return const [
          AdminDashboardView(),
          AdminLaporanFasilitasView(),
          AdminAspirasiView(),
          AdminUserView(),
        ];
      case UserRole.dosen:
        return const [
          HomeDosenView(),
          RoleProfileView(role: 'dosen'),
        ];
      case UserRole.mahasiswa:
        return const [
          HomeView(),
          LaporanFasilitasMahasiswaView(),
          AspirasiView(),
          RoleProfileView(role: 'mahasiswa'),
        ];
      case UserRole.teknisi:
        return const [
          HomeTeknisiView(),
          LaporanFasilitasMahasiswaView(role: 'teknisi'),
          RiwayatTugasView(),
          RoleProfileView(role: 'teknisi'),
        ];
    }
  }

  // 3. Fungsi untuk mengambil menu BottomNavBar berdasarkan Role (Prinsip DRY)
  List<BottomNavigationBarItem> _getNavBarItemsForRole() {
    switch (widget.userRole) {
      case UserRole.admin:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_rounded), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.apartment_rounded), label: 'Layanan'),
          BottomNavigationBarItem(icon: Icon(Icons.campaign_rounded), label: 'Aspirasi'),
          BottomNavigationBarItem(icon: Icon(Icons.group_rounded), label: 'User'),
        ];
      case UserRole.dosen:
        return const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: 'Profil'),
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

  @override
  Widget build(BuildContext context) {
    // Ambil data dinamis sesuai role saat ini
    final pages = _getPagesForRole();
    final navBarItems = _getNavBarItemsForRole();

    return Scaffold(
      // SLOT UTAMA: Halaman berganti sesuai index, dan daftarnya sudah disaring oleh role
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),

      // BottomBar dinamis yang jumlah tombol dan ikonnya otomatis berubah
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed, // Menjaga layout tetap rapi jika menu > 3
        selectedItemColor: const Color(0xFF1E3A5F),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: navBarItems,
      ),
    );
  }
}
