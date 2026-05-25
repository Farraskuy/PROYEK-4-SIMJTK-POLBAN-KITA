// ============================================================
// FILE: modules/home/teknisi/view/home_view.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import '../controller/home_controller.dart';
import '../model/home_model.dart';
import '../view/analisa_kerusakan_view.dart';
import '../view/kontrol_barang_view.dart';
import '../view/usulan_pemeliharaan_view.dart';
import '../view/penghapusan_view.dart';
// import '../../../log_harian_teknis/view/log_harian_teknis_view.dart';
import '../../../laporan_fasilitas/view/laporan_fasilitas_mahasiswa_view.dart';
import '../../../riwayat_tugas/view/riwayat_tugas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/profile/view/role_profile_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_bottom_nav_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';

// ============================================================
// ICON MAP untuk kategori fasilitas
// ============================================================
IconData _kategoriIcon(String kategori) {
  switch (kategori) {
    case 'Jaringan Internet':
      return Icons.wifi_rounded;
    case 'Perangkat PC':
      return Icons.computer_rounded;
    case 'AC / Pendingin':
      return Icons.ac_unit_rounded;
    case 'Kebersihan':
      return Icons.cleaning_services_rounded;
    case 'Listrik & Proyektor':
      return Icons.electrical_services_rounded;
    case 'Furnitur':
      return Icons.chair_rounded;
    default:
      return Icons.build_rounded;
  }
}

Color _kategoriIconColor(String kategori) {
  switch (kategori) {
    case 'Jaringan Internet':
      return AppColors.primary;
    case 'Perangkat PC':
      return AppColors.danger;
    case 'AC / Pendingin':
      return AppColors.success;
    default:
      return AppColors.purple;
  }
}

Color _kategoriIconBg(String kategori) {
  switch (kategori) {
    case 'Jaringan Internet':
      return AppColors.blueSoft;
    case 'Perangkat PC':
      return AppColors.redSoft;
    case 'AC / Pendingin':
      return AppColors.greenSoft;
    default:
      return AppColors.purpleSoft;
  }
}

// Widget section Modul Maintenance
class ModulMaintenanceSection extends StatelessWidget {
  const ModulMaintenanceSection({super.key});

  static const _menus = [
    {
      'label': 'Analisa\nKerusakan',
      'icon': Icons.analytics_rounded,
      'color': AppColors.danger,
      'route': 'analisa',
    },
    {
      'label': 'Kontrol\nBarang/Alat',
      'icon': Icons.inventory_2_outlined,
      'color': AppColors.primary,
      'route': 'kontrol',
    },
    {
      'label': 'Usulan\nPemeliharaan',
      'icon': Icons.build_circle_outlined,
      'color': AppColors.success,
      'route': 'pemeliharaan',
    },
    {
      'label': 'Usulan\nPenghapusan',
      'icon': Icons.delete_outline_rounded,
      'color': AppColors.warning,
      'route': 'penghapusan',
    },
    {
      'label': 'Log\nHarian',
      'icon': Icons.note_alt_outlined,
      'color': AppColors.purple,
      'route': 'log',
    },
  ];

  void _navigate(BuildContext context, String route) {
    switch (route) {
      case 'analisa':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AnalisaKerusakanView()),
        );
        break;
      case 'kontrol':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DataKontrolBarangView(),
          ),
        );
        break;
      case 'pemeliharaan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UsulanPemeliharaanView(),
          ),
        );
        break;
      case 'penghapusan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const UsulanPenghapusanView(),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Modul Maintenance',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.title,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: _menus.map((m) {
            final color = (m['color'] is Color) ? m['color'] as Color : AppColors.warning;
            final icon = (m['icon'] is IconData) ? m['icon'] as IconData : Icons.help_outline;
            return GestureDetector(
              onTap: () => _navigate(context, m['route'] as String),
              child: Container(
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      m['label'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 8,
                        color: color,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ============================================================
// HOME TEKNISI VIEW
// ============================================================
class HomeTeknisiView extends StatelessWidget {
  const HomeTeknisiView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(HomeTeknisiController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: ctrl.onRefresh,
          child: CustomScrollView(
            slivers: [
              // ---- APP BAR ----
              _buildAppBar(ctrl, context),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- STATISTIK TUGAS ----
                      _buildStatistik(ctrl),
                      const SizedBox(height: 24),

                      const ModulMaintenanceSection(),
                      const SizedBox(height: 24),

                      // ---- TUGAS MENDESAK ----
                      _buildTugasMendesakHeader(context),
                      const SizedBox(height: 12),
                      _buildTugasMendesakList(ctrl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNavBar(context, ctrl),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================
  Widget _buildAppBar(HomeTeknisiController ctrl, BuildContext context) {
    return Obx(
      () => AppHomeAppBar(
        title: 'Halo, ${ctrl.currentTeknisi.value.name}',
        subtitle: 'Teknisi JTK',
        avatarIcon: Icons.engineering_rounded,
        avatarText: ctrl.currentTeknisi.value.name.isEmpty
            ? null
            : ctrl.currentTeknisi.value.name[0].toUpperCase(),
        unreadCount: ctrl.unreadNotif.value,
        onNotificationTap: ctrl.onNotifikasiTapped,
      ),
    );
  }

  // ============================================================
  // STATISTIK TUGAS
  // ============================================================
  Widget _buildStatistik(HomeTeknisiController ctrl) {
    return Obx(() {
      final stat = ctrl.statistik.value;
      if (stat == null) return const SizedBox.shrink();

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Kolom kiri — total tugas
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.assignment_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'TUGAS HARI INI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${stat.totalTugas}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Kolom kanan — SELESAI & PENDING
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  // SELESAI (dark card)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SELESAI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white60,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${stat.tugasSelesai}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // PENDING (light card)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.blueSoft,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PENDING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.body,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${stat.tugasPending}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.title,
                                height: 1.0,
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.access_time_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ============================================================
  // TUGAS MENDESAK HEADER
  // ============================================================
  Widget _buildTugasMendesakHeader(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Tugas Mendesak',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.title,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AnalisaKerusakanView(),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.redSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.analytics_rounded,
                  color: AppColors.danger,
                  size: 14,
                ),
                SizedBox(width: 4),
                Text(
                  "Analisa",
                  style: TextStyle(
                    color: AppColors.danger,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TUGAS MENDESAK LIST
  // ============================================================
  Widget _buildTugasMendesakList(HomeTeknisiController ctrl) {
    return Obx(() {
      final list = ctrl.tugasMendesak;

      if (list.isEmpty) {
        return _EmptyMendesak();
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: list.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _TugasCard(
            tugas: list[index],
            onTap: () => ctrl.onTugasTapped(list[index]),
            onMulai: () => ctrl.onMulaiKerjakan(list[index]),
            onSelesai: () => ctrl.onSelesaikanTugas(list[index]),
          );
        },
      );
    });
  }

  // ============================================================
  // BOTTOM NAV BAR
  // ============================================================
  void _navigateBottomBar(BuildContext context, HomeTeknisiNavTarget? target) {
    if (target == null) return;
    if (target == HomeTeknisiNavTarget.tugas) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              const LaporanFasilitasMahasiswaView(role: 'teknisi'),
        ),
      );
      return;
    }
    if (target == HomeTeknisiNavTarget.riwayat) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RiwayatTugasView()),
      );
      return;
    }
    if (target == HomeTeknisiNavTarget.profile) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const RoleProfileView(role: 'teknisi'),
        ),
      );
    }
  }

  Widget _buildBottomNavBar(BuildContext context, HomeTeknisiController ctrl) {
    const items = [
      AppNavItem(label: 'Home', icon: Icons.dashboard_rounded),
      AppNavItem(label: 'Tugas', icon: Icons.assignment_rounded),
      AppNavItem(label: 'Riwayat', icon: Icons.history_rounded),
      AppNavItem(label: 'Profil', icon: Icons.person_rounded),
    ];

    return Obx(
      () => AppBottomNavBar(
        items: items,
        selectedIndex: ctrl.selectedNavIndex.value,
        onTap: (index) => _navigateBottomBar(context, ctrl.onNavTapped(index)),
      ),
    );
  }
}

// ============================================================
// WIDGET: Kartu Tugas Mendesak
// ============================================================
class _TugasCard extends StatelessWidget {
  final TugasTeknisiModel tugas;
  final VoidCallback onTap;
  final VoidCallback onMulai;
  final VoidCallback onSelesai;

  const _TugasCard({
    required this.tugas,
    required this.onTap,
    required this.onMulai,
    required this.onSelesai,
  });

  Color get _barColor {
    switch (tugas.prioritas) {
      case PrioritasTugas.high:
        return AppColors.danger;
      case PrioritasTugas.medium:
        return AppColors.primary;
      case PrioritasTugas.low:
        return AppColors.muted;
    }
  }

  Color get _badgeBg {
    switch (tugas.prioritas) {
      case PrioritasTugas.high:
        return AppColors.redSoft;
      case PrioritasTugas.medium:
        return AppColors.blueSoft;
      case PrioritasTugas.low:
        return AppColors.greySoft;
    }
  }

  Color get _badgeText {
    switch (tugas.prioritas) {
      case PrioritasTugas.high:
        return AppColors.danger;
      case PrioritasTugas.medium:
        return AppColors.primary;
      case PrioritasTugas.low:
        return AppColors.body;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: _barColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 0, 14),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _kategoriIconBg(tugas.kategori),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _kategoriIcon(tugas.kategori),
                    size: 22,
                    color: _kategoriIconColor(tugas.kategori),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tugas.judul,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppColors.title,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (!tugas.isSynced) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.orangeSoft,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Offline',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.muted,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              tugas.lokasi,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.body,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _badgeBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              tugas.prioritas.label,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _badgeText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (tugas.estimasiSelesai != null) ...[
                            const Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: AppColors.muted,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              tugas.jamEstimasi,
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.body,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: Empty State Tugas Mendesak
// ============================================================
class _EmptyMendesak extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 44,
            color: AppColors.success,
          ),
          SizedBox(height: 10),
          Text(
            'Tidak ada tugas mendesak',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.body,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Semua tugas high priority sudah diselesaikan!',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
