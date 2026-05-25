import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/view/home_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/laporan_fasilitas_mahasiswa_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/profile/view/role_profile_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final active = selected.index == index;
              return Expanded(
                child: InkWell(
                  onTap: () => _navigate(
                    context,
                    MahasiswaNavDestination.values[index],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 40,
                        height: 28,
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.blueSoft
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          item.icon,
                          size: 22,
                          color: active ? AppColors.primary : AppColors.muted,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          height: 1.0,
                          fontWeight:
                              active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? AppColors.primary : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
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
