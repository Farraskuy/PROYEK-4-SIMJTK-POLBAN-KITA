import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/controller/home_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/model/home_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/widgets/section_header.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class KalenderSection extends StatelessWidget {
  final HomeController controller;

  const KalenderSection({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MahasiswaSectionHeader(
          title: 'Kalender Akademik',
          onLihatSemua: controller.onLihatSemuaKalender,
        ),
        const SizedBox(height: 12),
        _KalenderCarousel(controller: controller),
      ],
    );
  }
}

class _KalenderCarousel extends StatelessWidget {
  final HomeController controller;

  const _KalenderCarousel({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.kalenderList;
      if (list.isEmpty) return const SizedBox.shrink();

      return Column(
        children: [
          SizedBox(
            height: 130,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.88),
              onPageChanged: controller.onKalenderPageChanged,
              itemCount: list.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: _KalenderCard(item: list[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(list.length, (i) {
                final active = controller.activeKalenderIndex.value == i;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary : AppColors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
        ],
      );
    });
  }
}

class _KalenderCard extends StatelessWidget {
  final KalenderAkademikModel item;

  const _KalenderCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final isUjian = item.tipeKartu == TipeKartuKalender.ujian;
    final isDark = isUjian;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.navy : Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.15)
                      : AppColors.blueSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.labelTipe,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.primary,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: isDark ? Colors.white54 : AppColors.body,
              ),
            ],
          ),
          const Spacer(),
          Text(
            item.judulAgenda,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.title,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            item.rentangTanggal,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : AppColors.body,
            ),
          ),
        ],
      ),
    );
  }
}
