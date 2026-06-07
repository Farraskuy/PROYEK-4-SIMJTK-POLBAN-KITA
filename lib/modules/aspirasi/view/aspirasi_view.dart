import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/aspirasi_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/widgets/aspirasi_card.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/widgets/aspirasi_sort_bar.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/aspirasi_form_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/detail_aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_empty_state.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_page_header.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';

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
      floatingActionButton: SizedBox(
        width: 56,
        height: 56,
        child: FloatingActionButton(
          heroTag: 'fab_aspirasi',
          onPressed: () async {
            final changed = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AspirasiCreateView(),
              ),
            );
            if (changed == true) ctrl.onRefresh();
          },
          backgroundColor: AppColors.primary,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
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
            title: 'Halo, ${ctrl.user?.name ?? 'Mahasiswa'}',
            subtitle: 'Mahasiswa JTK',
            avatarIcon: Icons.person_rounded,
            avatarText: (ctrl.user?.name ?? 'Mahasiswa').isEmpty
                ? 'M'
                : ctrl.user!.name[0].toUpperCase(),
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

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: ctrl.onRefresh,
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: ctrl.displayedAspirasi.isEmpty
                ? 1
                : ctrl.displayedAspirasi.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              if (ctrl.displayedAspirasi.isEmpty) {
                return const LaporanFasilitasEmptyState(
                  icon: Icons.campaign_outlined,
                  title: 'Belum ada aspirasi',
                  description: 'Aspirasi yang masuk akan muncul di bagian ini.',
                );
              }

              final item = ctrl.displayedAspirasi[index];
              return AspirasiCard(
                aspirasi: item,
                isUpvoted: ctrl.isUpvoted(item),
                isDownvoted: ctrl.isDownvoted(item),
                showActions: false,
                onUpvote: () => ctrl.onUpvote(item.id),
                onDownvote: () => ctrl.onDownvote(item.id),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          DetailAspirasiView(aspirasi: item, role: 'mahasiswa'),
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
