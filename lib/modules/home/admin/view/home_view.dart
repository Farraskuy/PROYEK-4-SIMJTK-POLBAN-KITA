// ============================================================
// FILE: modules/admin/dashboard/view/admin_dashboard_view.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../model/home_model.dart';

// ============================================================
// DESIGN TOKENS
// ============================================================
class _C {
  static const primary = Color(0xFF1A3A6B);
  static const primaryDark = Color(0xFF0D2545);
  static const primaryLight = Color(0xFF2B5BAE);
  static const accent = Color(0xFF3E7BFA);
  static const surface = Color(0xFFF0F4FA);
  static const white = Colors.white;
  static const cardBg = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textLight = Color(0xFFB0B8CC);
  static const divider = Color(0xFFE5E9F2);
  static const navActive = Color(0xFF1A3A6B);
  static const navInactive = Color(0xFF9CA3AF);
  static const navBg = Color(0xFF0D2545);
  static const chipPerbaikan = Color(0xFF2B5BAE);
  static const chipPerbaikanBg = Color(0xFFE3F2FD);
  static const chipLaporan = Color(0xFFD32F2F);
  static const chipLaporanBg = Color(0xFFFFEBEE);
  static const chipAspirasi = Color(0xFF2E7D32);
  static const chipAspirasi_bg = Color(0xFFE8F5E9);
  static const chipLostFound = Color(0xFFE65100);
  static const chipLostFoundBg = Color(0xFFFFF3E0);
  static const chipDelegasi = Color(0xFF6A1B9A);
  static const chipDelegasiBg = Color(0xFFF3E5F5);
  static const positifColor = Color(0xFF4CAF50);
  static const tindakanBg = Color(0xFFEDF2FF);
}

// ============================================================
// ADMIN DASHBOARD VIEW
// ============================================================
class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminDashboardController());

    return Scaffold(
      backgroundColor: _C.surface,
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _C.primary),
          );
        }
        return RefreshIndicator(
          color: _C.primary,
          onRefresh: ctrl.onRefresh,
          child: CustomScrollView(
            slivers: [
              // ---- APP BAR ----
              _buildSliverAppBar(ctrl),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- SAPAAN ----
                      _buildSapaan(ctrl),
                      const SizedBox(height: 20),

                      // ---- KARTU TOTAL LAPORAN ----
                      _buildKartuTotalLaporan(ctrl),
                      const SizedBox(height: 14),

                      // ---- KARTU RINGKASAN (2 kolom) ----
                      _buildKartuRingkasan(ctrl),
                      const SizedBox(height: 24),

                      // ---- TINDAKAN CEPAT ----
                      _buildTindakanCepat(ctrl),
                      const SizedBox(height: 24),

                      // ---- AKTIVITAS TERBARU ----
                      _buildAktivitasHeader(ctrl),
                      const SizedBox(height: 12),
                      _buildAktivitasList(ctrl),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNavBar(ctrl),
    );
  }

  // ============================================================
  // SLIVER APP BAR
  // ============================================================
  SliverAppBar _buildSliverAppBar(AdminDashboardController ctrl) {
    return SliverAppBar(
      backgroundColor: _C.white,
      elevation: 0,
      floating: true,
      pinned: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Avatar admin
            CircleAvatar(
              radius: 20,
              backgroundColor: _C.primary,
              child: const Icon(Icons.admin_panel_settings_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Institution Admin',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _C.textPrimary,
                ),
              ),
            ),
            // Notifikasi
            Obx(() => Stack(
                  children: [
                    IconButton(
                      onPressed: ctrl.onNotifikasiTapped,
                      icon: const Icon(Icons.notifications_outlined,
                          color: _C.textPrimary, size: 26),
                    ),
                    if (ctrl.unreadNotif.value > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle),
                          alignment: Alignment.center,
                          child: Text(
                            '${ctrl.unreadNotif.value}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // SAPAAN
  // ============================================================
  Widget _buildSapaan(AdminDashboardController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          ctrl.sapaanAdmin.toUpperCase(),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _C.textSecondary,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),

        Obx(() => Text(
              ctrl.currentAdmin.value.name,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: _C.textPrimary,
                height: 1.1,
              ),
            )),
        const SizedBox(height: 4),
        const Text(
          'Ringkasan aktivitas institusi hari ini.',
          style: TextStyle(fontSize: 13, color: _C.textSecondary),
        ),
      ],
    );
  }

  // ============================================================
  // KARTU TOTAL LAPORAN (besar, dark blue)
  // ============================================================
  Widget _buildKartuTotalLaporan(AdminDashboardController ctrl) {
    return Obx(() {
      final stat = ctrl.statistikLaporan.value;
      if (stat == null) return const SizedBox.shrink();

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_C.primary, _C.primaryDark],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: _C.primary.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Konten kiri
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total Laporan',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatAngka(stat.totalLaporan),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        stat.isPositif
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: stat.isPositif
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        stat.persenLabel,
                        style: TextStyle(
                          color: stat.isPositif
                              ? Colors.greenAccent
                              : Colors.redAccent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Progress bar status laporan
                  _LaporanProgressBar(stat: stat),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Ikon kanan
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.description_outlined,
                  color: Colors.white, size: 24),
            ),
          ],
        ),
      );
    });
  }

  // ============================================================
  // KARTU RINGKASAN (2 kolom)
  // ============================================================
  Widget _buildKartuRingkasan(AdminDashboardController ctrl) {
    return Obx(() {
      final r = ctrl.statistikRingkasan.value;
      if (r == null) return const SizedBox.shrink();

      return Row(
        children: [
          Expanded(
            child: _RingkasanCard(
              icon: Icons.engineering_rounded,
              label: 'Teknisi Aktif',
              value: '${r.teknisiAktif}',
              iconColor: _C.primaryLight,
              iconBg: _C.tindakanBg,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _RingkasanCard(
              icon: Icons.pending_actions_rounded,
              label: 'Aspirasi Tertunda',
              value: '${r.aspirasiTertunda}',
              iconColor: const Color(0xFFE65100),
              iconBg: const Color(0xFFFFF3E0),
            ),
          ),
        ],
      );
    });
  }

  // ============================================================
  // TINDAKAN CEPAT
  // ============================================================
  Widget _buildTindakanCepat(AdminDashboardController ctrl) {
    const iconMap = {
      TindakanCepatType.tugaskan: Icons.assignment_ind_rounded,
      TindakanCepatType.siarkan: Icons.campaign_rounded,
      TindakanCepatType.moderasi: Icons.verified_user_rounded,
      TindakanCepatType.tambahAgenda: Icons.calendar_month_rounded,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tindakan Cepat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _C.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Obx(() => Row(
              children: ctrl.tindakanCepatList.map((item) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                      right: ctrl.tindakanCepatList.last == item ? 0 : 10,
                    ),
                    child: _TindakanCepatButton(
                      label: item.label,
                      icon: iconMap[item.type] ?? Icons.flash_on_rounded,
                      onTap: () => ctrl.onTindakanCepatTapped(item.type),
                    ),
                  ),
                );
              }).toList(),
            )),
      ],
    );
  }

  // ============================================================
  // AKTIVITAS TERBARU HEADER
  // ============================================================
  Widget _buildAktivitasHeader(AdminDashboardController ctrl) {
    return Row(
      children: [
        const Text(
          'Aktivitas Terbaru',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _C.textPrimary,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: ctrl.onLihatSemuaAktivitas,
          child: const Text(
            'Lihat Semua',
            style: TextStyle(
              fontSize: 13,
              color: _C.primaryLight,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // AKTIVITAS LIST
  // ============================================================
  Widget _buildAktivitasList(AdminDashboardController ctrl) {
    return Obx(() => ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: ctrl.aktivitasList.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = ctrl.aktivitasList[index];
            return _AktivitasCard(
              aktivitas: item,
              onTap: () => ctrl.onAktivitasTapped(item),
            );
          },
        ));
  }

  // ============================================================
  // BOTTOM NAV BAR (dark background sesuai screenshot)
  // ============================================================
  Widget _buildBottomNavBar(AdminDashboardController ctrl) {
    const icons = [
      Icons.dashboard_rounded,
      Icons.apartment_rounded,
      Icons.campaign_rounded,
      Icons.group_rounded,
    ];
    final items = AdminNavItemModel.items();

    return Obx(() => Container(
          decoration: BoxDecoration(
            color: _C.navBg,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 12,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 62,
              child: Row(
                children: List.generate(items.length, (i) {
                  final active = ctrl.selectedNavIndex.value == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => ctrl.onNavTapped(i),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (active)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(icons[i],
                                  size: 20, color: Colors.white),
                            )
                          else
                            Icon(icons[i],
                                size: 22,
                                color: Colors.white.withOpacity(0.5)),
                          const SizedBox(height: 3),
                          Text(
                            items[i].label,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: active
                                  ? Colors.white
                                  : Colors.white.withOpacity(0.5),
                              letterSpacing: 0.5,
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
        ));
  }

  // ---- HELPER ----
  String _formatAngka(int n) {
    if (n >= 1000) {
      final s = n.toString();
      return '${s.substring(0, s.length - 3)},${s.substring(s.length - 3)}';
    }
    return n.toString();
  }
}

// ============================================================
// WIDGET: Progress Bar status laporan (dalam kartu biru)
// ============================================================
class _LaporanProgressBar extends StatelessWidget {
  final StatistikLaporanModel stat;
  const _LaporanProgressBar({required this.stat});

  @override
  Widget build(BuildContext context) {
    final total = stat.totalLaporan > 0 ? stat.totalLaporan : 1;
    return Column(
      children: [
        Row(
          children: [
            _BarItem(
              label: 'Selesai',
              value: stat.laporanResolved / total,
              color: Colors.greenAccent,
            ),
            const SizedBox(width: 6),
            _BarItem(
              label: 'Proses',
              value: stat.laporanInProgress / total,
              color: Colors.amberAccent,
            ),
            const SizedBox(width: 6),
            _BarItem(
              label: 'Pending',
              value: stat.laporanPending / total,
              color: Colors.orangeAccent,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _LegendDot(color: Colors.greenAccent, label: 'Selesai ${stat.laporanResolved}'),
            const SizedBox(width: 10),
            _LegendDot(color: Colors.amberAccent, label: 'Proses ${stat.laporanInProgress}'),
            const SizedBox(width: 10),
            _LegendDot(color: Colors.orangeAccent, label: 'Pending ${stat.laporanPending}'),
          ],
        ),
      ],
    );
  }
}

class _BarItem extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _BarItem(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: (value * 100).round().clamp(1, 100),
      child: Container(
        height: 6,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 7,
          height: 7,
          decoration:
              BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: Colors.white60, fontSize: 10)),
      ],
    );
  }
}

// ============================================================
// WIDGET: Kartu Ringkasan Kecil
// ============================================================
class _RingkasanCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBg;

  const _RingkasanCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: _C.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET: Tombol Tindakan Cepat
// ============================================================
class _TindakanCepatButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _TindakanCepatButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _C.tindakanBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 22, color: _C.primary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _C.textPrimary,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: Kartu Aktivitas Terbaru
// ============================================================
class _AktivitasCard extends StatelessWidget {
  final AktivitasTerbaruModel aktivitas;
  final VoidCallback onTap;

  const _AktivitasCard({required this.aktivitas, required this.onTap});

  // Warna & ikon per tipe aktivitas
  Color get _chipColor {
    switch (aktivitas.tipe) {
      case TipeAktivitas.perbaikan:
        return _C.chipPerbaikan;
      case TipeAktivitas.laporanBaru:
        return _C.chipLaporan;
      case TipeAktivitas.aspirasiBaru:
        return _C.chipAspirasi;
      case TipeAktivitas.lostFound:
        return _C.chipLostFound;
      case TipeAktivitas.delegasi:
        return _C.chipDelegasi;
    }
  }

  Color get _chipBgColor {
    switch (aktivitas.tipe) {
      case TipeAktivitas.perbaikan:
        return _C.chipPerbaikanBg;
      case TipeAktivitas.laporanBaru:
        return _C.chipLaporanBg;
      case TipeAktivitas.aspirasiBaru:
        return _C.chipAspirasi_bg;
      case TipeAktivitas.lostFound:
        return _C.chipLostFoundBg;
      case TipeAktivitas.delegasi:
        return _C.chipDelegasiBg;
    }
  }

  IconData get _tipeIcon {
    switch (aktivitas.tipe) {
      case TipeAktivitas.perbaikan:
        return Icons.build_circle_rounded;
      case TipeAktivitas.laporanBaru:
        return Icons.report_problem_rounded;
      case TipeAktivitas.aspirasiBaru:
        return Icons.campaign_rounded;
      case TipeAktivitas.lostFound:
        return Icons.search_rounded;
      case TipeAktivitas.delegasi:
        return Icons.assignment_ind_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.divider, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon tipe
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _chipBgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_tipeIcon, size: 22, color: _chipColor),
            ),
            const SizedBox(width: 12),

            // Konten
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label tipe + jam
                  Row(
                    children: [
                      Text(
                        aktivitas.tipe.label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _chipColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        aktivitas.jamLabel,
                        style: const TextStyle(
                          fontSize: 11,
                          color: _C.textLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Judul
                  Text(
                    aktivitas.judul,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _C.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // Deskripsi
                  Text(
                    aktivitas.deskripsi,
                    style: const TextStyle(
                      fontSize: 12,
                      color: _C.textSecondary,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}