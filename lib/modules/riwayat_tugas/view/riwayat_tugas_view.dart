// ============================================================
// FILE: modules/home/teknisi/riwayat/view/riwayat_tugas_view.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// MODIFIKASI:
//   - Data dari DB: laporan dengan teknisi_id == user login & status resolved
//   - Tampilkan ID petugas (teknisi_id)
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/riwayat_tugas_controller.dart';

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
  static const chipActive = Color(0xFF1A3A6B);
  static const chipInactiveBg = Color(0xFFFFFFFF);
  static const chipInactiveFg = Color(0xFF6B7280);
  static const chipInactiveBorder = Color(0xFFDDE3EF);
  static const selesaiBg = Color(0xFF1A3A6B);
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
          _buildHeader(ctrl, context),
          _buildSearchBar(ctrl),
          _buildFilterChips(ctrl),
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
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
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
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader(RiwayatTugasController ctrl, BuildContext context) {
    return Container(
      color: _C.white,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    radius: 22,
                    backgroundColor: _C.primary,
                    child: Icon(
                      Icons.engineering_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Portal Teknisi',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: _C.textPrimary,
                          ),
                        ),
                        Text(
                          'Teknisi JTK',
                          style: TextStyle(
                            fontSize: 12,
                            color: _C.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
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
                'Laporan yang telah Anda selesaikan.',
                style: TextStyle(fontSize: 13, color: _C.textSecondary),
              ),

              // ─── Info ID Petugas ───
              const SizedBox(height: 8),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDF2FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.badge_rounded,
                            size: 13, color: _C.primary),
                        const SizedBox(width: 5),
                        Text(
                          'ID Petugas: ${ctrl.currentTeknisiId}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: _C.primary,
                          ),
                        ),
                      ],
                    ),
                  )),
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
            style: const TextStyle(fontSize: 14, color: _C.textPrimary),
            decoration: InputDecoration(
              hintText: 'Cari riwayat tugas...',
              hintStyle:
                  const TextStyle(color: _C.textLight, fontSize: 14),
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
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: _C.searchBorder, width: 1.2),
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
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? Colors.white : _C.chipInactiveFg,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withValues(alpha: 0.25)
                      : _C.primary.withValues(alpha: 0.08),
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
// WIDGET: Kartu Riwayat — dari LaporanFasilitasModel
// ============================================================
class _RiwayatCard extends StatelessWidget {
  final RiwayatLaporanModel item;
  final VoidCallback onTap;

  const _RiwayatCard({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final laporan = item.laporan;

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
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- Baris atas: ID Laporan + Badge SELESAI ----
            Row(
              children: [
                // ID Laporan (ID laporan dari DB)
                Expanded(
                  child: Text(
                    'ID: ${laporan.id}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _C.textLight,
                      letterSpacing: 0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),

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
            const SizedBox(height: 10),

            // ---- Judul laporan ----
            Text(
              laporan.judul,
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

            // ---- Lokasi ----
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: _C.textLight),
                const SizedBox(width: 4),
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
            const SizedBox(height: 4),

            // ---- Tanggal selesai ----
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 13, color: _C.textLight),
                const SizedBox(width: 5),
                Text(
                  'Selesai: ${item.tanggalLabel}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: _C.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: _C.divider),
            const SizedBox(height: 10),

            // ---- ID Petugas yang menanggapi ----
            Row(
              children: [
                const Icon(Icons.engineering_rounded,
                    size: 13, color: _C.textLight),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Ditangani oleh: ${laporan.teknisi_id ?? "-"}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _C.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // ---- Catatan petugas (jika ada) ----
            if (laporan.catatanPetugas != null &&
                laporan.catatanPetugas!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded,
                      size: 13, color: _C.textLight),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      laporan.catatanPetugas!,
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
            if (laporan.foto_urls.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.photo_library_outlined,
                      size: 13, color: _C.textLight),
                  const SizedBox(width: 5),
                  Text(
                    '${laporan.foto_urls.length} foto bukti',
                    style: const TextStyle(
                        fontSize: 11, color: _C.textLight),
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
        : 'Riwayat akan muncul setelah laporan Anda diselesaikan';

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
            style: const TextStyle(fontSize: 12, color: Color(0xFFB0B8CC)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
