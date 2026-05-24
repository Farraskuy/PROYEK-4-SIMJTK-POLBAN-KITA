import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/controller/home_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/model/home_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/widgets/section_header.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class AksesCepatSection extends StatelessWidget {
  final HomeController controller;
  final ValueChanged<MahasiswaNavTarget?> onNavigate;

  const AksesCepatSection({
    super.key,
    required this.controller,
    required this.onNavigate,
  });

  static const Map<String, IconData> _iconMap = {
    'report': Icons.report_problem_outlined,
    'search': Icons.manage_search_rounded,
    'school': Icons.school_outlined,
    'description': Icons.description_outlined,
    'science': Icons.science_outlined,
    'meeting_room': Icons.meeting_room_outlined,
    'calendar_month': Icons.calendar_month_outlined,
    'receipt_long': Icons.receipt_long_outlined,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MahasiswaSectionHeader(
          title: 'Akses Cepat',
          onLihatSemua: controller.onLihatSemuaAksesCepat,
        ),

         const SizedBox(height: 12),
        
        Obx(() {
          final list = controller.aksesCepatList;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 12,
                crossAxisSpacing: 8,
                childAspectRatio: 0.82,
              ),
              itemCount: list.length,
              itemBuilder: (context, index) {
                final item = list[index];
                return _AksesCepatItem(
                  item: item,
                  icon: _iconMap[item.iconAsset] ?? Icons.circle_outlined,
                  onTap: () =>
                      onNavigate(controller.onAksesCepatTapped(item.route)),
                );
              },
            ),
          );
        }),
      ],
    );
  }
}

class _AksesCepatItem extends StatelessWidget {
  final AksesCepatModel item;
  final IconData icon;
  final VoidCallback onTap;

  const _AksesCepatItem({
    required this.item,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.blueSoft,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Icon(icon, size: 24, color: AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: AppColors.title,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
