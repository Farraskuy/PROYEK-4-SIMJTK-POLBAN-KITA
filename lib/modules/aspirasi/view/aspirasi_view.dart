import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/aspirasi_controller.dart';
import '../model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/widgets/aspirasi_card.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/aspirasi_form_view.dart';
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
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedTabHeaderDelegate(
            child: Container(
              color: AppColors.surface,
              child: TabBar(
                controller: ctrl.tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.body,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
                indicatorColor: AppColors.primary,
                indicatorWeight: 2.5,
                tabs: TabAspirasi.values.map((t) => Tab(text: t.label)).toList(),
              ),
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
                Icon(
                  Icons.campaign_outlined,
                  size: 56,
                  color: AppColors.muted,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Belum ada aspirasi di sini',
                  style: TextStyle(color: AppColors.body),
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
            separatorBuilder: (_, __) =>
                const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final item = ctrl.displayedAspirasi[index];
              final canManage =
                  item.pelaporId != null && item.pelaporId == ctrl.currentUserId;
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
              );
            },
          ),
        );
      }),
    );
  }
}

class _PinnedTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedTabHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 48;

  @override
  double get maxExtent => 48;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return SizedBox(height: maxExtent, child: child);
  }

  @override
  bool shouldRebuild(covariant _PinnedTabHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}
