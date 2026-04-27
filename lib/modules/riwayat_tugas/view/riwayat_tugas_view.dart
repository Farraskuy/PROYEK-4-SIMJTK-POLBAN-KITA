// ============================================================
// FILE: modules/home/teknisi/riwayat/view/riwayat_tugas_view.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/riwayat_tugas_controller.dart';
import '../model/riwayat_tugas_model.dart';

// ============================================================
// DESIGN TOKENS
// ============================================================
class _C {
  static const primary = Color(0xFF1A3A6B);
  static const surface = Color(0xFFF0F4FA);
  static const white = Colors.white;
  static const cardBg = Color(0xFFFFFFFF);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textLight = Color(0xFFB0B8CC);
  static const divider = Color(0xFFE5E9F2);
  static const searchBg = Color(0xFFFFFFFF);
  static const searchBorder = Color(0xFFDDE3EF);

  // Filter chip
  static const chipActive = Color(0xFF1A3A6B);
  static const chipActiveFg = Colors.white;
  static const chipInactiveBg = Color(0xFFFFFFFF);
  static const chipInactiveFg = Color(0xFF6B7280);
  static const chipInactiveBorder = Color(0xFFDDE3EF);

  // Badge SELESAI
  static const selesaiBg = Color(0xFF1A3A6B);
  static const selesaiFg = Colors.white;

  // Nav
  static const navActive = Color(0xFF1A3A6B);
  static const navInactive = Color(0xFF9CA3AF);

  // Kategori icon
  static const jaringanColor = Color(0xFF2B5BAE);
  static const jaringanBg = Color(0xFFE8EDF8);
  static const acColor = Color(0xFF2E7D32);
  static const acBg = Color(0xFFE8F5E9);
  static const pcColor = Color(0xFFE53935);
  static const pcBg = Color(0xFFFFEBEE);
  static const umColor = Color(0xFF6A1B9A);
  static const umBg = Color(0xFFF3E5F5);
}

// ============================================================
// RIWAYAT TUGAS VIEW
// ============================================================
class RiwayatTugasView extends StatelessWidget {
  const RiwayatTugasView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(RiwayatTugasController());

    return Scaffold(
      backgroundColor: _C.surface,
      body: Column(
        children: [
          // ---- HEADER FIXED ----
          _buildHeader(ctrl),

          // ---- SEARCH BAR FIXED ----
          _buildSearchBar(ctrl),

          // ---- FILTER CHIPS FIXED ----
          _buildFilterChips(ctrl),

          // ---- LIST SCROLLABLE ----
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(
                    child: CircularProgressIndicator(color: _C.primary));
              }

              if (ctrl.riwayatTampil.isEmpty) {
                return _EmptyState(
                  isSearch: ctrl.isSearchActive,
                  filter: ctrl.activeFilter.value,
                );
              }

              return RefreshIndicator(
                color: _C.primary,
                onRefresh: ctrl.onRefresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: ctrl.riwayatTampil.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final item = ctrl.riwayatTampil[index];
                    return _RiwayatCard(
                      item: item,
                      onTap: () => ctrl.onItemTapped(item),
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
  Widget _buildHeader(RiwayatTugasController ctrl) {
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
                    onPressed: ctrl.onMenuTapped,
                    icon: const Icon(Icons.menu_rounded,
                        color: _C.textPrimary, size: 24),
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
                  const CircleAvatar(
                    radius: 18,
                    backgroundColor: _C.primary,
                    child:
                        Icon(Icons.person, color: Colors.white, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Judul
              const Text(
                'Riwayat Tugas',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Daftar tugas yang telah diselesaikan.',
                style:
                    TextStyle(fontSize: 13, color: _C.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SEARCH BAR
  // ============================================================
  Widget _buildSearchBar(RiwayatTugasController ctrl) {
    return Container(
      color: _C.white,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Obx(() => TextField(
            controller: ctrl.searchController,
            style: const TextStyle(
                fontSize: 14, color: _C.textPrimary),
            decoration: InputDecoration(
              hintText: 'Cari tugas...',
              hintStyle: const TextStyle(
                  color: _C.textLight, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: _C.textLight, size: 20),
              suffixIcon: ctrl.isSearchActive
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: _C.textLight, size: 18),
                      onPressed: ctrl.onClearSearch,
                    )
                  : null,
              filled: true,
              fillColor: _C.searchBg,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: _C.searchBorder, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: _C.primary, width: 1.5),
              ),
            ),
          )),
    );
  }

  // ============================================================
  // FILTER CHIPS
  // ============================================================
  Widget _buildFilterChips(RiwayatTugasController ctrl) {
    return Container(
      color: _C.white,
      child: Column(
        children: [
          const Divider(height: 1, color: _C.divider),
          SizedBox(
            height: 52,
            child: Obx(() => ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  children: FilterRiwayat.values.map((filter) {
                    final isActive = ctrl.activeFilter.value == filter;

                    int count;
                    switch (filter) {
                      case FilterRiwayat.semua:
                        count = ctrl.countSemua;
                        break;
                      case FilterRiwayat.mingguIni:
                        count = ctrl.countMingguIni;
                        break;
                      case FilterRiwayat.bulanIni:
                        count = ctrl.countBulanIni;
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
                )),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // BOTTOM NAV BAR
  // ============================================================
  Widget _buildBottomNavBar(RiwayatTugasController ctrl) {
    const navItems = [
      {'label': 'BERANDA', 'icon': Icons.dashboard_rounded},
      {'label': 'TUGAS', 'icon': Icons.assignment_rounded},
      {'label': 'RIWAYAT', 'icon': Icons.history_rounded},
      {'label': 'PROFIL', 'icon': Icons.person_rounded},
    ];

    return Obx(() => Container(
          decoration: BoxDecoration(
            color: _C.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2))
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
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: _C.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Icon(icon,
                                  size: 20, color: _C.navActive),
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
                              color: active
                                  ? _C.navActive
                                  : _C.navInactive,
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
        ));
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
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                fontWeight: isActive
                    ? FontWeight.w700
                    : FontWeight.w500,
                color: isActive
                    ? _C.chipActiveFg
                    : _C.chipInactiveFg,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1),
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
// WIDGET: Kartu Riwayat
// ============================================================
class _RiwayatCard extends StatelessWidget {
  final ItemRiwayatModel item;
  final VoidCallback onTap;

  const _RiwayatCard({required this.item, required this.onTap});

  Color get _iconColor {
    switch (item.kategori) {
      case 'Jaringan Internet':
        return _C.jaringanColor;
      case 'AC / Pendingin':
        return _C.acColor;
      case 'Perangkat PC':
        return _C.pcColor;
      default:
        return _C.umColor;
    }
  }

  Color get _iconBg {
    switch (item.kategori) {
      case 'Jaringan Internet':
        return _C.jaringanBg;
      case 'AC / Pendingin':
        return _C.acBg;
      case 'Perangkat PC':
        return _C.pcBg;
      default:
        return _C.umBg;
    }
  }

  IconData get _iconData {
    switch (item.kategori) {
      case 'Jaringan Internet':
        return Icons.wifi_rounded;
      case 'AC / Pendingin':
        return Icons.ac_unit_rounded;
      case 'Perangkat PC':
        return Icons.computer_rounded;
      case 'Listrik & Proyektor':
        return Icons.electrical_services_rounded;
      default:
        return Icons.build_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
            // ---- Baris atas: ID + Badge SELESAI ----
            Row(
              children: [
                // Ikon kategori
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: _iconBg,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Icon(_iconData, size: 18, color: _iconColor),
                ),
                const SizedBox(width: 10),

                // Nomor ID
                Text(
                  'ID: ${item.nomorId}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _C.textLight,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),

                // Badge SELESAI
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _C.selesaiBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.check_circle_rounded,
                          size: 11, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'SELESAI',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ---- Judul tugas ----
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
            const SizedBox(height: 8),

            // ---- Tanggal selesai ----
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: _C.textLight),
                const SizedBox(width: 5),
                Text(
                  item.tanggalLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _C.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // ---- Catatan pengerjaan (jika ada) ----
            if (item.catatanPengerjaan != null &&
                item.catatanPengerjaan!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(height: 1, color: _C.divider),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded,
                      size: 13, color: _C.textLight),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      item.catatanPengerjaan!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: _C.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            // ---- Foto bukti count ----
            if (item.fotoBuktiUrls.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.photo_library_outlined,
                      size: 13, color: _C.textLight),
                  const SizedBox(width: 5),
                  Text(
                    '${item.fotoBuktiUrls.length} foto bukti',
                    style: const TextStyle(
                      fontSize: 11,
                      color: _C.textLight,
                    ),
                  ),
                ],
              ),
            ],
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
  final bool isSearch;
  final FilterRiwayat filter;

  const _EmptyState({required this.isSearch, required this.filter});

  @override
  Widget build(BuildContext context) {
    final icon = isSearch
        ? Icons.search_off_rounded
        : Icons.history_toggle_off_rounded;
    final title = isSearch
        ? 'Tidak ditemukan'
        : filter == FilterRiwayat.mingguIni
            ? 'Belum ada riwayat minggu ini'
            : filter == FilterRiwayat.bulanIni
                ? 'Belum ada riwayat bulan ini'
                : 'Belum ada riwayat tugas';
    final subtitle = isSearch
        ? 'Coba kata kunci lain atau ubah filter'
        : 'Riwayat akan muncul setelah tugas diselesaikan';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 56, color: const Color(0xFFB0B8CC)),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFFB0B8CC)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// Extension untuk onMenuTapped
extension on RiwayatTugasController {
  void onMenuTapped() {
    // TODO: buka drawer
  }
}