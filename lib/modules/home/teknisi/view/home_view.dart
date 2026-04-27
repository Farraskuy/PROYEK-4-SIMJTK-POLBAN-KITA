// ============================================================
// FILE: modules/home/teknisi/view/home_teknisi_view.dart
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
  static const selesaiBg = Color(0xFF1A3A6B); // dark blue card
  static const pendingBg = Color(0xFFEDF2FF); // light blue card
  static const highPriorityBar = Color(0xFFE53935);
  static const medPriorityBar = Color(0xFF1A3A6B);
  static const lowPriorityBar = Color(0xFF9CA3AF);
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
  static const offlineBadge = Color(0xFFFFF3E0);
  static const offlineText = Color(0xFFE65100);
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
      return _C.jaringanIcon;
    case 'Perangkat PC':
      return _C.hardwareIcon;
    case 'AC / Pendingin':
      return _C.acIcon;
    default:
      return _C.umIcon;
  }
}

Color _kategoriIconBg(String kategori) {
  switch (kategori) {
    case 'Jaringan Internet':
      return _C.jaringanIconBg;
    case 'Perangkat PC':
      return _C.hardwareIconBg;
    case 'AC / Pendingin':
      return _C.acIconBg;
    default:
      return _C.umIconBg;
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
              _buildAppBar(ctrl, context),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ---- SAPAAN ----
                      _buildSapaan(ctrl),
                      const SizedBox(height: 20),

                      // ---- STATISTIK TUGAS ----
                      _buildStatistik(ctrl),
                      const SizedBox(height: 28),

                      // ---- TUGAS MENDESAK ----
                      _buildTugasMendesakHeader(),
                      const SizedBox(height: 12),
                      _buildTugasMendesakList(ctrl),
                      const SizedBox(height: 28),
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
  // APP BAR
  // ============================================================
  SliverAppBar _buildAppBar(HomeTeknisiController ctrl, BuildContext context) {
    return SliverAppBar(
      backgroundColor: _C.white,
      elevation: 0,
      floating: true,
      pinned: false,
      titleSpacing: 0,
      leading: IconButton(                          // ← replace the menu icon
      icon: const Icon(Icons.arrow_back_ios_new_rounded,
          color: _C.textPrimary, size: 22),
      onPressed: () => Navigator.pop(context),    // ← pops back to LoginView
      ),
      title: const Text(
        'Technician Portal',
        style: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: _C.primary,
        ),
      ),
      actions: [
        // Avatar teknisi
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: Obx(
            () => CircleAvatar(
              radius: 19,
              backgroundColor: _C.primary,
              child: Text(
                ctrl.currentTeknisi.value.name[0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ],
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
  // STATISTIK TUGAS — kartu gabungan sesuai Figma
  // ============================================================
  Widget _buildStatistik(HomeTeknisiController ctrl) {
    return Obx(() {
      final stat = ctrl.statistik.value;
      if (stat == null) return const SizedBox.shrink();

      return Container(
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _C.divider, width: 1),
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
                          color: _C.primary,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'TUGAS HARI INI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _C.textSecondary,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${stat.totalTugas}',
                      style: const TextStyle(
                        fontSize: 52,
                        fontWeight: FontWeight.w800,
                        color: _C.textPrimary,
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
                      vertical: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: _C.selesaiBg,
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
                                fontSize: 32,
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
                      vertical: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: _C.pendingBg,
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
                            color: _C.textSecondary,
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
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: _C.textPrimary,
                                height: 1.0,
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: _C.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.access_time_rounded,
                                color: _C.primary,
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
  Widget _buildTugasMendesakHeader() {
    return Row(
      children: [
        const Text(
          'Tugas Mendesak',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: _C.textPrimary,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFEBEE),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            color: Color(0xFFD32F2F),
            size: 18,
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
        separatorBuilder: (_, __) => const SizedBox(height: 10),
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
  Widget _buildBottomNavBar(HomeTeknisiController ctrl) {
    final items = TeknisiNavItemModel.items();
    final icons = [
      Icons.dashboard_rounded,
      Icons.assignment_rounded,
      Icons.history_rounded,
      Icons.person_rounded,
    ];

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: _C.navBg,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
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
                        // Active: icon dalam rounded container biru
                        if (active)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _C.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(
                              icons[i],
                              size: 20,
                              color: _C.navActive,
                            ),
                          )
                        else
                          Icon(icons[i], size: 22, color: _C.navInactive),
                        const SizedBox(height: 3),
                        Text(
                          items[i].label,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: active ? _C.navActive : _C.navInactive,
                            letterSpacing: 0.3,
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

  // Warna garis prioritas di sisi kiri card
  Color get _barColor {
    switch (tugas.prioritas) {
      case PrioritasTugas.high:
        return _C.highPriorityBar;
      case PrioritasTugas.medium:
        return _C.medPriorityBar;
      case PrioritasTugas.low:
        return _C.lowPriorityBar;
    }
  }

  // Warna & teks badge prioritas
  Color get _badgeBg {
    switch (tugas.prioritas) {
      case PrioritasTugas.high:
        return _C.highPriorityBadge;
      case PrioritasTugas.medium:
        return _C.medPriorityBadge;
      case PrioritasTugas.low:
        return _C.lowPriorityBadge;
    }
  }

  Color get _badgeText {
    switch (tugas.prioritas) {
      case PrioritasTugas.high:
        return _C.highPriorityText;
      case PrioritasTugas.medium:
        return _C.medPriorityText;
      case PrioritasTugas.low:
        return _C.lowPriorityText;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _C.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _C.divider, width: 1),
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
              // ---- Garis prioritas kiri ----
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

              // ---- Ikon kategori ----
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

              // ---- Konten utama ----
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Judul + offline badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tugas.judul,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: _C.textPrimary,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          // Badge offline (syncStatus: local)
                          if (!tugas.isSynced) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _C.offlineBadge,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'Offline',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: _C.offlineText,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Lokasi
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: _C.textLight,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              tugas.lokasi,
                              style: const TextStyle(
                                fontSize: 12,
                                color: _C.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Badge prioritas + estimasi jam
                      Row(
                        children: [
                          // Badge prioritas
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

                          // Estimasi jam
                          if (tugas.estimasiSelesai != null) ...[
                            const Icon(
                              Icons.access_time_rounded,
                              size: 12,
                              color: _C.textLight,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              tugas.jamEstimasi,
                              style: const TextStyle(
                                fontSize: 11,
                                color: _C.textSecondary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],

                          const Spacer(),
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
// WIDGET: Action Chip (tombol kecil di card)
// ============================================================
class _ActionChip extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionChip({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w700,
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
        color: _C.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _C.divider, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 44,
            color: Color(0xFF81C784),
          ),
          SizedBox(height: 10),
          Text(
            'Tidak ada tugas mendesak',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _C.textSecondary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Semua tugas high priority sudah diselesaikan!',
            style: TextStyle(fontSize: 12, color: _C.textLight),
          ),
        ],
      ),
    );
  }
}
