// ============================================================
// FILE: modules/aspirasi/view/admin_aspirasi_view.dart
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../aspirasi/controller/aspirasi_controller.dart';
import '../../aspirasi/model/aspirasi_model.dart';
// Import untuk komponen Navbar dan View lainnya
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_bottom_nav_bar.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/view/admin_add_user_view.dart';
// PENTING: Sesuaikan path import controller Admin Anda di bawah ini jika error
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
          Container(
            color: _C.white,
            child: TabBar(
              controller: ctrl.tabController,
              labelColor: _C.primary,
              unselectedLabelColor: _C.textSecondary,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
              indicatorColor: _C.primary,
              indicatorWeight: 2.5,
              tabs: TabAspirasi.values.map((t) => Tab(text: t.label)).toList(),
            ),
          ),
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
                  separatorBuilder: (_, __) => const Divider(height: 30, color: _C.divider),
                  itemBuilder: (context, index) {
                    final item = ctrl.displayedAspirasi[index];
                    return _AdminAspirasiCard(
                      aspirasi: item,
                      onTanggapi: () {
                         Get.snackbar('Fitur', 'Fitur tanggapan segera hadir!');
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
          if (index == 2) return; // Abaikan jika tab yang sama diklik
          adminCtrl.onNavTapped(index);
          if (index == 0) Get.back();
        },
      ),
    );
  }
}

// Widget Card versi ringkas untuk Admin
class _AdminAspirasiCard extends StatelessWidget {
  final AspirasiModel aspirasi;
  final VoidCallback onTanggapi;

  const _AdminAspirasiCard({required this.aspirasi, required this.onTanggapi});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: _C.avatarBg,
              child: Text(
                aspirasi.initials,
                style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    aspirasi.pelaporName ?? 'Anonim',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: _C.textPrimary),
                  ),
                  Text(
                    '${aspirasi.pelaporProdi ?? ''} · ${aspirasi.waktuRelatif}',
                    style: const TextStyle(fontSize: 11, color: _C.textSecondary),
                  ),
                ],
              ),
            ),
            _StatusBadge(status: aspirasi.status),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          aspirasi.topik,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _C.textPrimary),
        ),
        const SizedBox(height: 6),
        Text(
          aspirasi.isiSaran,
          style: const TextStyle(fontSize: 13, color: _C.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Icon(Icons.keyboard_arrow_up_rounded, size: 18, color: _C.upvoteActive),
            Text(' ${aspirasi.upvoteCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(width: 16),
            Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: _C.downvoteActive),
            Text(' ${aspirasi.downvoteCount}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            const Spacer(),
          ],
        )
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final StatusAspirasi status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    if (status == StatusAspirasi.open) return const SizedBox.shrink();
    
    final bool isSelesai = status == StatusAspirasi.responded;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isSelesai ? _C.badgeSelesaiBg : _C.badgeProsesBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isSelesai ? _C.badgeSelesai : _C.badgeProses,
        ),
      ),
    );
  }
}