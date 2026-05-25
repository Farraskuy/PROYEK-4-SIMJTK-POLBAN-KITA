import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class LaporanFasilitasEmptyState extends StatelessWidget {
  const LaporanFasilitasEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 48,
              color: AppColors.muted,
            ),
            SizedBox(height: 12),
            Text(
              'Belum ada laporan fasilitas',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.title,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Laporan yang masuk akan muncul di bagian ini.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.body,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
