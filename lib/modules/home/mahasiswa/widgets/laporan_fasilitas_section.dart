import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/controller/home_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/widgets/section_header.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_vote_column.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

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
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'Belum ada laporan fasilitas',
              style: TextStyle(color: AppColors.body),
            ),
          ),
        );
      }

      final visibleItems = list.length > 3 ? list.sublist(0, 3) : list;

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: visibleItems.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, index) {
          return _LaporanCard(
            laporan: visibleItems[index],
            controller: controller,
          );
        },
      );
    });
  }
}

class _LaporanCard extends StatelessWidget {
  final LaporanFasilitasModel laporan;
  final HomeController controller;

  const _LaporanCard({required this.laporan, required this.controller});

  Color get _statusBgColor {
    switch (laporan.status) {
      case StatusLaporan.pending:
        return AppColors.blueSoft;
      case StatusLaporan.in_progress:
        return AppColors.greenSoft;
      case StatusLaporan.resolved:
        return AppColors.greenSoft;
      case StatusLaporan.escalated_to_upt:
        return AppColors.purpleSoft;
      case StatusLaporan.waiting_disposal:
        return AppColors.blueSoft;
      case StatusLaporan.cancelled:
        return AppColors.border;
    }
  }

  Color get _statusTextColor {
    switch (laporan.status) {
      case StatusLaporan.pending:
        return AppColors.primary;
      case StatusLaporan.in_progress:
        return AppColors.success;
      case StatusLaporan.resolved:
        return AppColors.success;
      case StatusLaporan.escalated_to_upt:
        return AppColors.purple;
      case StatusLaporan.waiting_disposal:
        return AppColors.primary;
      case StatusLaporan.cancelled:
        return AppColors.body;
    }
  }

  String get _waktuRelatif {
    final diff = DateTime.now().difference(laporan.updatedAt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    return '${diff.inDays} hari yang lalu';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          LaporanFasilitasVoteColumn(
            voteScore: laporan.vote_score,
            isUpvoted: controller.isLaporanUpvoted(laporan),
            isDownvoted: controller.isLaporanDownvoted(laporan),
            onUpvote: () => controller.onUpvoteLaporan(laporan.id),
            onDownvote: () => controller.onDownvoteLaporan(laporan.id),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        laporan.status.label.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _statusTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _waktuRelatif,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  laporan.judul,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.title,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  laporan.deskripsi,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.body,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  laporan.lokasi,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.muted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}