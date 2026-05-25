// ============================================================
// FILE: modules/home/teknisi/view/home_teknisi_view.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// MODIFIKASI: Tugas Mendesak dari DB laporan_fasilitas, sort by vote_score
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import '../controller/home_controller.dart';
import '../model/home_model.dart';
import '../view/analisa_kerusakan_view.dart';
import '../view/usulan_pemeliharaan_view.dart';
import '../view/penghapusan_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import '../../../laporan_fasilitas/view/laporan_fasilitas_mahasiswa_view.dart';
import '../../../riwayat_tugas/view/riwayat_tugas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/profile/view/role_profile_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_bottom_nav_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';

// ============================================================
// DESIGN TOKENS
// ============================================================
class _C {
  static const primary = Color(0xFF1A3A6B);
  static const primaryLight = Color(0xFF2B5BAE);
  static const surface = Color(0xFFF0F4FA);
  static const white = Colors.white;
  static const cardBg = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textLight = Color(0xFFB0B8CC);
  static const divider = Color(0xFFE5E9F2);
  static const navBg = Color(0xFFFFFFFF);
  static const navActive = Color(0xFF1A3A6B);
  static const navInactive = Color(0xFF9CA3AF);
  static const selesaiBg = Color(0xFF1A3A6B);
  static const pendingBg = Color(0xFFEDF2FF);
  static const highPriorityBadge = Color(0xFFFFEBEE);
  static const highPriorityText = Color(0xFFD32F2F);
  static const medPriorityBadge = Color(0xFFE3F2FD);
  static const medPriorityText = Color(0xFF1565C0);
  static const lowPriorityBadge = Color(0xFFF5F5F5);
  static const lowPriorityText = Color(0xFF616161);
  static const jaringanIcon = Color(0xFF2B5BAE);
  static const jaringanIconBg = Color(0xFFE8EDF8);
  static const hardwareIcon = Color(0xFFE53935);
  static const hardwareIconBg = Color(0xFFFFEBEE);
  static const acIcon = Color(0xFF2E7D32);
  static const acIconBg = Color(0xFFE8F5E9);
  static const umIcon = Color(0xFF6A1B9A);
  static const umIconBg = Color(0xFFF3E5F5);
  static const upvoteBg = Color(0xFFE8F5E9);
  static const upvoteText = Color(0xFF2E7D32);
}

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

// ============================================================
// MODUL MAINTENANCE SECTION
// ============================================================
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
  ];

  void _navigate(BuildContext context, String route) {
    switch (route) {
      case 'analisa':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AnalisaKerusakanView()),
        );
        break;
      case 'pemeliharaan':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UsulanPemeliharaanView()),
        );
        break;
      case 'penghapusan':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UsulanPenghapusanView()),
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
          crossAxisCount: 3,
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
                        fontSize: 10,
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
              _buildAppBar(ctrl, context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSapaan(ctrl),
                      const SizedBox(height: 20),
                      _buildStatistik(ctrl),
                      const SizedBox(height: 28),
                      const ModulMaintenanceSection(),
                      const SizedBox(height: 28),
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
  // SAPAAN
  // ============================================================
  Widget _buildSapaan(HomeTeknisiController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            'Hallo, ${ctrl.currentTeknisi.value.name}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          ctrl.sapaan,
          style: const TextStyle(fontSize: 13, color: _C.textSecondary),
        ),
      ],
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
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.assignment_rounded,
                            color: _C.primary, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'TUGAS AKTIF',
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
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    decoration: const BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.only(
                          topRight: Radius.circular(16)),
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
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 18),
                    decoration: const BoxDecoration(
                      color: AppColors.blueSoft,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(16)),
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
                              child: const Icon(Icons.access_time_rounded,
                                  color: _C.primary, size: 18),
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
            color: _C.textPrimary,
          ),
        ),
        const SizedBox(width: 6),
        // Label keterangan sort
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: _C.upvoteBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: const [
              Icon(Icons.arrow_upward_rounded,
                  size: 11, color: _C.upvoteText),
              SizedBox(width: 3),
              Text(
                'Top Upvote',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: _C.upvoteText,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AnalisaKerusakanView()),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.redSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.analytics_rounded,
                    color: Color(0xFFD32F2F), size: 16),
                SizedBox(width: 4),
                Text(
                  'Analisa',
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
  // TUGAS MENDESAK LIST — dari LaporanFasilitasModel
  // ============================================================
  Widget _buildTugasMendesakList(HomeTeknisiController ctrl) {
    return Obx(() {
      final list = ctrl.tugasMendesak;

      if (list.isEmpty) {
        return _EmptyMendesak();
      }

      // Tampilkan maksimal 5 tugas teratas di home
      final displayList = list.take(5).toList();

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayList.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          return _LaporanCard(
            laporan: displayList[index],
            onTap: () => ctrl.onTugasTapped(displayList[index]),
          );
        },
      );
    });
  }

  // ============================================================
  // BOTTOM NAV BAR
  // ============================================================
  void _navigateBottomBar(
      BuildContext context, HomeTeknisiNavTarget? target) {
    if (target == null) return;
    if (target == HomeTeknisiNavTarget.tugas) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const LaporanFasilitasMahasiswaView(role: 'teknisi'),
        ),
      );
      return;
    }
    if (target == HomeTeknisiNavTarget.riwayat) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RiwayatTugasView()),
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

  Widget _buildBottomNavBar(
      BuildContext context, HomeTeknisiController ctrl) {
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
        onTap: (index) =>
            _navigateBottomBar(context, ctrl.onNavTapped(index)),
      ),
    );
  }
}

// ============================================================
// WIDGET: Kartu Laporan Mendesak (dari LaporanFasilitasModel)
// ============================================================
class _LaporanCard extends StatelessWidget {
  final LaporanFasilitasModel laporan;
  final VoidCallback onTap;

  const _LaporanCard({required this.laporan, required this.onTap});

  // Badge warna berdasarkan status
  Color get _statusBg {
    switch (laporan.status) {
      case StatusLaporan.pending:
        return const Color(0xFFFFF3E0);
      case StatusLaporan.in_progress:
        return const Color(0xFFE3F2FD);
      case StatusLaporan.escalated_to_upt:
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFE8F5E9);
    }
  }

  Color get _statusText {
    switch (laporan.status) {
      case StatusLaporan.pending:
        return const Color(0xFFE65100);
      case StatusLaporan.in_progress:
        return const Color(0xFF1565C0);
      case StatusLaporan.escalated_to_upt:
        return const Color(0xFFD32F2F);
      default:
        return const Color(0xFF2E7D32);
    }
  }

  String get _statusLabel {
    switch (laporan.status) {
      case StatusLaporan.pending:
        return 'Pending';
      case StatusLaporan.in_progress:
        return 'Dikerjakan';
      case StatusLaporan.escalated_to_upt:
        return 'Eskalasi UPT';
      default:
        return 'Selesai';
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
          border: Border.all(color: const Color(0xFFE5E9F2), width: 1),
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
              // Garis kiri — warna berdasarkan vote score
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: laporan.vote_score >= 10
                      ? const Color(0xFFE53935)
                      : laporan.vote_score >= 5
                          ? _C.primary
                          : const Color(0xFF9CA3AF),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    bottomLeft: Radius.circular(14),
                  ),
                ),
              ),

              // Ikon kategori
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 0, 14),
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: _kategoriIconBg(laporan.lokasi),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _kategoriIcon(laporan.lokasi),
                    size: 22,
                    color: _kategoriIconColor(laporan.lokasi),
                  ),
                ),
              ),

              // Konten utama
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul
                      Text(
                        laporan.judul,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 12, color: _C.textLight),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              laporan.lokasi,
                              style: const TextStyle(
                                  fontSize: 12, color: _C.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Badge status + upvote count
                      Row(
                        children: [
                          // Status badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _statusBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _statusLabel,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: _statusText,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),

                          // Upvote count — kunci sorting tugas mendesak
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _C.upvoteBg,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.arrow_upward_rounded,
                                    size: 11, color: _C.upvoteText),
                                const SizedBox(width: 3),
                                Text(
                                  '${laporan.vote_score}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _C.upvoteText,
                                  ),
                                ),
                              ],
                            ),
                          ),
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
        border: Border.all(color: const Color(0xFFE5E9F2), width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.check_circle_outline_rounded,
              size: 44, color: Color(0xFF81C784)),
          SizedBox(height: 10),
          Text(
            'Tidak ada laporan mendesak',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.body,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Belum ada laporan fasilitas yang masuk',
            style: TextStyle(fontSize: 12, color: _C.textLight),
          ),
        ],
      ),
    );
  }
}