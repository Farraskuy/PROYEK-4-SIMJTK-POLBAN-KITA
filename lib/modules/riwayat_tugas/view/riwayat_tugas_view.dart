// ============================================================
// FILE: modules/home/teknisi/riwayat/view/riwayat_tugas_view.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// MODIFIKASI:
//   - Data dari DB: laporan dengan teknisi_id == user login & status resolved
//   - Tampilkan ID petugas (teknisi_id)
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';
import '../controller/riwayat_tugas_controller.dart';

// ============================================================
// RIWAYAT TUGAS VIEW
// ============================================================
class RiwayatTugasView extends StatelessWidget {
  const RiwayatTugasView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(RiwayatTugasController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: ctrl.onRefresh,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(ctrl, context),
            SliverToBoxAdapter(child: _buildHeaderContent(ctrl)),
            SliverToBoxAdapter(child: _buildSearchBar(ctrl)),
            SliverToBoxAdapter(child: _buildFilterChips(ctrl)),
            Obx(() {
              if (ctrl.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }
              if (ctrl.riwayatTampil.isEmpty) {
                return SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyState(
                    isSearch: ctrl.isSearchActive,
                    filter: ctrl.activeFilter.value,
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                sliver: SliverList.separated(
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
          ],
        ),
      ),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================
  Widget _buildAppBar(RiwayatTugasController ctrl, BuildContext context) {
    return Obx(() {
      final name = ctrl.user?.name ?? 'Teknisi';
      return AppHomeAppBar(
        title: 'Halo, $name',
        subtitle: 'Teknisi JTK',
        avatarIcon: Icons.engineering_rounded,
        avatarText: name.isEmpty ? 'T' : name[0].toUpperCase(),
      );
    });
  }

  Widget _buildHeaderContent(RiwayatTugasController ctrl) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Riwayat Tugas',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.title,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Laporan yang telah Anda selesaikan.',
            style: TextStyle(fontSize: 13, color: AppColors.body),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.blueSoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.badge_rounded, size: 13, color: AppColors.primary),
                  const SizedBox(width: 5),
                  Text(
                    'ID Petugas: ${ctrl.user?.nomorInduk ?? ctrl.user?.id ?? '-'}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget buildHeaderLegacy(RiwayatTugasController ctrl, BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (ctrl.user?.name ?? 'Teknisi').isEmpty
                          ? 'T'
                          : ctrl.user!.name[0].toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${ctrl.user?.name ?? 'Teknisi'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.title,
                          ),
                        ),
                        const Text(
                          'Teknisi JTK',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.body,
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
                  color: AppColors.title,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Laporan yang telah Anda selesaikan.',
                style: TextStyle(fontSize: 13, color: AppColors.body),
              ),

              // ─── Info ID Petugas ───
              const SizedBox(height: 8),
              Obx(() => Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.blueSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.badge_rounded,
                            size: 13, color: AppColors.primary),
                        const SizedBox(width: 5),
                        Text(
                          'ID Petugas: ${ctrl.user?.nomorInduk ?? ctrl.user?.id ?? '-'}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
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
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Obx(() => TextField(
            controller: ctrl.searchController,
            style: const TextStyle(fontSize: 14, color: AppColors.title),
            decoration: InputDecoration(
              hintText: 'Cari riwayat tugas...',
              hintStyle:
                  const TextStyle(color: AppColors.muted, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppColors.muted, size: 20),
              suffixIcon: ctrl.isSearchActive
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded,
                          color: AppColors.muted, size: 18),
                      onPressed: ctrl.onClearSearch,
                    )
                  : null,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.border, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.5),
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
      color: AppColors.surface,
      child: Column(
        children: [
          const Divider(height: 1, color: AppColors.border),
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
          color: isActive ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
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
                color: isActive ? Colors.white : AppColors.body,
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
                      : AppColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : AppColors.primary,
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
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1),
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
                      color: AppColors.muted,
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
                    color: AppColors.primary,
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
                color: AppColors.title,
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
                    size: 13, color: AppColors.muted),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    laporan.lokasi,
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.body),
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
                    size: 13, color: AppColors.muted),
                const SizedBox(width: 5),
                Text(
                  'Selesai: ${item.tanggalLabel}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.body,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 10),

            // ---- ID Petugas yang menanggapi ----
            Row(
              children: [
                const Icon(Icons.engineering_rounded,
                    size: 13, color: AppColors.muted),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Ditangani oleh: ${laporan.teknisi_id ?? "-"}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
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
                      size: 13, color: AppColors.muted),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      laporan.catatanPetugas!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.body,
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
                      size: 13, color: AppColors.muted),
                  const SizedBox(width: 5),
                  Text(
                    '${laporan.foto_urls.length} foto bukti',
                    style: const TextStyle(
                        fontSize: 11, color: AppColors.muted),
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
          Icon(icon, size: 56, color: AppColors.muted),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.body,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
