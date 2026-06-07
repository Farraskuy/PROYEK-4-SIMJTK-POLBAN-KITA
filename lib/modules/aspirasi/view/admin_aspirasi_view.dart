import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../aspirasi/controller/aspirasi_controller.dart';
import '../../aspirasi/model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/widgets/aspirasi_card.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/widgets/aspirasi_sort_bar.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/detail_aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_bottom_nav_bar.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/view/admin_add_user_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/admin_laporan_fasilitas_view.dart';
import '../../home/admin/controller/home_controller.dart'; 
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class AdminAspirasiView extends StatelessWidget {
  const AdminAspirasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AspirasiController());
    final adminCtrl = Get.find<AdminDashboardController>();

    // Memastikan indeks navbar otomatis berpindah ke 'Aspirasi' (indeks ke-2) saat halaman ini dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminCtrl.selectedNavIndex.value = 2;
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Daftar Aspirasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.title,
            fontFamily: 'Poppins',
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.title),
          onPressed: () {
            adminCtrl.selectedNavIndex.value = 0; // Kembalikan indikator ke Home
            Get.back();
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Obx(
            () => AspirasiSortBar(
              selectedIndex: ctrl.activeTab.value.index,
              onChanged: (index) {
                ctrl.tabController.animateTo(index);
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value) {
                return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              }

              if (ctrl.displayedAspirasi.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada aspirasi.',
                    style: TextStyle(color: AppColors.body, fontFamily: 'Poppins'),
                  ),
                );
              }

              return RefreshIndicator(
                color: AppColors.primary,
                onRefresh: ctrl.onRefresh,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: ctrl.displayedAspirasi.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = ctrl.displayedAspirasi[index];
                    return AspirasiCard(
                      aspirasi: item,
                      isUpvoted: ctrl.isUpvoted(item),
                      isDownvoted: ctrl.isDownvoted(item),
                      showVoteButtons: false,
                      showVoteColumn: true,
                      showActions: false,
                      onUpvote: () {},
                      onDownvote: () {},
                      onTap: () {
                        Get.to(() => DetailAspirasiView(
                              aspirasi: item,
                              role: 'tu',
                            ));
                      },
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
}
