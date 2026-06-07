import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/interaksi_laporan_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/lapor_fasilitas_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/detail_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/tambah_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_card.dart';

class LaporanFasilitasListSection extends StatelessWidget {
  final InteraksiLaporanController controller;
  final String role;

  const LaporanFasilitasListSection({
    super.key,
    required this.controller,
    required this.role,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final laporanList = controller.listLaporan;

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final laporan = laporanList[index];
            return Padding(
              padding: EdgeInsets.only(bottom: index == laporanList.length - 1 ? 0 : 12),
              child: LaporanFasilitasCard(
                laporan: laporan,
                currentUserId: controller.currentUserId,
                showVoteColumn: true,
                showActions: false,
                showVoteButtons: controller.isMahasiswa,
                onTap: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailLaporanFasilitasView(
                        laporanId: laporan.id,
                        role: role,
                      ),
                    ),
                  );
                  if (changed == true) controller.fetchLaporan();
                },
                onEdit: () {
                  final laporCtrl = Get.put(LaporFasilitasController());
                  laporCtrl.setupEditPage(laporan);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const TambahLaporanFasilitasView(),
                    ),
                  );
                },
                onDelete: () => controller.deleteLaporan(laporan.id),
                onUpvote: () => controller.upvoteLaporan(
                  controller.currentUserId,
                  index,
                ),
                onDownvote: () => controller.downvoteLaporan(
                  controller.currentUserId,
                  index,
                ),
              ),
            );
          },
          childCount: laporanList.length,
        ),
      );
    });
  }
}
