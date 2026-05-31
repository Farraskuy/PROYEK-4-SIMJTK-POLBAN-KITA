import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/aspirasi_controller.dart';
import '../model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/widgets/aspirasi_card.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/widgets/aspirasi_sort_bar.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/aspirasi_form_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/detail_aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_page_header.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/mahasiswa_bottom_nav_bar.dart';

// ============================================================
// ASPIRASI VIEW Entry Point
// ============================================================
class AspirasiView extends StatelessWidget {
  const AspirasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AspirasiController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: _AspirasiListPage(ctrl: ctrl),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AspirasiCreateView()),
          );
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.edit_rounded, color: AppColors.surface),
        label: const Text(
          'Tulis Aspirasi',
          style: TextStyle(
            color: AppColors.surface,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      bottomNavigationBar: const MahasiswaBottomNavBar(
        selected: MahasiswaNavDestination.aspirasi,
      ),
    );
  }
}

// ============================================================
// PAGE 1: LIST ASPIRASI
// ============================================================
class _AspirasiListPage extends StatelessWidget {
  final AspirasiController ctrl;
  const _AspirasiListPage({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        Obx(
          () => AppHomeAppBar(
            title: 'Halo, ${ctrl.currentUserName}',
            subtitle: 'Mahasiswa JTK',
            avatarIcon: Icons.person_rounded,
            unreadCount: ctrl.unreadNotifCount.value,
            onNotificationTap: ctrl.onNotificationTapped,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        const SliverToBoxAdapter(
          child: AppPageHeader(
            title: 'Aspirasi Mahasiswa',
            description:
                'Sampaikan aspirasi, saran, dan masukan untuk kemajuan Jurusan Teknik Komputer dan Informatika',
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 12)),
        Obx(
          () => SliverToBoxAdapter(
            child: AspirasiSortBar(
              selectedIndex: ctrl.activeTab.value.index,
              onChanged: (index) {
                ctrl.tabController.animateTo(index);
              },
            ),
          ),
        ),
      ],
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        if (ctrl.displayedAspirasi.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.campaign_outlined,
                  size: 56,
                  color: AppColors.muted,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Belum ada aspirasi di sini',
                  style: TextStyle(color: AppColors.body, fontFamily: 'Poppins'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: ctrl.onRefresh,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: ctrl.displayedAspirasi.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = ctrl.displayedAspirasi[index];
              final canManage =
                  item.pelaporId != null && item.pelaporId == ctrl.currentUserId.value;
              return AspirasiCard(
                aspirasi: item,
                isUpvoted: ctrl.isUpvoted(item),
                isDownvoted: ctrl.isDownvoted(item),
                showActions: canManage,
                onEdit: canManage
                    ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => AspirasiEditView(aspirasi: item),
                          ),
                        );
                      }
                    : null,
                onDelete: canManage ? () => ctrl.deleteAspirasi(item.id) : null,
                onUpvote: () => ctrl.onUpvote(item.id),
                onDownvote: () => ctrl.onDownvote(item.id),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailAspirasiView(
                        aspirasi: item,
                        role: 'mahasiswa',
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
      }),
    );
  }
}
