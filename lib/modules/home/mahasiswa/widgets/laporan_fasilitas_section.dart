import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/controller/home_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/widgets/section_header.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/detail_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_card.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_empty_state.dart';

class LaporanFasilitasSection extends StatelessWidget {
  final HomeController controller;
  final ValueChanged<MahasiswaNavTarget?> onNavigate;

  const LaporanFasilitasSection({
    super.key,
    required this.controller,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MahasiswaSectionHeader(
          title: 'Laporan Fasilitas',
          showFlame: true,
          onLihatSemua: () => onNavigate(controller.onLihatSemuaAspirasi()),
        ),
        const SizedBox(height: 12),
        _LaporanList(controller: controller),
      ],
    );
  }
}

class _LaporanList extends StatelessWidget {
  final HomeController controller;

  const _LaporanList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.laporanTrendingList;
      if (list.isEmpty) {
        return const LaporanFasilitasEmptyState();
      }

      final visibleItems = list.length > 3 ? list.sublist(0, 3) : list;

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: visibleItems.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final laporan = visibleItems[index];
          return LaporanFasilitasCard(
            laporan: laporan,
            currentUserId: controller.currentUser?.id ?? '',
            showVoteColumn: true,
            showActions: false,
            showVoteButtons: true,
            onTap: () async {
              final changed = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailLaporanFasilitasView(
                    laporanId: laporan.id,
                    role: 'mahasiswa',
                  ),
                ),
              );
              if (changed == true) controller.refreshData();
            },
            onEdit: null,
            onDelete: null,
            onUpvote: () => controller.onUpvoteLaporan(laporan.id),
            onDownvote: () => controller.onDownvoteLaporan(laporan.id),
          );
        },
      );
    });
  }
}
