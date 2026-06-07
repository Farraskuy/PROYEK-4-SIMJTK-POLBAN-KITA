import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/admin_laporan_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/detail_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_card.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_empty_state.dart';
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
          const _AdminHeader(
            title: 'Laporan Fasilitas',
            subtitle: 'Pantau seluruh laporan fasilitas mahasiswa.',
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Obx(
              () => TextField(
                controller: controller.searchController,
                decoration: InputDecoration(
                  hintText: 'Cari judul, lokasi, pelapor, atau ID...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: controller.searchQuery.value.isEmpty
                      ? null
                      : IconButton(
                          onPressed: controller.clearSearch,
                          icon: const Icon(Icons.close_rounded),
                        ),
                  filled: true,
                  fillColor: AppColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 48,
            child: Obx(
              () {
                final activeFilter = controller.activeFilter.value;
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  scrollDirection: Axis.horizontal,
                  itemCount: AdminLaporanFilter.values.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (_, index) {
                    final filter = AdminLaporanFilter.values[index];
                    return ChoiceChip(
                      label: Text(filter.label),
                      selected: activeFilter == filter,
                      onSelected: (_) => controller.setFilter(filter),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (controller.laporanList.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.fetchLaporan,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 80),
                      LaporanFasilitasEmptyState(
                        icon: Icons.assignment_outlined,
                        title: 'Tidak ada laporan',
                        description:
                            'Laporan yang sesuai pencarian akan muncul di sini.',
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchLaporan,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: controller.laporanList.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final item = controller.laporanList[index];
                    return LaporanFasilitasCard(
                      laporan: item,
                      currentUserId: '',
                      showVoteColumn: false,
                      showActions: false,
                      showVoteButtons: false,
                      onTap: () => Get.to(
                        () => DetailLaporanFasilitasView(
                          laporanId: item.id,
                          role: 'admin',
                        ),
                      ),
                      onEdit: null,
                      onDelete: null,
                      onUpvote: _noop,
                      onDownvote: _noop,
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

  static void _noop() {}
}

class _AdminHeader extends StatelessWidget {
  const _AdminHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.primary,
                  child: Icon(
                    Icons.admin_panel_settings_outlined,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Portal Admin / TU',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                      ),
                    ),
                    Text(
                      'SIMJTK',
                      style: TextStyle(fontSize: 12, color: AppColors.body),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(fontSize: 13, color: AppColors.body),
            ),
          ],
        ),
      ),
    );
  }
}
