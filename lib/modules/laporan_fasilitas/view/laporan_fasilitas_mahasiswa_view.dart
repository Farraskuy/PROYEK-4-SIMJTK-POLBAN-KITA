import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/interaksi_laporan_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/lapor_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_empty_state.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_header_section.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_list_section.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_sort_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';

class LaporanFasilitasMahasiswaView extends StatelessWidget {
  const LaporanFasilitasMahasiswaView({super.key, this.role = 'mahasiswa'});

  final String role;

  String get _title {
    if (role == 'teknisi' || role == 'petugas') return 'Tanggapan Laporan';
    if (role == 'tu') return 'Cetak Laporan TU';
    return 'Laporan Fasilitas';
  }

  String get _subtitle {
    if (role == 'mahasiswa') return 'Mahasiswa JTK';
    if (role == 'teknisi' || role == 'petugas') return 'Petugas JTK';
    if (role == 'tu') return 'TU JTK';
    return 'JTK';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      InteraksiLaporanController(role: role),
      tag: 'laporan-$role',
    );

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
              Obx(
                () => AppHomeAppBar(
                  title: 'Halo, ${controller.currentUserName}',
                  subtitle: _subtitle,
                  avatarIcon: Icons.person_rounded,
                  unreadCount: controller.unreadNotifCount.value,
                  onNotificationTap: controller.onNotificationTapped,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 20)),
              SliverToBoxAdapter(
                child: LaporanFasilitasHeaderSection(
                  title: _title,
                  description:
                      'Laporan ditampilkan dari vote tertinggi agar prioritas paling penting muncul lebih dulu.',
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 16)),
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
                  if (changed == true) {
                    controller.refreshData();
                  }
                },
                backgroundColor: const Color(0xFF1E78E6),
                shape: const CircleBorder(),
                elevation: 4,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            )
          : null,
    );
  }
}
