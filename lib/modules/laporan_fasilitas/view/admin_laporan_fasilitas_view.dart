// modules/laporan_fasilitas/view/admin_laporan_fasilitas_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/admin_laporan_controller.dart';
import '../../home/admin/controller/home_controller.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_bottom_nav_bar.dart';

import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_card.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/detail_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/admin_aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/view/admin_add_user_view.dart';

class AdminLaporanFasilitasView extends StatelessWidget {
  const AdminLaporanFasilitasView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminLaporanController());
    final adminCtrl = Get.find<AdminDashboardController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: const Text(
          'Laporan Fasilitas',
          style: TextStyle(
            color: AppColors.title,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.title),
          onPressed: () {
            adminCtrl.selectedNavIndex.value = 0;
            Get.back();
          },
        ),
      ),
      body: Obx(() => ctrl.isLoading.value 
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : RefreshIndicator(
            color: AppColors.primary,
            onRefresh: ctrl.fetchLaporan,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ctrl.laporanList.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = ctrl.laporanList[index];
                return LaporanFasilitasCard(
                  laporan: item,
                  currentUserId: '',
                  showVoteColumn: false,
                  showActions: false,
                  showVoteButtons: false,
                  onTap: () {
                    Get.to(() => DetailLaporanFasilitasView(
                      laporanId: item.id,
                      role: 'admin',
                    ));
                  },
                  onEdit: () {},
                  onDelete: () {},
                  onUpvote: () {},
                  onDownvote: () {},
                );
              },
            ),
          ),
      ),
    );
  }
}