import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/interaksi_laporan_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/lapor_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_empty_state.dart';
// import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_header_section.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_list_section.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_sort_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_page_header.dart';

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
          onRefresh: controller.fetchLaporan,
          child: CustomScrollView(
            slivers: [
              AppHomeAppBar(
                title: 'Halo, ${controller.currentUserName}',
                subtitle: _subtitle,
                avatarIcon: Icons.person_rounded,
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
                    onChanged: (index) => controller.sortLaporan(
                      LaporanSortMode.values[index],
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
                heroTag: 'fab_laporan',
                onPressed: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LaporFasilitasView()),
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
}

// ============================================================
// WIDGET: Sort Bar khusus teknisi
// ============================================================
class _TeknisiSortBar extends StatefulWidget {
  final InteraksiLaporanController controller;
  const _TeknisiSortBar({required this.controller});

  @override
  State<_TeknisiSortBar> createState() => _TeknisiSortBarState();
}

class _TeknisiSortBarState extends State<_TeknisiSortBar> {
  bool _isTopUpvote = true;

  void _toggle(bool topUpvote) {
    if (_isTopUpvote == topUpvote) return;
    setState(() => _isTopUpvote = topUpvote);
    widget.controller.sortLaporan(topUpvote ? LaporanSortMode.populer : LaporanSortMode.terbaru);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip(
          label: 'Top Upvote',
          icon: Icons.arrow_upward_rounded,
          active: _isTopUpvote,
          onTap: () => _toggle(true),
        ),
        const SizedBox(width: 8),
        _chip(
          label: 'Terbaru',
          icon: Icons.schedule_rounded,
          active: !_isTopUpvote,
          onTap: () => _toggle(false),
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A3A6B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? const Color(0xFF1A3A6B)
                : const Color(0xFFDDE3EF),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: active ? Colors.white : const Color(0xFF6B7280)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
