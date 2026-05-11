import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_bottom_nav_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_dashboard_components.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';
import '../controller/home_controller.dart';

class HomeTuView extends StatelessWidget {
  const HomeTuView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeTuController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () => CustomScrollView(
          slivers: [
            AppHomeAppBar(
              title: 'Tata Usaha JTK',
              subtitle: controller.state.value.subtitle,
              avatarIcon: Icons.business_center_rounded,
              unreadCount: controller.unreadNotif.value,
              onNotificationTap: controller.onNotificationTapped,
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppGreeting(
                      eyebrow: controller.greeting,
                      title: controller.state.value.title,
                      subtitle:
                          'Kelola administrasi akademik, surat, dan agenda layanan JTK.',
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: AppStatCard(
                            icon: Icons.description_outlined,
                            label: 'Surat Diproses',
                            value: '${controller.state.value.pendingLetters}',
                            color: AppColors.primary,
                            backgroundColor: AppColors.blueSoft,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: AppStatCard(
                            icon: Icons.calendar_month_rounded,
                            label: 'Agenda Bulan Ini',
                            value: '${controller.state.value.monthlyAgenda}',
                            color: AppColors.success,
                            backgroundColor: AppColors.greenSoft,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const AppSectionHeader(
                      title: 'Akses Cepat',
                      actionLabel: null,
                    ),
                    const SizedBox(height: 12),
                    AppQuickActionGrid(
                      actions: [
                        AppQuickAction(
                          label: 'Surat Keterangan',
                          icon: Icons.description_rounded,
                          color: AppColors.primary,
                          onTap: () => controller.onQuickAction(
                            context,
                            'Surat Keterangan',
                          ),
                        ),
                        AppQuickAction(
                          label: 'Kalender Akademik',
                          icon: Icons.event_note_rounded,
                          color: AppColors.success,
                          onTap: () => controller.onQuickAction(
                            context,
                            'Kalender Akademik',
                          ),
                        ),
                        AppQuickAction(
                          label: 'Data Mahasiswa',
                          icon: Icons.groups_rounded,
                          color: AppColors.warning,
                          onTap: () => controller.onQuickAction(
                            context,
                            'Data Mahasiswa',
                          ),
                        ),
                        AppQuickAction(
                          label: 'Arsip Layanan',
                          icon: Icons.inventory_2_rounded,
                          color: AppColors.purple,
                          onTap: () => controller.onQuickAction(
                            context,
                            'Arsip Layanan',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const AppSectionHeader(
                      title: 'Prioritas Hari Ini',
                      actionLabel: null,
                    ),
                    const SizedBox(height: 12),
                    _TuPriorityList(items: controller.state.value.priorities),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Obx(
        () => AppBottomNavBar(
          items: const [
            AppNavItem(label: 'Home', icon: Icons.dashboard_rounded),
            AppNavItem(label: 'Layanan', icon: Icons.folder_copy_rounded),
            AppNavItem(label: 'Agenda', icon: Icons.calendar_month_rounded),
            AppNavItem(label: 'Profil', icon: Icons.person_rounded),
          ],
          selectedIndex: controller.selectedNavIndex.value,
          onTap: (index) => controller.onNavTapped(context, index),
        ),
      ),
    );
  }
}

class _TuPriorityList extends StatelessWidget {
  final List<String> items;

  const _TuPriorityList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(items.length, (index) {
          return ListTile(
            leading: CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.blueSoft,
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            title: Text(
              items[index],
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.title,
              ),
            ),
            trailing: const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.muted,
            ),
          );
        }),
      ),
    );
  }
}
