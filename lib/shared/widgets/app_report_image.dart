import 'dart:io';

import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class AppReportImage extends StatelessWidget {
  const AppReportImage({
    super.key,
    this.source,
    this.height = 180,
    this.width = double.infinity,
    this.fit = BoxFit.cover,
  });

  final String? source;
  final double height;
  final double width;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final value = source?.trim() ?? '';
    if (value.isEmpty) return _fallback();

    if (value.startsWith('https://') || value.startsWith('http://')) {
      return Image.network(
        value,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }

    return Image.file(
      File(value),
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (_, _, _) => _fallback(),
    );
  }

  Widget _fallback() {
    return Container(
      height: height,
      width: width,
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.image_not_supported_outlined, color: AppColors.muted),
          SizedBox(height: 6),
          Text(
            'Foto tidak tersedia',
            style: TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
