import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_dashboard_components.dart';

class LaporanFasilitasHeaderSection extends StatelessWidget {
  final String title;
  final String description;

  const LaporanFasilitasHeaderSection({
    super.key,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSectionHeader(title: title),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(fontSize: 12, height: 1.45),
          ),
        ],
      ),
    );
  }
}
