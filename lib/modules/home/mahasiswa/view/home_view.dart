import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/controller/home_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/widgets/akses_cepat_section.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/widgets/aspirasi_section.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/widgets/kalender_section.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/laporan_fasilitas_mahasiswa_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_bottom_nav_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(controller),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    KalenderSection(controller: controller),
                    
                    const SizedBox(height: 24),

                    AksesCepatSection(
                      controller: controller,
                      onNavigate: (target) =>
                          _navigateMahasiswa(context, target),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    AspirasiSection(
                      controller: controller,
                      onNavigate: (target) =>
                          _navigateMahasiswa(context, target),
                    ),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: _buildBottomNavBar(context, controller),
    );
  }

  Widget _buildAppBar(HomeController controller) {
    return Obx(
      () => AppHomeAppBar(
        title: 'Halo, ${controller.currentUser.value.name}',
        subtitle: 'Mahasiswa JTK',
        avatarIcon: Icons.person_rounded,
        unreadCount: controller.unreadNotifCount.value,
        onNotificationTap: controller.onNotificationTapped,
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context, HomeController controller) {
    const items = [
      AppNavItem(label: 'Home', icon: Icons.home_rounded),
      AppNavItem(label: 'Layanan', icon: Icons.grid_view_rounded),
      AppNavItem(label: 'Aspirasi', icon: Icons.campaign_rounded),
      AppNavItem(label: 'Profil', icon: Icons.person_rounded),
    ];

    return Obx(
      () => AppBottomNavBar(
        items: items,
        selectedIndex: controller.selectedNavIndex.value,
        onTap: (index) =>
            _navigateMahasiswa(context, controller.onNavItemTapped(index)),
      ),
    );
  }
}

void _navigateMahasiswa(BuildContext context, MahasiswaNavTarget? target) {
  if (target == null) return;

  if (target == MahasiswaNavTarget.laporanFasilitas) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const LaporanFasilitasMahasiswaView(),
      ),
    );
    return;
  }

  if (target == MahasiswaNavTarget.aspirasi) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AspirasiView()),
    );
  }
}
