import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class LaporanFasilitasStatusChip extends StatelessWidget {
  final StatusLaporan status;
  final bool printed;

  const LaporanFasilitasStatusChip({
    super.key,
    required this.status,
    required this.printed,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    if (printed) {
      bg = AppColors.greenSoft;
      fg = AppColors.success;
      label = 'Selesai';
      icon = Icons.check_circle_rounded;
    } else {
      switch (status) {
        case StatusLaporan.pending:
          bg = AppColors.blueSoft;
          fg = AppColors.primary;
          label = 'Menunggu Petugas';
          icon = Icons.info_outline_rounded;
          break;
        case StatusLaporan.in_progress:
          bg = AppColors.orangeSoft;
          fg = AppColors.warning;
          label = 'Ditangani Petugas';
          icon = Icons.hourglass_top_rounded;
          break;
        case StatusLaporan.resolved:
          bg = AppColors.greenSoft;
          fg = AppColors.success;
          label = 'Selesai';
          icon = Icons.check_circle_rounded;
          break;
        case StatusLaporan.escalated_to_upt:
          bg = AppColors.orangeSoft;
          fg = AppColors.warning;
          label = 'Diajukan ke TU';
          icon = Icons.hourglass_top_rounded;
          break;
        case StatusLaporan.waiting_disposal:
          bg = AppColors.orangeSoft;
          fg = AppColors.warning;
          label = 'Menunggu Cetak TU';
          icon = Icons.hourglass_top_rounded;
          break;
        case StatusLaporan.cancelled:
          bg = AppColors.redSoft;
          fg = AppColors.danger;
          label = 'Dibatalkan';
          icon = Icons.cancel_outlined;
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: fg,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
