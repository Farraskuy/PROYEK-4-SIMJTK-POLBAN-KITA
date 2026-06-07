import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/admin_laporan_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/detail_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_empty_state.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/teknisi_laporan_fasilitas_card.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class AdminLaporanFasilitasView extends StatelessWidget {
  const AdminLaporanFasilitasView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminLaporanController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _Header(controller: controller),
          _SearchBar(controller: controller),
          _FilterBar(controller: controller),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (controller.laporanList.isEmpty) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: controller.fetchLaporan,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 72),
                      LaporanFasilitasEmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'Tidak ada laporan',
                        description:
                            'Laporan fasilitas yang sesuai pencarian akan muncul di sini.',
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: controller.fetchLaporan,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  itemCount: controller.laporanList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final laporan = controller.laporanList[index];
                    return TeknisiLaporanFasilitasCard(
                      laporan: laporan,
                      respondLabel: 'Lihat Detail Laporan',
                      respondIcon: Icons.visibility_outlined,
                      onTap: () => _openDetail(laporan.id),
                      onRespond: () => _openDetail(laporan.id),
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

  void _openDetail(String laporanId) {
    Get.to(
      () => DetailLaporanFasilitasView(
        laporanId: laporanId,
        role: 'admin',
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.controller});

  final AdminLaporanController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      (controller.user?.name ?? 'Admin').isEmpty
                          ? 'A'
                          : controller.user!.name[0].toUpperCase(),
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
                          'Halo, ${controller.user?.name ?? 'Admin'}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.title,
                          ),
                        ),
                        const Text(
                          'Admin / TU JTK',
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
                'Laporan Fasilitas',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.title,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Pantau seluruh laporan fasilitas mahasiswa.',
                style: TextStyle(fontSize: 13, color: AppColors.body),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final AdminLaporanController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Obx(
        () => TextField(
          controller: controller.searchController,
          decoration: InputDecoration(
            hintText: 'Cari laporan berdasarkan judul, lokasi, pelapor, atau ID...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: controller.isSearchActive
                ? IconButton(
                    onPressed: controller.clearSearch,
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});

  final AdminLaporanController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: Column(
        children: [
          const Divider(height: 1, color: AppColors.border),
          SizedBox(
            height: 56,
            child: Obx(
              () {
                final activeFilter = controller.activeFilter.value;

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: AdminLaporanFilter.values.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = AdminLaporanFilter.values[index];
                    return _FilterChip(
                      filter: filter,
                      selected: activeFilter == filter,
                      onTap: () => controller.setFilter(filter),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  final AdminLaporanFilter filter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              filter.icon,
              size: 15,
              color: selected ? Colors.white : AppColors.body,
            ),
            const SizedBox(width: 6),
            Text(
              filter.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.title,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
