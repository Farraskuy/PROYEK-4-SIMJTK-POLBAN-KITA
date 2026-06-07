import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class LaporanFasilitasEmptyState extends StatelessWidget {
  const LaporanFasilitasEmptyState({
    super.key,
    this.icon = Icons.assignment_outlined,
    this.title = 'Belum ada laporan fasilitas',
    this.description = 'Laporan yang masuk akan muncul di bagian ini.',
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 48,
              color: AppColors.muted,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
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
