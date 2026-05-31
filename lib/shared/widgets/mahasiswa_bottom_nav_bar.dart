import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/laporan_fasilitas_mahasiswa_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/profile/view/role_profile_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_bottom_nav_bar.dart';

enum MahasiswaNavDestination { home, laporanFasilitas, aspirasi, profil }

class MahasiswaBottomNavBar extends StatelessWidget {
  const MahasiswaBottomNavBar({
    super.key,
    required this.selected
  });

  final MahasiswaNavDestination selected;

  static const _items = [
    _NavItem(label: 'Home', icon: Icons.home_rounded),
    _NavItem(label: 'Laporan Fasilitas', icon: Icons.assignment_outlined),
    _NavItem(label: 'Aspirasi', icon: Icons.chat_bubble_outline_rounded),
    _NavItem(label: 'Profil', icon: Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final navItems = _items.map((e) => AppNavItem(label: e.label, icon: e.icon)).toList();
    return AppBottomNavBar(
      items: navItems,
      selectedIndex: selected.index,
      onTap: (index) => _navigate(
        context,
        MahasiswaNavDestination.values[index],
      ),
    );
  }

  void _navigate(BuildContext context, MahasiswaNavDestination target) {
    if (target == selected) return;

    Widget page;
    switch (target) {
      case MahasiswaNavDestination.home:
        page = const HomeView();
        break;
      case MahasiswaNavDestination.laporanFasilitas:
        page = const LaporanFasilitasMahasiswaView();
        break;
      case MahasiswaNavDestination.aspirasi:
        page = const AspirasiView();
        break;
      case MahasiswaNavDestination.profil:
        page = RoleProfileView(role: 'mahasiswa');
        break;
    }

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }
}

class _NavItem {
  final String label;
  final IconData icon;

  const _NavItem({required this.label, required this.icon});
}
