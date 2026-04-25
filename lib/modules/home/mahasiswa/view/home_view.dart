import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';
import '../model/home_model.dart';

class _AppColors {
  static const primary = Color(0xFF1A3A6B);
  static const primaryLight = Color(0xFF2B5BAE);
  static const surface = Color(0xFFF5F7FA);
  static const ujianBg = Color(0xFF1A3A6B);
  static const tagFasilitas = Color(0xFFE8F5E9);
  static const tagFasilitasText = Color(0xFF2E7D32);
  static const tagAkademik = Color(0xFFE3F2FD);
  static const tagAkademikText = Color(0xFF1565C0);
  static const tagHimpunan = Color(0xFFFFF3E0);
  static const tagHimpunanText = Color(0xFFE65100);
  static const upvoteActive = Color(0xFF1A3A6B);
  static const upvoteInactive = Color(0xFFBDBDBD);
  static const divider = Color(0xFFE0E0E0);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textLight = Color(0xFF9CA3AF);
  static const iconBg = Color(0xFFF0F4FF);
  static const navActive = Color(0xFF1A3A6B);
  static const navInactive = Color(0xFF9CA3AF);
}

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller
    final controller = Get.put(HomeController());

    return Scaffold(
      backgroundColor: _AppColors.surface,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _AppColors.primary),
          );
        }
        return RefreshIndicator(
          color: _AppColors.primary,
          onRefresh: controller.refreshData,
          child: CustomScrollView(
            slivers: [
              // ---- APP BAR ----
              _buildAppBar(controller),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),

                    // ---- KALENDER AKADEMIK ----
                    _SectionHeader(
                      title: 'Kalender Akademik',
                      onLihatSemua: controller.onLihatSemuaKalender,
                    ),
                    const SizedBox(height: 12),
                    _KalenderCarousel(controller: controller),
                    const SizedBox(height: 24),

                    // ---- AKSES CEPAT ----
                    _SectionHeader(
                      title: 'Akses Cepat',
                      onLihatSemua: controller.onLihatSemuaAksesCepat,
                    ),
                    const SizedBox(height: 12),
                    _AksesCepatGrid(controller: controller),
                    const SizedBox(height: 24),

                    // ---- ASPIRASI TRENDING ----
                    _SectionHeader(
                      title: 'Aspirasi Trending',
                      showFlame: true,
                      onLihatSemua: controller.onLihatSemuaAspirasi,
                    ),
                    const SizedBox(height: 12),
                    _AspirasiList(controller: controller),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        );
      }),

      bottomNavigationBar: _buildBottomNavBar(controller),
    );
  }

  SliverAppBar _buildAppBar(HomeController controller) {
    return SliverAppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      floating: true,
      pinned: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 22,
              backgroundColor: _AppColors.primary,
              child: const Icon(Icons.person, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),

            // Nama & Role
            Expanded(
              child: Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, ${controller.currentUser.value.name}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Mahasiswa JTK',
                        style: const TextStyle(
                          fontSize: 12,
                          color: _AppColors.textSecondary,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  )),
            ),

            // Notifikasi Bell
            Obx(() => Stack(
                  children: [
                    IconButton(
                      onPressed: controller.onNotificationTapped,
                      icon: const Icon(Icons.notifications_outlined,
                          color: _AppColors.textPrimary, size: 26),
                    ),
                    if (controller.unreadNotifCount.value > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${controller.unreadNotifCount.value}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar(HomeController controller) {
    final items = BottomNavItemModel.items();
    final icons = [
      Icons.home_rounded,
      Icons.grid_view_rounded,
      Icons.campaign_rounded,
      Icons.person_rounded,
    ];

    return Obx(() => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 20),
                blurRadius: 12,
                offset: const Offset(0, -2),
              )
            ],
          ),
          child: SafeArea(
            child: SizedBox(
              height: 60,
              child: Row(
                children: List.generate(items.length, (i) {
                  final active = controller.selectedNavIndex.value == i;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => controller.onNavItemTapped(i),
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            icons[i],
                            size: 24,
                            color: active
                                ? _AppColors.navActive
                                : _AppColors.navInactive,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            items[i].label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: active
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: active
                                  ? _AppColors.navActive
                                  : _AppColors.navInactive,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ));
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final bool showFlame;
  final VoidCallback? onLihatSemua;

  const _SectionHeader({
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
              color: _AppColors.textPrimary,
            ),
          ),
          if (showFlame) ...[
            const SizedBox(width: 4),
            const Text('🔥', style: TextStyle(fontSize: 16)),
          ],
          const Spacer(),
          GestureDetector(
            onTap: onLihatSemua,
            child: const Text(
              'Lihat Semua',
              style: TextStyle(
                fontSize: 13,
                color: _AppColors.primaryLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _KalenderCard(item: list[index]),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          // Page indicator dots
          Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(list.length, (i) {
                  final active = controller.activeKalenderIndex.value == i;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: active
                          ? _AppColors.primary
                          : _AppColors.divider,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              )),
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
      decoration: BoxDecoration(
        color: isDark ? _AppColors.ujianBg : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 20),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tag + Kalender icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 38)
                      : _AppColors.tagAkademik,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  item.labelTipe,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : _AppColors.tagAkademikText,
                  ),
                ),
              ),
              Icon(
                Icons.calendar_today_rounded,
                size: 18,
                color: isDark ? Colors.white54 : _AppColors.textSecondary,
              ),
            ],
          ),
          const Spacer(),

          // Judul
          Text(
            item.judulAgenda,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : _AppColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Tanggal
          Text(
            item.rentangTanggal,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : _AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AksesCepatGrid extends StatelessWidget {
  final HomeController controller;

  const _AksesCepatGrid({required this.controller});

  // Icon mapping dari string ke IconData
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
    return Obx(() {
      final list = controller.aksesCepatList;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
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
              onTap: () => controller.onAksesCepatTapped(item.route),
            );
          },
        ),
      );
    });
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: _AppColors.iconBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _AppColors.divider, width: 1),
            ),
            child: Icon(icon, size: 24, color: _AppColors.primary),
          ),
          const SizedBox(height: 6),
          Text(
            item.label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: _AppColors.textPrimary,
              height: 1.3,
            ),
          ),
        ],
      ),
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
            child: Text('Belum ada aspirasi',
                style: TextStyle(color: _AppColors.textSecondary)),
          ),
        );
      }

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: list.length,
        separatorBuilder: (_, _) => const Divider(
          height: 1,
          color: _AppColors.divider,
        ),
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
        return _AppColors.tagFasilitas;
      case KategoriAspirasi.akademik:
        return _AppColors.tagAkademik;
      case KategoriAspirasi.himpunan:
        return _AppColors.tagHimpunan;
      case KategoriAspirasi.umum:
        return _AppColors.iconBg;
    }
  }

  Color get _tagTextColor {
    switch (aspirasi.kategori) {
      case KategoriAspirasi.fasilitas:
        return _AppColors.tagFasilitasText;
      case KategoriAspirasi.akademik:
        return _AppColors.tagAkademikText;
      case KategoriAspirasi.himpunan:
        return _AppColors.tagHimpunanText;
      case KategoriAspirasi.umum:
        return _AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upvote Column
          GestureDetector(
            onTap: onUpvote,
            child: Column(
              children: [
                Icon(
                  Icons.keyboard_arrow_up_rounded,
                  size: 26,
                  color: isUpvoted
                      ? _AppColors.upvoteActive
                      : _AppColors.upvoteInactive,
                ),
                Text(
                  '${aspirasi.upvoteCount}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isUpvoted
                        ? _AppColors.upvoteActive
                        : _AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tag + Waktu
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
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
                        color: _AppColors.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Judul Topik
                Text(
                  aspirasi.topik,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),

                // Deskripsi
                Text(
                  aspirasi.isiSaran,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _AppColors.textSecondary,
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