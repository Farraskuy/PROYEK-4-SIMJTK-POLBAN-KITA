import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class AppFieldLabel extends StatelessWidget {
  const AppFieldLabel({
    super.key,
    required this.text,
    this.required = false,
    this.color,
    this.uppercase = true,
  });

  final String text;
  final bool required;
  final Color? color;
  final bool uppercase;

  @override
  Widget build(BuildContext context) {
    final label = uppercase ? text.toUpperCase() : text;

    return Text.rich(
      TextSpan(
        text: label,
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.danger),
            ),
        ],
      ),
      style: GoogleFonts.poppins(
        color: color ?? AppColors.muted,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 16 / 12,
        letterSpacing: uppercase ? 0.6 : 0,
      ),
    );
  }
}
