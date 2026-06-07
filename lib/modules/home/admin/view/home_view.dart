import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/admin_aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/admin/controller/home_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/admin_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/view/admin_user_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDashboardController());

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
          onRefresh: controller.onRefresh,
          child: CustomScrollView(
            slivers: [
              AppHomeAppBar(
                title: 'Portal Admin / TU',
                subtitle: 'SIMJTK',
                avatarIcon: Icons.admin_panel_settings_rounded,
                avatarText: (controller.user?.name ?? 'Admin').isEmpty
                    ? 'A'
                    : controller.user!.name[0].toUpperCase(),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${controller.sapaanAdmin},',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.body,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Obx(
                        () => Text(
                          controller.user?.name ?? 'Admin',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.title,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Pantau laporan fasilitas dan tanggapi aspirasi mahasiswa.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.body,
                          height: 1.45,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _SummaryGrid(controller: controller),
                      const SizedBox(height: 24),
                      const Text(
                        'Akses Admin / TU',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.title,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _ActionCard(
                        icon: Icons.apartment_rounded,
                        title: 'Laporan Fasilitas',
                        description:
                            'Lihat seluruh laporan fasilitas dari mahasiswa.',
                        onTap: () =>
                            Get.to(() => const AdminLaporanFasilitasView()),
                      ),
                      const SizedBox(height: 12),
                      _ActionCard(
                        icon: Icons.campaign_rounded,
                        title: 'Aspirasi Mahasiswa',
                        description:
                            'Tinjau dan berikan tanggapan resmi jurusan.',
                        onTap: () => Get.to(() => const AdminAspirasiView()),
                      ),
                      const SizedBox(height: 12),
                      _ActionCard(
                        icon: Icons.manage_accounts_rounded,
                        title: 'Kelola User',
                        description:
                            'Tambah, ubah, dan hapus akun pengguna aplikasi.',
                        onTap: () => Get.to(() => const AdminUserView()),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.controller});

  final AdminDashboardController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.38,
        children: [
          _SummaryCard(
            label: 'Total Laporan',
            value: controller.totalLaporan.value,
            icon: Icons.assignment_outlined,
            color: AppColors.primary,
          ),
          _SummaryCard(
            label: 'Laporan Aktif',
            value: controller.laporanAktif.value,
            icon: Icons.pending_actions_rounded,
            color: AppColors.warning,
          ),
          _SummaryCard(
            label: 'Laporan Selesai',
            value: controller.laporanSelesai.value,
            icon: Icons.check_circle_outline_rounded,
            color: AppColors.success,
          ),
          _SummaryCard(
            label: 'Aspirasi Belum Ditanggapi',
            value: controller.aspirasiBelumDitanggapi.value,
            icon: Icons.forum_outlined,
            color: AppColors.secondary,
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final int value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.title,
              height: 1,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.body,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.blueSoft,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.body,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}
