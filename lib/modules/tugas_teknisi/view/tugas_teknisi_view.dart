// ============================================================
// FILE: modules/home/teknisi/tugas/view/daftar_tugas_view.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/tugas_teknisi_controller.dart';
import '../model/tugas_teknisi_model.dart';

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

  // Filter chip colors
  static const chipActive = Color(0xFF1A3A6B);
  static const chipActiveFg = Colors.white;
  static const chipInactiveBg = Color(0xFFFFFFFF);
  static const chipInactiveFg = Color(0xFF6B7280);
  static const chipInactiveBorder = Color(0xFFDDE3EF);

  // Status badge
  static const menungguBg = Color(0xFFEDF2FF);
  static const menungguFg = Color(0xFF2B5BAE);
  static const diprosesBg = Color(0xFFE3F2FD);
  static const diprosesFg = Color(0xFF1565C0);
  static const selesaiBg = Color(0xFF1A3A6B);
  static const selesaiFg = Colors.white;
  static const ditolakBg = Color(0xFFFFEBEE);
  static const ditolakFg = Color(0xFFD32F2F);

  // Prioritas bar kiri
  static const barHigh = Color(0xFFE53935);
  static const barMedium = Color(0xFF1A3A6B);
  static const barLow = Color(0xFFB0B8CC);

  // Nav
  static const navActive = Color(0xFF1A3A6B);
  static const navInactive = Color(0xFF9CA3AF);

  // Offline badge
  static const offlineBg = Color(0xFFFFF3E0);
  static const offlineFg = Color(0xFFE65100);
}

// ============================================================
// DAFTAR TUGAS VIEW
// ============================================================
class DaftarTugasView extends StatelessWidget {
  const DaftarTugasView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(DaftarTugasController());

    return Scaffold(
      backgroundColor: _C.surface,
      body: Column(
        children: [
          // ---- HEADER FIXED (tidak scroll) ----
          _buildHeader(ctrl),

          // ---- FILTER CHIPS FIXED ----
          _buildFilterChips(ctrl),

          // ---- LIST TUGAS SCROLLABLE ----
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: _C.primary),
                );
              }

              if (ctrl.tugasTampil.isEmpty) {
                return _EmptyState(filter: ctrl.activeFilter.value);
              }

              return RefreshIndicator(
                color: _C.primary,
                onRefresh: ctrl.onRefresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: ctrl.tugasTampil.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = ctrl.tugasTampil[index];
                    return _TugasListItem(
                      item: item,
                      onTap: () => ctrl.onItemTapped(item),
                      onMulai: () => ctrl.onMulaiKerjakan(item),
                      onSelesai: () => ctrl.onSelesaikan(item),
                    );
                  },
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(ctrl),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader(DaftarTugasController ctrl) {
    return Container(
      color: _C.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // App bar row
              Row(
                children: [
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: _C.textPrimary,
                      size: 24,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Technician Portal',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: _C.primary,
                    ),
                  ),
                  const Spacer(),
                  // Avatar
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: _C.primary,
                    child: Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Judul halaman
              const Text(
                'Daftar Tugas',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tugas yang diberikan kepada anda',
                style: TextStyle(fontSize: 13, color: _C.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FILTER CHIPS
  // ============================================================
  Widget _buildFilterChips(DaftarTugasController ctrl) {
    return Container(
      color: _C.white,
      child: Column(
        children: [
          const Divider(height: 1, color: _C.divider),
          SizedBox(
            height: 52,
            child: Obx(
              () => ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                children: FilterTugas.values.map((filter) {
                  final isActive = ctrl.activeFilter.value == filter;

                  // Hitung jumlah per filter untuk badge
                  int count;
                  switch (filter) {
                    case FilterTugas.semua:
                      count = ctrl.countSemua;
                      break;
                    case FilterTugas.menunggu:
                      count = ctrl.countMenunggu;
                      break;
                    case FilterTugas.diproses:
                      count = ctrl.countDiproses;
                      break;
                    case FilterTugas.selesai:
                      count = ctrl.countSelesai;
                      break;
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _FilterChip(
                      label: filter.label,
                      count: count,
                      isActive: isActive,
                      onTap: () => ctrl.onFilterChanged(filter),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAV BAR
  // ============================================================
  Widget _buildBottomNavBar(DaftarTugasController ctrl) {
    const navItems = [
      {'label': 'Home', 'icon': Icons.dashboard_rounded},
      {'label': 'Tugas', 'icon': Icons.assignment_rounded},
      {'label': 'Riwayat', 'icon': Icons.history_rounded},
      {'label': 'Profil', 'icon': Icons.person_rounded},
    ];

    return Obx(
      () => Container(
        decoration: BoxDecoration(
          color: _C.white,
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
              children: List.generate(navItems.length, (i) {
                final active = ctrl.selectedNavIndex.value == i;
                final icon = navItems[i]['icon'] as IconData;
                final label = navItems[i]['label'] as String;

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
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _C.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Icon(icon, size: 20, color: _C.navActive),
                          )
                        else
                          Icon(icon, size: 22, color: _C.navInactive),
                        const SizedBox(height: 3),
                        Text(
                          label,
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
// WIDGET: Filter Chip
// ============================================================
class _FilterChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.count,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? _C.chipActive : _C.chipInactiveBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? _C.chipActive : _C.chipInactiveBorder,
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? _C.chipActiveFg : _C.chipInactiveFg,
              ),
            ),
            // Badge count
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withOpacity(0.25)
                      : _C.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : _C.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: Item Tugas di List
// ============================================================
class _TugasListItem extends StatelessWidget {
  final ItemTugasModel item;
  final VoidCallback onTap;
  final VoidCallback onMulai;
  final VoidCallback onSelesai;

  const _TugasListItem({
    required this.item,
    required this.onTap,
    required this.onMulai,
    required this.onSelesai,
  });

  // Warna garis kiri berdasarkan prioritas
  Color get _barColor {
    switch (item.prioritas) {
      case PrioritasLaporan.high:
        return _C.barHigh;
      case PrioritasLaporan.medium:
        return _C.barMedium;
      case PrioritasLaporan.low:
        return _C.barLow;
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

              // ---- Konten ----
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Baris atas: nomor ref + badge status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Nomor referensi
                          Text(
                            item.nomorRef,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _C.textLight,
                              letterSpacing: 0.3,
                            ),
                          ),

                          Row(
                            children: [
                              // Badge offline
                              if (!item.isSynced) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _C.offlineBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Offline',
                                    style: TextStyle(
                                      fontSize: 9,
                                      color: _C.offlineFg,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                              ],

                              // Badge status
                              _StatusBadge(status: item.status),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Judul tugas
                      Text(
                        item.judul,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),

                      // Lokasi
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            size: 13,
                            color: _C.textLight,
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              item.lokasi,
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

                      // Tombol aksi — hanya tampil jika belum selesai
                      if (item.status != StatusLaporanTeknisi.resolved &&
                          item.status != StatusLaporanTeknisi.rejected) ...[
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: _C.divider),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            // Chip kategori
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _C.surface,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: _C.divider, width: 1),
                              ),
                              child: Text(
                                item.kategori,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: _C.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ],
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
// WIDGET: Status Badge
// ============================================================
class _StatusBadge extends StatelessWidget {
  final StatusLaporanTeknisi status;
  const _StatusBadge({required this.status});

  Color get _bg {
    switch (status) {
      case StatusLaporanTeknisi.pending:
      case StatusLaporanTeknisi.assigned:
        return _C.menungguBg;
      case StatusLaporanTeknisi.inProgress:
        return _C.diprosesBg;
      case StatusLaporanTeknisi.resolved:
        return _C.selesaiBg;
      case StatusLaporanTeknisi.rejected:
        return _C.ditolakBg;
    }
  }

  Color get _fg {
    switch (status) {
      case StatusLaporanTeknisi.pending:
      case StatusLaporanTeknisi.assigned:
        return _C.menungguFg;
      case StatusLaporanTeknisi.inProgress:
        return _C.diprosesFg;
      case StatusLaporanTeknisi.resolved:
        return _C.selesaiFg;
      case StatusLaporanTeknisi.rejected:
        return _C.ditolakFg;
    }
  }

  IconData get _icon {
    switch (status) {
      case StatusLaporanTeknisi.pending:
      case StatusLaporanTeknisi.assigned:
        return Icons.access_time_rounded;
      case StatusLaporanTeknisi.inProgress:
        return Icons.build_rounded;
      case StatusLaporanTeknisi.resolved:
        return Icons.check_circle_rounded;
      case StatusLaporanTeknisi.rejected:
        return Icons.cancel_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 11, color: _fg),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: _fg,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET: Tombol Aksi (Mulai / Selesai)
// ============================================================
class _AksiButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _AksiButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: Colors.white),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: Empty State
// ============================================================
class _EmptyState extends StatelessWidget {
  final FilterTugas filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    String message;
    IconData icon;

    switch (filter) {
      case FilterTugas.menunggu:
        message = 'Tidak ada tugas yang menunggu';
        icon = Icons.inbox_rounded;
        break;
      case FilterTugas.diproses:
        message = 'Tidak ada tugas yang sedang diproses';
        icon = Icons.build_circle_outlined;
        break;
      case FilterTugas.selesai:
        message = 'Belum ada tugas yang diselesaikan';
        icon = Icons.check_circle_outline_rounded;
        break;
      default:
        message = 'Tidak ada tugas yang ditemukan';
        icon = Icons.assignment_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: const Color(0xFFB0B8CC)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Tarik ke bawah untuk memperbarui',
            style: TextStyle(fontSize: 12, color: Color(0xFFB0B8CC)),
          ),
        ],
      ),
    );
  }
}
