import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class MahasiswaSectionHeader extends StatelessWidget {
  final String title;
  final bool showFlame;
  final VoidCallback? onLihatSemua;

  const MahasiswaSectionHeader({
    super.key,
    required this.title,
    this.showFlame = false,
    this.onLihatSemua,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.title,
            ),
          ),
          const Spacer(),
          if (onLihatSemua != null)
            GestureDetector(
              onTap: onLihatSemua,
              child: const Text(
                'Lihat Semua',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
