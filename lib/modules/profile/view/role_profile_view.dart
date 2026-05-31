import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/onboarding/view/onboarding_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/mahasiswa_bottom_nav_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';

import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_button.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_card.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/detail_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/widgets/aspirasi_card.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/detail_aspirasi_view.dart';

class RoleProfileView extends StatefulWidget {
  const RoleProfileView({super.key, required this.role});

  final String role;

  @override
  State<RoleProfileView> createState() => _RoleProfileViewState();
}

class _RoleProfileViewState extends State<RoleProfileView> {
  late Future<_ProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfileData();
  }

  String get _roleLabel {
    switch (widget.role) {
      case 'mahasiswa':
        return 'Mahasiswa';
      case 'dosen':
        return 'Dosen';
      case 'teknisi':
        return 'Teknisi';
      case 'admin':
        return 'Admin';
      default:
        return widget.role.toUpperCase();
    }
  }

  bool get _showBottomNav => widget.role == 'mahasiswa';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: FutureBuilder<_ProfileData>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Gagal memuat profil: ${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.body),
                  ),
                ),
              );
            }

            final data = snapshot.data ?? _ProfileData.empty(_roleLabel);

            final isMahasiswa = widget.role == 'mahasiswa';

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                setState(() {
                  _profileFuture = _loadProfileData();
                });
                await _profileFuture;
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  AppHomeAppBar(
                    title: 'Halo, ${data.firstName}',
                    subtitle: '${data.roleLabel} JTK',
                    avatarIcon: Icons.person_rounded,
                    unreadCount: 0,
                    onNotificationTap: null,
                  ),
                  SliverToBoxAdapter(child: _ProfileHero(data: data)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isMahasiswa) ...[
                            AppButton(
                              label: 'Lihat Laporan Saya',
                              leadingIcon: Icons.assignment_outlined,
                              variant: AppButtonVariant.navy,
                              size: AppButtonSize.large,
                              onPressed: () {
                                Get.to(() => MahasiswaOwnReportsView(ownLaporan: data.ownLaporan));
                              },
                            ),
                            const SizedBox(height: 14),
                            AppButton(
                              label: 'Lihat Aspirasi Saya',
                              leadingIcon: Icons.chat_bubble_outline_rounded,
                              variant: AppButtonVariant.navy,
                              size: AppButtonSize.large,
                              onPressed: () {
                                Get.to(() => MahasiswaOwnAspirationsView(ownAspirasi: data.ownAspirasi));
                              },
                            ),
                            const SizedBox(height: 20),
                          ],
                          const _SignOutTile(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        bottomNavigationBar: _showBottomNav
            ? const MahasiswaBottomNavBar(
                selected: MahasiswaNavDestination.profil,
              )
            : null,
      ),
    );
  }

  Future<_ProfileData> _loadProfileData() async {
    final auth = AuthService();
    final user = auth.currentUser ?? await auth.loadSavedSession();
    final userIds = <String>{};
    if (user != null) {
      if (user.id.isNotEmpty) userIds.add(user.id);
      if (user.nomorInduk.isNotEmpty) userIds.add(user.nomorInduk);
    }

    final aspirasiList = List<AspirasiModel>.from({});
    //     AspirasiModel.dummyList()
    //         .where((item) => userIds.contains(item.pelaporId))
    //         .toList()
    //       ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final laporanList = await LaporanFasilitasService().getAll();
    final ownLaporan =
        laporanList.where((item) => userIds.contains(item.pelapor_id)).toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return _ProfileData(
      roleLabel: _roleLabel,
      name: user?.name.isNotEmpty == true ? user!.name : 'Pengguna',
      nomorInduk: user?.nomorInduk ?? '-',
      programStudy: user?.programStudy.isNotEmpty == true
          ? user!.programStudy
          : 'Dept. of Computer Science',
      initials: _initials(user?.name ?? _roleLabel),
      ownAspirasi: aspirasiList,
      ownLaporan: ownLaporan,
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return '${parts.first.substring(0, 1)}${parts[1].substring(0, 1)}'
        .toUpperCase();
  }
}

class _ProfileData {
  const _ProfileData({
    required this.roleLabel,
    required this.name,
    required this.nomorInduk,
    required this.programStudy,
    required this.initials,
    required this.ownAspirasi,
    required this.ownLaporan,
  });

  final String roleLabel;
  final String name;
  final String nomorInduk;
  final String programStudy;
  final String initials;
  final List<AspirasiModel> ownAspirasi;
  final List<LaporanFasilitasModel> ownLaporan;

  String get firstName {
    final parts = name.trim().split(' ').where((part) => part.isNotEmpty);
    return parts.isEmpty ? name : parts.first;
  }

  factory _ProfileData.empty(String roleLabel) {
    return _ProfileData(
      roleLabel: roleLabel,
      name: 'Pengguna',
      nomorInduk: '-',
      programStudy: 'Dept. of Computer Science',
      initials: '?',
      ownAspirasi: const [],
      ownLaporan: const [],
    );
  }
}


class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.data});

  final _ProfileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00335F), Color(0xFF0F4D82)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 3),
              color: const Color(0xFF2F363B),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFF6FA6A4),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: CustomPaint(
                  painter: _AvatarPainter(),
                  size: const Size(52, 52),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                _HeroLine(
                  icon: Icons.badge_outlined,
                  text:
                      'NIM: ${data.nomorInduk.isEmpty ? '-' : data.nomorInduk}',
                ),
                const SizedBox(height: 6),
                _HeroLine(
                  icon: Icons.account_balance_outlined,
                  text: data.programStudy,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final skin = Paint()..color = const Color(0xFFF0C7A6);
    final hair = Paint()..color = const Color(0xFF60422F);
    final suit = Paint()..color = const Color(0xFF2C6F73);
    final suitDark = Paint()..color = const Color(0xFF1F5659);
    final shirt = Paint()..color = const Color(0xFFF8F8F5);
    final tie = Paint()..color = const Color(0xFF1C2730);
    final line = Paint()
      ..color = const Color(0xFF263238)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(Offset(size.width * 0.5, size.height * 0.36), 19, skin);
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.30, size.height * 0.30)
        ..quadraticBezierTo(
          size.width * 0.40,
          size.height * 0.12,
          size.width * 0.67,
          size.height * 0.22,
        )
        ..quadraticBezierTo(
          size.width * 0.72,
          size.height * 0.33,
          size.width * 0.68,
          size.height * 0.43,
        )
        ..quadraticBezierTo(
          size.width * 0.54,
          size.height * 0.30,
          size.width * 0.30,
          size.height * 0.36,
        )
        ..close(),
      hair,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.22, size.height)
        ..lineTo(size.width * 0.34, size.height * 0.58)
        ..quadraticBezierTo(
          size.width * 0.50,
          size.height * 0.68,
          size.width * 0.66,
          size.height * 0.58,
        )
        ..lineTo(size.width * 0.82, size.height)
        ..close(),
      suit,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.39, size.height * 0.62)
        ..lineTo(size.width * 0.50, size.height * 0.80)
        ..lineTo(size.width * 0.61, size.height * 0.62)
        ..close(),
      shirt,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.50, size.height * 0.68)
        ..lineTo(size.width * 0.46, size.height * 0.91)
        ..lineTo(size.width * 0.54, size.height * 0.91)
        ..close(),
      tie,
    );
    canvas.drawLine(
      Offset(size.width * 0.34, size.height * 0.67),
      Offset(size.width * 0.26, size.height * 0.93),
      line..color = const Color(0xFF1F5659),
    );
    canvas.drawLine(
      Offset(size.width * 0.66, size.height * 0.67),
      Offset(size.width * 0.77, size.height * 0.93),
      line,
    );
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.30,
        size.height * 0.78,
        size.width * 0.40,
        size.height * 0.22,
      ),
      3.25,
      2.75,
      false,
      Paint()
        ..color = const Color(0xFFFFE3C8)
        ..strokeWidth = 11
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(Offset(size.width * 0.43, size.height * 0.37), 1.5, tie);
    canvas.drawCircle(Offset(size.width * 0.57, size.height * 0.37), 1.5, tie);
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.44,
        size.height * 0.43,
        size.width * 0.12,
        size.height * 0.08,
      ),
      0.2,
      2.7,
      false,
      line..color = const Color(0xFF263238),
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.31, size.height * 0.32)
        ..quadraticBezierTo(
          size.width * 0.50,
          size.height * 0.18,
          size.width * 0.69,
          size.height * 0.29,
        ),
      line..color = const Color(0xFF60422F),
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.24, size.height)
        ..lineTo(size.width * 0.39, size.height * 0.77)
        ..lineTo(size.width * 0.47, size.height),
      suitDark,
    );
    canvas.drawPath(
      Path()
        ..moveTo(size.width * 0.76, size.height)
        ..lineTo(size.width * 0.61, size.height * 0.77)
        ..lineTo(size.width * 0.53, size.height),
      suitDark,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeroLine extends StatelessWidget {
  const _HeroLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFD7E7F3), size: 16),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFD7E7F3),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}


class _SignOutTile extends StatelessWidget {
  const _SignOutTile();

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () async {
          await AuthService().logout();
          Get.offAll(() => const OnboardingView());
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFD21D1D), size: 18),
              SizedBox(width: 10),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: Color(0xFFD21D1D),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


String _formatDate(DateTime date) {
  final now = DateTime.now();
  final sameDay =
      now.year == date.year && now.month == date.month && now.day == date.day;
  if (sameDay) return 'Hari Ini';

  const months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];
  return '${date.day} ${months[date.month - 1]} ${date.year}';
}

class MahasiswaOwnReportsView extends StatelessWidget {
  final List<LaporanFasilitasModel> ownLaporan;

  const MahasiswaOwnReportsView({super.key, required this.ownLaporan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const AppSliverDetailAppBar(
            title: 'Laporan Saya',
            subtitle: 'Riwayat keluhan Anda',
          ),
          if (ownLaporan.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Belum ada laporan fasilitas yang Anda buat.',
                  style: TextStyle(color: AppColors.body),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final laporan = ownLaporan[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: LaporanFasilitasCard(
                        laporan: laporan,
                        currentUserId: laporan.pelapor_id ?? '',
                        showVoteColumn: false,
                        showActions: true,
                        showVoteButtons: false,
                        onTap: () {
                          Get.to(() => DetailLaporanFasilitasView(
                                laporanId: laporan.id,
                                role: 'mahasiswa',
                              ));
                        },
                        onEdit: () {},
                        onDelete: () {},
                        onUpvote: () {},
                        onDownvote: () {},
                      ),
                    );
                  },
                  childCount: ownLaporan.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class MahasiswaOwnAspirationsView extends StatelessWidget {
  final List<AspirasiModel> ownAspirasi;

  const MahasiswaOwnAspirationsView({super.key, required this.ownAspirasi});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const AppSliverDetailAppBar(
            title: 'Aspirasi Saya',
            subtitle: 'Riwayat saran Anda',
          ),
          if (ownAspirasi.isEmpty)
            const SliverFillRemaining(
              child: Center(
                child: Text(
                  'Belum ada aspirasi yang Anda buat.',
                  style: TextStyle(color: AppColors.body),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final aspirasi = ownAspirasi[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AspirasiCard(
                        aspirasi: aspirasi,
                        isUpvoted: false,
                        isDownvoted: false,
                        showActions: true,
                        showVoteButtons: false,
                        onUpvote: () {},
                        onDownvote: () {},
                        onTap: () {
                          Get.to(() => DetailAspirasiView(
                                aspirasi: aspirasi,
                                role: 'mahasiswa',
                              ));
                        },
                      ),
                    );
                  },
                  childCount: ownAspirasi.length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
