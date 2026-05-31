import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/controller/admin_user_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/admin/controller/home_controller.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_bottom_nav_bar.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/view/admin_add_user_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class AdminUserView extends StatelessWidget {
  const AdminUserView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminUserController());
    final adminCtrl = Get.find<AdminDashboardController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola User'),
      ),
      body: Obx(() => ctrl.isLoading.value 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: ctrl.fetchUsers,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ctrl.users.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final user = ctrl.users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(Icons.person, color: AppColors.primary),
                  ),
                  title: Text(user.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${user.role.toUpperCase()} • ${user.nomorInduk}\n${user.email}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () async {
                          final result = await Get.to(
                            () => const AdminAddUserView(),
                            arguments: user,
                          );
                          if (result == true) {
                            ctrl.fetchUsers();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          Get.defaultDialog(
                            title: 'Hapus User',
                            middleText: 'Apakah Anda yakin ingin menghapus user ${user.name}?',
                            textCancel: 'Batal',
                            textConfirm: 'Hapus',
                            confirmTextColor: Colors.white,
                            onConfirm: () {
                              Get.back();
                              ctrl.deleteUser(user.id);
                            },
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.to(() => const AdminAddUserView());
          if (result == true) {
            ctrl.fetchUsers();
          }
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: AppBottomNavBar(
        items: const [
          AppNavItem(label: 'Home', icon: Icons.dashboard_rounded),
          AppNavItem(label: 'Layanan', icon: Icons.apartment_rounded),
          AppNavItem(label: 'Aspirasi', icon: Icons.campaign_rounded),
          AppNavItem(label: 'User', icon: Icons.group_rounded),
        ],
        selectedIndex: 3, // Set to 3 since this is the User tab
        onTap: (index) {
          if (index != 3) { // Hanya pindah jika bukan tab User
            adminCtrl.onNavTapped(index);
            if (index == 0) Get.back(); // Kembali ke dashboard
          }
        },
      ),
    );
  }
}
