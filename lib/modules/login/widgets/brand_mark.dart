import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Text(
        'SIMJTK',
        style: GoogleFonts.manrope(
          color: AppColors.navy,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          height: 32 / 24,
        ),
      );
    }

    return Text(
      'SIM\nJTK',
      textAlign: TextAlign.center,
      style: GoogleFonts.manrope(
        color: AppColors.navy,
        fontSize: 72,
        fontWeight: FontWeight.w800,
        height: 1,
        letterSpacing: -3.6,
      ),
    );
  }
}
