import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/controller/aspirasi_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/detail_aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/widgets/aspirasi_card.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/widgets/aspirasi_sort_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';

class AdminAspirasiView extends StatelessWidget {
  const AdminAspirasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AspirasiController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => CustomScrollView(
          slivers: [
            AppHomeAppBar(
              title: 'Portal Admin / TU',
              subtitle: 'SIMJTK',
              avatarIcon: Icons.admin_panel_settings_rounded,
              avatarText: controller.currentUserName.value.isEmpty
                  ? 'A'
                  : controller.currentUserName.value[0].toUpperCase(),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Aspirasi Mahasiswa',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tinjau dan berikan tanggapan resmi kepada mahasiswa.',
                      style: TextStyle(fontSize: 13, color: AppColors.body),
                    ),
                    const SizedBox(height: 18),
                    TextField(
                      controller: controller.adminSearchController,
                      decoration: InputDecoration(
                        hintText: 'Cari judul, isi aspirasi, atau pelapor...',
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
                    const SizedBox(height: 12),
                    AspirasiSortBar(
                      selectedIndex: controller.activeTab.value.index,
                      onChanged: controller.tabController.animateTo,
                    ),
                  ],
                ),
              ),
            ),
            if (controller.isLoading.value)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                ),
              )
            else if (controller.displayedAspirasi.isEmpty)
              const SliverFillRemaining(
                hasScrollBody: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.campaign_outlined,
                      size: 48,
                      color: AppColors.muted,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Tidak ada aspirasi yang sesuai.',
                      style: TextStyle(color: AppColors.body),
                    ),
                  ],
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: SliverList.separated(
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
              ),
          ],
        ),
      ),
    );
  }

  static void _noop() {}
}
