import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/controller/aspirasi_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/detail_aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/widgets/aspirasi_card.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/widgets/aspirasi_sort_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class AdminAspirasiView extends StatelessWidget {
  const AdminAspirasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AspirasiController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const _Header(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Obx(
              () => TextField(
                controller: controller.adminSearchController,
                decoration: InputDecoration(
                  hintText: 'Cari topik, isi aspirasi, atau pelapor...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: controller.adminSearchQuery.value.isEmpty
                      ? null
                      : IconButton(
                          onPressed: controller.clearAdminSearch,
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
          Obx(
            () => AspirasiSortBar(
              selectedIndex: controller.activeTab.value.index,
              onChanged: controller.tabController.animateTo,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }
              if (controller.displayedAspirasi.isEmpty) {
                return RefreshIndicator(
                  onRefresh: controller.onRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: const [
                      SizedBox(height: 120),
                      Icon(
                        Icons.campaign_outlined,
                        size: 48,
                        color: AppColors.muted,
                      ),
                      SizedBox(height: 12),
                      Center(
                        child: Text(
                          'Tidak ada aspirasi yang sesuai.',
                          style: TextStyle(color: AppColors.body),
                        ),
                      ),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.onRefresh,
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                  itemCount: controller.displayedAspirasi.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (_, index) {
                    final item = controller.displayedAspirasi[index];
                    return AspirasiCard(
                      aspirasi: item,
                      isUpvoted: false,
                      isDownvoted: false,
                      showVoteButtons: false,
                      showVoteColumn: false,
                      showActions: false,
                      onUpvote: _noop,
                      onDownvote: _noop,
                      onTap: () => Get.to(
                        () => DetailAspirasiView(aspirasi: item, role: 'admin'),
                      ),
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

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: const SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
            SizedBox(height: 20),
            Text(
              'Aspirasi Mahasiswa',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.title,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Tinjau dan berikan tanggapan resmi kepada mahasiswa.',
              style: TextStyle(fontSize: 13, color: AppColors.body),
            ),
          ],
        ),
      ),
    );
  }
}
