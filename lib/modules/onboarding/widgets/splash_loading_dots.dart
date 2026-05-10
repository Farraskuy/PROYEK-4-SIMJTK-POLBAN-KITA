import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class SplashLoadingDots extends StatelessWidget {
  const SplashLoadingDots({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => Container(
          width: 6,
          height: 6,
          margin: EdgeInsets.only(left: index == 0 ? 0 : 8),
          decoration: const BoxDecoration(
            color: AppColors.navy,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
