import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/controller/home_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/model/home_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/mahasiswa/widgets/section_header.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class AspirasiSection extends StatelessWidget {
  final HomeController controller;
  final ValueChanged<MahasiswaNavTarget?> onNavigate;

  const AspirasiSection({
    super.key,
    required this.controller,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MahasiswaSectionHeader(
          title: 'Aspirasi',
          showFlame: true,
          onLihatSemua: () => onNavigate(controller.onLihatSemuaAspirasi()),
        ),
        const SizedBox(height: 12),
        _AspirasiList(controller: controller),
      ],
    );
  }
}

class _AspirasiList extends StatelessWidget {
  final HomeController controller;

  const _AspirasiList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final list = controller.aspirasiTrendingList;
      if (list.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text(
              'Belum ada aspirasi',
              style: TextStyle(color: AppColors.body),
            ),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        separatorBuilder: (_, _) =>
            const Divider(height: 1, color: AppColors.border),
        itemBuilder: (context, index) {
          return _AspirasiCard(
            aspirasi: list[index],
            isUpvoted: controller.isUpvoted(list[index]),
            onUpvote: () => controller.onUpvoteAspirasi(list[index].id),
          );
        },
      );
    });
  }
}

class _AspirasiCard extends StatelessWidget {
  final AspirasiModel aspirasi;
  final bool isUpvoted;
  final VoidCallback onUpvote;

  const _AspirasiCard({
    required this.aspirasi,
    required this.isUpvoted,
    required this.onUpvote,
  });

  Color get _tagBgColor {
    switch (aspirasi.kategori) {
      case KategoriAspirasi.fasilitas:
        return AppColors.greenSoft;
      case KategoriAspirasi.akademik:
        return AppColors.blueSoft;
      case KategoriAspirasi.himpunan:
        return AppColors.purpleSoft;
      case KategoriAspirasi.umum:
        return AppColors.blueSoft;
    }
  }

  Color get _tagTextColor {
    switch (aspirasi.kategori) {
      case KategoriAspirasi.fasilitas:
        return AppColors.success;
      case KategoriAspirasi.akademik:
        return AppColors.primary;
      case KategoriAspirasi.himpunan:
        return AppColors.purple;
      case KategoriAspirasi.umum:
        return AppColors.body;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onUpvote,
            child: Column(
              children: [
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 26,
                  color: isUpvoted ? AppColors.primary : AppColors.muted,
                ),
                Text(
                  '${aspirasi.upvoteCount}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isUpvoted ? AppColors.primary : AppColors.body,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _tagBgColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        aspirasi.labelKategori,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: _tagTextColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      aspirasi.waktuRelatif,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  aspirasi.topik,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.title,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  aspirasi.isiSaran,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.body,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
