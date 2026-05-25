import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/controller/home_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/widgets/akses_cepat_section.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/widgets/kalender_section.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/widgets/laporan_fasilitas_section.dart';
import 'package:proyek_4_poki_polban_kita/modules/profile/view/role_profile_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/laporan_fasilitas_mahasiswa_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/mahasiswa_bottom_nav_bar.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: AppColors.background,
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
              Obx(
                () => AppHomeAppBar(
                  title: 'Halo, ${controller.currentUser?.name ?? 'Mahasiswa'}',
                  subtitle: 'Mahasiswa JTK',
                  avatarIcon: Icons.person_rounded,
                  unreadCount: controller.unreadNotifCount.value,
                  onNotificationTap: controller.onNotificationTapped,
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    KalenderSection(controller: controller),

                    const SizedBox(height: 24),

                    AksesCepatSection(
                      controller: controller,
                      onNavigate: (target) => _navigateMahasiswa(
                        context,
                        target,
                        role: 'mahasiswa',
                      ),
                    ),

                    const SizedBox(height: 24),

                    LaporanFasilitasSection(
                      controller: controller,
                      onNavigate: (target) => _navigateMahasiswa(
                        context,
                        target,
                        role: 'mahasiswa',
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: const MahasiswaBottomNavBar(
        selected: MahasiswaNavDestination.home,
      ),
    );
  }
}

void _navigateMahasiswa(
  BuildContext context,
  MahasiswaNavTarget? target, {
  required String role,
}) {
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
    return;
  }

  if (target == MahasiswaNavTarget.profile) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RoleProfileView(role: role)),
    );
  }
}
