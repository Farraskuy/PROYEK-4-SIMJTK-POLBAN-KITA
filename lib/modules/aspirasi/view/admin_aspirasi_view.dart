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

class _C {
  static const primary = Color(0xFF1A3A6B);
  static const surface = Color(0xFFF5F7FA);
  static const white = Colors.white;
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textLight = Color(0xFFB0B8CC);
  static const divider = Color(0xFFE5E9F2);
  static const badgeSelesaiBg = Color(0xFFE8F5E9);
  static const badgeSelesai = Color(0xFF2E7D32);
  static const badgeProsesBg = Color(0xFFE3F2FD);
  static const badgeProses = Color(0xFF1565C0);
  static const tanggapanBg = Color(0xFFF0F4FF);
  static const tanggapanBorder = Color(0xFFB0C0E0);
  static const primaryLight = Color(0xFF2B5BAE);
  static const avatarBg = Color(0xFF2B5BAE);
  static const upvoteActive = Color(0xFF1A3A6B);
  static const downvoteActive = Color(0xFFD32F2F);
  static const voteInactive = Color(0xFFBDBDBD);
}

class AdminAspirasiView extends StatelessWidget {
  const AdminAspirasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AspirasiController());
    
    // Memanggil Admin controller agar bisa mengakses selectedNavIndex
    final adminCtrl = Get.find<AdminDashboardController>();

    // Memastikan indeks navbar otomatis berpindah ke 'Aspirasi' (indeks ke-2) saat halaman ini dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      adminCtrl.selectedNavIndex.value = 2;
    });

    return Scaffold(
      backgroundColor: _C.surface,
      appBar: AppBar(
        backgroundColor: _C.white,
        elevation: 0,
        title: const Text(
          'Daftar Aspirasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: _C.textPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: _C.textPrimary),
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
                return const Center(child: CircularProgressIndicator(color: _C.primary));
              }

              if (ctrl.displayedAspirasi.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada aspirasi.',
                    style: TextStyle(color: _C.textSecondary),
                  ),
                );
              }

              return RefreshIndicator(
                color: _C.primary,
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
      // MENGHUBUNGKAN NAVBAR KE DALAM SCAFFOLD
      bottomNavigationBar: _buildBottomNavBar(adminCtrl), 
    );
  }

  // ---- FUNGSI PEMBUATAN NAVBAR ----
  Widget _buildBottomNavBar(AdminDashboardController adminCtrl) {
    const items = [
      AppNavItem(label: 'Home', icon: Icons.dashboard_rounded),
      AppNavItem(label: 'Layanan', icon: Icons.apartment_rounded),
      AppNavItem(label: 'Aspirasi', icon: Icons.campaign_rounded),
      AppNavItem(label: 'User', icon: Icons.group_rounded),
    ];

    return Obx(
      () => AppBottomNavBar(
        items: items,
        selectedIndex: adminCtrl.selectedNavIndex.value,
        onTap: (index) {
          if (index == adminCtrl.selectedNavIndex.value) return; // Abaikan jika tab yang sama diklik

          adminCtrl.selectedNavIndex.value = index;

          if (index == 0) {
            Get.back();
          } else if (index == 1) {
            Get.off(() => const AdminLaporanFasilitasView());
          } else if (index == 3) {
            Get.off(() => const AdminAddUserView());
          }
        },
      ),
    );
  }
}
