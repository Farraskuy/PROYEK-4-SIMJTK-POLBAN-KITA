// modules/laporan_fasilitas/view/admin_laporan_fasilitas_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/admin_laporan_controller.dart';
import '../../home/admin/controller/home_controller.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_bottom_nav_bar.dart';

class AdminLaporanFasilitasView extends StatelessWidget {
  const AdminLaporanFasilitasView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminLaporanController());
    final adminCtrl = Get.find<AdminDashboardController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Laporan Fasilitas')),
      body: Obx(() => ctrl.isLoading.value 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: ctrl.fetchLaporan,
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: ctrl.laporanList.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, index) {
                final item = ctrl.laporanList[index];
                return ListTile(
                  title: Text(item.judul, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${item.lokasi} • ${item.pelapor_nama}'),
                  trailing: Chip(
                    label: Text(item.status.label, style: const TextStyle(fontSize: 10)),
                    backgroundColor: Colors.blue.withOpacity(0.1),
                  ),
                  onTap: () {
                    // Navigasi ke detail laporan
                  },
                );
              },
            ),
          ),
      ),
      bottomNavigationBar: Obx(() => AppBottomNavBar(
        items: const [
          AppNavItem(label: 'Home', icon: Icons.dashboard_rounded),
          AppNavItem(label: 'Layanan', icon: Icons.apartment_rounded),
          AppNavItem(label: 'Aspirasi', icon: Icons.campaign_rounded),
          AppNavItem(label: 'User', icon: Icons.group_rounded),
        ],
        selectedIndex: adminCtrl.selectedNavIndex.value,
        onTap: (index) {
          adminCtrl.onNavTapped(index);
          if (index == 0) Get.back();
        },
      )),
    );
  }
}