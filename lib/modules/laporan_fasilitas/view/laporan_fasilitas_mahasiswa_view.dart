// lib/modules/laporan_fasilitas/view/laporan_fasilitas_mahasiswa_view.dart

import 'dart:io'; // Tambahkan import dart:io untuk mendukung render path file lokal jika ada
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/interaksi_laporan_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/lapor_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_empty_state.dart';
// import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_header_section.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_list_section.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_sort_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_page_header.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/mahasiswa_bottom_nav_bar.dart';

class LaporanFasilitasMahasiswaView extends StatelessWidget {
  const LaporanFasilitasMahasiswaView({super.key, this.role = 'mahasiswa'});

  final String role;

  String get _subtitle {
    if (role == 'mahasiswa') return 'Mahasiswa';
    if (role == 'teknisi' || role == 'petugas') return 'Petugas';
    return 'JTK';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      InteraksiLaporanController(role: role),
      tag: 'laporan-$role',
    );

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
                  title: 'Halo, ${controller.currentUserName}',
                  subtitle: _subtitle,
                  avatarIcon: Icons.person_rounded,
                  unreadCount: controller.unreadNotifCount.value,
                  onNotificationTap: controller.onNotificationTapped,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              SliverToBoxAdapter(
                child: AppPageHeader(
                  title: 'Laporan Fasilitas',
                  description:
                      'Laporkan masalah atau keluhan terkait fasilitas di kampus.',
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              Obx(
                () => SliverToBoxAdapter(
                  child: LaporanFasilitasSortBar(
                    selectedIndex: controller.sortMode.value.index,
                    onChanged: (index) => controller.setSortMode(
                      index == 0
                          ? LaporanSortMode.populer
                          : LaporanSortMode.terbaru,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              if (controller.listLaporan.isEmpty)
                const SliverToBoxAdapter(child: LaporanFasilitasEmptyState())
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                  sliver: LaporanFasilitasListSection(
                    controller: controller,
                    role: role,
                  ),
                ),
            ],
          ),
        );
      }),
      bottomNavigationBar: role == 'mahasiswa'
          ? const MahasiswaBottomNavBar(
              selected: MahasiswaNavDestination.laporanFasilitas,
            )
          : null,
      floatingActionButton: role == 'mahasiswa'
          ? SizedBox(
              width: 56,
              height: 56,
              child: FloatingActionButton(
                onPressed: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LaporFasilitasView(),
                    ),
                  );
                  if (changed == true) controller.fetchLaporan();
                },
                backgroundColor: AppColors.primary,
                shape: const CircleBorder(),
                elevation: 4,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            )
          : null,
    );
  }

  Widget _buildStatusChip(StatusLaporan status, bool printed) {
    final color = printed ? Colors.teal : const Color(0xFF1E78E6);
    final bg = printed ? const Color(0xFFE0F2F1) : const Color(0xFFE3F2FD);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            printed ? 'Selesai' : status.label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
      ),
    );
  }
}