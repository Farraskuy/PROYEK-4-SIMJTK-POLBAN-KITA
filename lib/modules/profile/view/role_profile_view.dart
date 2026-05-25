import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/onboarding/view/onboarding_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/profile/view/widgets/profile_empty_state.dart';
import 'package:proyek_4_poki_polban_kita/modules/profile/view/widgets/profile_settings_card.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/mahasiswa_bottom_nav_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';

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

            return RefreshIndicator(
              color: AppColors.primary,
              onRefresh: () async {
                setState(() {
                  _profileFuture = _loadProfileData();
                });
                await _profileFuture;
              },
              child: NestedScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  AppHomeAppBar(
                    title: 'Halo, ${data.firstName}',
                    subtitle: '${data.roleLabel} JTK',
                    avatarIcon: Icons.person_rounded,
                    unreadCount: 0,
                    onNotificationTap: null,
                  ),
                  SliverToBoxAdapter(child: _ProfileHero(data: data)),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _PinnedTabHeaderDelegate(
                      child: const _ProfileTabs(),
                    ),
                  ),
                ],
                body: TabBarView(
                  children: [
                    _ProfileContent(
                      emptyText: 'Belum ada laporan fasilitas yang Anda buat.',
                      children: data.ownLaporan
                          .map(
                            (laporan) => _LaporanHistoryCard(laporan: laporan),
                          )
                          .toList(),
                    ),
                    _ProfileContent(
                      emptyText: 'Belum ada aspirasi yang Anda buat.',
                      children: data.ownAspirasi
                          .map(
                            (aspirasi) =>
                                _AspirasiHistoryCard(aspirasi: aspirasi),
                          )
                          .toList(),
                    ),
                  ],
                ),
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

    final aspirasiList =
        AspirasiModel.dummyList()
            .where((item) => userIds.contains(item.pelaporId))
            .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.data});

  final _ProfileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 12,
        20,
        20,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFF132536),
            child: Stack(
              alignment: Alignment.center,
              children: const [
                Icon(Icons.school_rounded, color: Color(0xFFFF944D), size: 26),
                Positioned(
                  right: 6,
                  top: 10,
                  child: Icon(Icons.circle, color: Color(0xFFFFB36D), size: 6),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Halo, ${data.firstName}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.roleLabel} JTK',
                  style: const TextStyle(
                    color: AppColors.body,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileHero extends StatelessWidget {
  const _ProfileHero({required this.data});

  final _ProfileData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 304,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 34),
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
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white24, width: 5),
              color: const Color(0xFF2F363B),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFF6FA6A4),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: CustomPaint(
                  painter: _AvatarPainter(),
                  size: const Size(80, 80),
                ),
              ),
            ),
          ),
          const SizedBox(width: 18),
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
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.05,
                  ),
                ),
                const SizedBox(height: 20),
                _HeroLine(
                  icon: Icons.badge_outlined,
                  text:
                      'NIM: ${data.nomorInduk.isEmpty ? '-' : data.nomorInduk}',
                ),
                const SizedBox(height: 12),
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
        Icon(icon, color: const Color(0xFFD7E7F3), size: 21),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFD7E7F3),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileTabs extends StatelessWidget {
  const _ProfileTabs();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7F8FA),
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 0),
      child: const TabBar(
        labelColor: Color(0xFF005B84),
        unselectedLabelColor: Color(0xFF444B55),
        indicatorColor: Color(0xFF005B84),
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Color(0xFFE0E2E5),
        labelStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
        unselectedLabelStyle: TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(text: 'Laporan Saya'),
          Tab(text: 'Aspirasi Saya'),
        ],
      ),
    );
  }
}

class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.children, required this.emptyText});

  final List<Widget> children;
  final String emptyText;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 30, 22, 24),
      children: [
        if (children.isEmpty)
          ProfileEmptyState(text: emptyText)
        else
          ...children,
        const SizedBox(height: 10),
        const ProfileSettingsCard(),
        const SizedBox(height: 18),
        const _SignOutTile(),
      ],
    );
  }
}

class _LaporanHistoryCard extends StatelessWidget {
  const _LaporanHistoryCard({required this.laporan});

  final LaporanFasilitasModel laporan;

  @override
  Widget build(BuildContext context) {
    return _HistoryCard(
      icon: _iconForLaporan(laporan.judul),
      title: laporan.judul,
      description: laporan.deskripsi,
      date: _formatDate(laporan.createdAt),
      status: _StatusPresentation.fromLaporan(laporan.status),
    );
  }

  IconData _iconForLaporan(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('jaringan') || lower.contains('wifi')) {
      return Icons.wifi_off_rounded;
    }
    if (lower.contains('kursi')) return Icons.chair_outlined;
    return Icons.construction_rounded;
  }
}

class _AspirasiHistoryCard extends StatelessWidget {
  const _AspirasiHistoryCard({required this.aspirasi});

  final AspirasiModel aspirasi;

  @override
  Widget build(BuildContext context) {
    return _HistoryCard(
      icon: Icons.chat_bubble_outline_rounded,
      title: aspirasi.topik,
      description: aspirasi.isiSaran,
      date: _formatDate(aspirasi.createdAt),
      status: _StatusPresentation.fromAspirasi(aspirasi.status),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.date,
    required this.status,
  });

  final IconData icon;
  final String title;
  final String description;
  final String date;
  final _StatusPresentation status;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      padding: const EdgeInsets.fromLTRB(30, 30, 30, 28),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F3F5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: const Color(0xFF2F609F), size: 30),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF1D2024),
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                          height: 1.12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF535B66),
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Divider(height: 1, color: Color(0xFFECEDEF)),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                date,
                style: const TextStyle(
                  color: Color(0xFF535B66),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              _StatusChip(status: status),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final _StatusPresentation status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(status.icon, color: status.foreground, size: 15),
          const SizedBox(width: 6),
          Text(
            status.label,
            style: TextStyle(
              color: status.foreground,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusPresentation {
  const _StatusPresentation({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  factory _StatusPresentation.fromLaporan(StatusLaporan status) {
    switch (status) {
      case StatusLaporan.resolved:
        return const _StatusPresentation(
          label: 'Selesai',
          icon: Icons.check_circle_rounded,
          background: Color(0xFFE2EEF1),
          foreground: Color(0xFF005B84),
        );
      case StatusLaporan.in_progress:
      case StatusLaporan.escalated_to_upt:
      case StatusLaporan.waiting_disposal:
        return const _StatusPresentation(
          label: 'Diproses',
          icon: Icons.more_horiz_rounded,
          background: Color(0xFFE6F2FF),
          foreground: Color(0xFF005B84),
        );
      case StatusLaporan.pending:
      case StatusLaporan.cancelled:
        return const _StatusPresentation(
          label: 'Menunggu Verifikasi',
          icon: Icons.schedule_rounded,
          background: Color(0xFFE9EAEC),
          foreground: Color(0xFF535B66),
        );
    }
  }

  factory _StatusPresentation.fromAspirasi(StatusAspirasi status) {
    switch (status) {
      case StatusAspirasi.responded:
        return const _StatusPresentation(
          label: 'Selesai',
          icon: Icons.check_circle_rounded,
          background: Color(0xFFE2EEF1),
          foreground: Color(0xFF005B84),
        );
      case StatusAspirasi.inReview:
        return const _StatusPresentation(
          label: 'Diproses',
          icon: Icons.more_horiz_rounded,
          background: Color(0xFFE6F2FF),
          foreground: Color(0xFF005B84),
        );
      case StatusAspirasi.open:
        return const _StatusPresentation(
          label: 'Menunggu Verifikasi',
          icon: Icons.schedule_rounded,
          background: Color(0xFFE9EAEC),
          foreground: Color(0xFF535B66),
        );
    }
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
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const OnboardingView()),
              (route) => false,
            );
          }
        },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 18),
          child: Row(
            children: [
              Icon(Icons.logout_rounded, color: Color(0xFFD21D1D), size: 22),
              SizedBox(width: 10),
              Text(
                'Sign Out',
                style: TextStyle(
                  color: Color(0xFFD21D1D),
                  fontSize: 18,
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

class _PinnedTabHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedTabHeaderDelegate({required this.child});

  final Widget child;

  @override
  double get minExtent => 70;

  @override
  double get maxExtent => 70;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(
      height: maxExtent,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedTabHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
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
