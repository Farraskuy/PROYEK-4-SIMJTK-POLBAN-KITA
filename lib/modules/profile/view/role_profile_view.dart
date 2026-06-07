import 'dart:async';

import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/onboarding/view/onboarding_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';

import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_card.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_empty_state.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/detail_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/widgets/aspirasi_card.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/detail_aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/service/aspirasi_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/aspirasi_form_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/lapor_fasilitas_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/lapor_fasilitas_view.dart';

class RoleProfileView extends StatefulWidget {
  const RoleProfileView({super.key, required this.role});

  final String role;

  @override
  State<RoleProfileView> createState() => _RoleProfileViewState();
}

class _RoleProfileViewState extends State<RoleProfileView> {
  late Future<_ProfileData> _profileFuture;
  int _loadGeneration = 0;

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
                  ),
                  SliverToBoxAdapter(child: _ProfileHero(data: data)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isMahasiswa) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: _OwnHistoryCardButton(
                                    title: 'Laporan Saya',
                                    subtitle: 'Keluhan fasilitas',
                                    count: data.ownLaporan.length,
                                    icon: Icons.assignment_outlined,
                                    color: AppColors.primary,
                                    onTap: () {
                                      Get.to(
                                        () => MahasiswaOwnReportsView(
                                          ownLaporan: data.ownLaporan,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _OwnHistoryCardButton(
                                    title: 'Aspirasi Saya',
                                    subtitle: 'Saran & masukan',
                                    count: data.ownAspirasi.length,
                                    icon: Icons.chat_bubble_outline_rounded,
                                    color: AppColors.secondary,
                                    onTap: () {
                                      Get.to(
                                        () => MahasiswaOwnAspirationsView(
                                          ownAspirasi: data.ownAspirasi,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
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
      ),
    );
  }

  Future<_ProfileData> _loadProfileData() async {
    final generation = ++_loadGeneration;
    final auth = AuthService();
    var user = auth.currentUser;
    if (user == null) {
      try {
        user = await auth.loadSavedSession();
      } catch (_) {
        user = null;
      }
    }

    final userIds = <String>{};
    if (user != null) {
      if (user.id.isNotEmpty) userIds.add(user.id);
      if (user.nomorInduk.isNotEmpty) userIds.add(user.nomorInduk);
    }

    final baseData = _ProfileData(
      roleLabel: _roleLabel,
      name: user?.name.isNotEmpty == true ? user!.name : 'Pengguna',
      nomorInduk: user?.nomorInduk ?? '-',
      programStudy: user?.programStudy.isNotEmpty == true
          ? user!.programStudy
          : 'Dept. of Computer Science',
      initials: _initials(user?.name ?? _roleLabel),
      ownAspirasi: const [],
      ownLaporan: const [],
    );

    unawaited(_loadProfileHistory(baseData, userIds, generation));
    return baseData;
  }

  Future<void> _loadProfileHistory(
    _ProfileData baseData,
    Set<String> userIds,
    int generation,
  ) async {
    var aspirasiList = <AspirasiModel>[];
    var ownLaporan = <LaporanFasilitasModel>[];

    await Future.wait([
      () async {
        try {
          final raw = await AspirasiService().fetchAllAspirasi();
          aspirasiList =
              raw
                  .where(
                    (item) =>
                        item.pelaporId != null &&
                        userIds.contains(item.pelaporId),
                  )
                  .toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } catch (_) {}
      }(),
      () async {
        try {
          final raw = await LaporanFasilitasService().getAll();
          ownLaporan =
              raw.where((item) => userIds.contains(item.pelapor_id)).toList()
                ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        } catch (_) {}
      }(),
    ]);

    if (!mounted || generation != _loadGeneration) return;

    setState(() {
      _profileFuture = Future.value(
        baseData.copyWith(ownAspirasi: aspirasiList, ownLaporan: ownLaporan),
      );
    });
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

  _ProfileData copyWith({
    List<AspirasiModel>? ownAspirasi,
    List<LaporanFasilitasModel>? ownLaporan,
  }) {
    return _ProfileData(
      roleLabel: roleLabel,
      name: name,
      nomorInduk: nomorInduk,
      programStudy: programStudy,
      initials: initials,
      ownAspirasi: ownAspirasi ?? this.ownAspirasi,
      ownLaporan: ownLaporan ?? this.ownLaporan,
    );
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

class _OwnHistoryCardButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _OwnHistoryCardButton({
    required this.title,
    required this.subtitle,
    required this.count,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: color,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.title,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.body,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MahasiswaOwnReportsView extends StatefulWidget {
  final List<LaporanFasilitasModel> ownLaporan;

  const MahasiswaOwnReportsView({super.key, required this.ownLaporan});

  @override
  State<MahasiswaOwnReportsView> createState() =>
      _MahasiswaOwnReportsViewState();
}

class _MahasiswaOwnReportsViewState extends State<MahasiswaOwnReportsView> {
  late List<LaporanFasilitasModel> _listLaporan;
  String _currentFilter = 'Terbaru'; // 'Terbaru' or 'Selesai'

  @override
  void initState() {
    super.initState();
    _listLaporan = List.from(widget.ownLaporan);
  }

  List<LaporanFasilitasModel> get _filteredLaporan {
    var list = List<LaporanFasilitasModel>.from(_listLaporan);
    if (_currentFilter == 'Terbaru') {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_currentFilter == 'Selesai') {
      list = list
          .where((l) => l.status == StatusLaporan.resolved || l.sudahDicetak)
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  Widget _localSortChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.title,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredLaporan;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const AppSliverDetailAppBar(
            title: 'Laporan Saya',
            subtitle: 'Riwayat keluhan Anda',
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  _localSortChip(
                    label: 'Terbaru',
                    selected: _currentFilter == 'Terbaru',
                    onTap: () {
                      setState(() {
                        _currentFilter = 'Terbaru';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _localSortChip(
                    label: 'Selesai',
                    selected: _currentFilter == 'Selesai',
                    onTap: () {
                      setState(() {
                        _currentFilter = 'Selesai';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: LaporanFasilitasEmptyState(),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final laporan = filtered[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LaporanFasilitasCard(
                      laporan: laporan,
                      currentUserId: laporan.pelapor_id,
                      showVoteColumn: false,
                      showActions: true,
                      showVoteButtons: false,
                      onTap: () async {
                        final changed = await Get.to(
                          () => DetailLaporanFasilitasView(
                            laporanId: laporan.id,
                            role: 'mahasiswa',
                          ),
                        );
                        if (changed == true) {
                          final fresh = await LaporanFasilitasService()
                              .getAll();
                          final user = AuthService().currentUser;
                          if (user != null) {
                            setState(() {
                              _listLaporan = fresh
                                  .where(
                                    (item) =>
                                        item.pelapor_id == user.id ||
                                        item.pelapor_id == user.nomorInduk,
                                  )
                                  .toList();
                            });
                          }
                        }
                      },
                      onEdit: () {
                        final currentUser = AuthService().currentUser;
                        if (currentUser == null) return;
                        if (laporan.pelapor_id != currentUser.id &&
                            laporan.pelapor_id != currentUser.nomorInduk) {
                          Get.snackbar(
                            'Gagal',
                            'Anda hanya bisa mengubah laporan Anda sendiri',
                          );
                          return;
                        }
                        final laporCtrl = Get.put(LaporFasilitasController());
                        laporCtrl.setupEditPage(laporan);
                        Get.to(() => const LaporFasilitasView());
                      },
                      onDelete: () {
                        final currentUser = AuthService().currentUser;
                        if (currentUser == null) return;
                        if (laporan.pelapor_id != currentUser.id &&
                            laporan.pelapor_id != currentUser.nomorInduk) {
                          Get.snackbar(
                            'Gagal',
                            'Anda hanya bisa menghapus laporan Anda sendiri',
                          );
                          return;
                        }
                        Get.defaultDialog(
                          title: 'Hapus Laporan',
                          middleText:
                              'Apakah Anda yakin ingin menghapus laporan ini?',
                          textConfirm: 'Hapus',
                          textCancel: 'Batal',
                          confirmTextColor: Colors.white,
                          buttonColor: AppColors.danger,
                          onConfirm: () async {
                            try {
                              await LaporanFasilitasService().delete(
                                laporan.id,
                              );
                              Get.back();
                              Get.snackbar(
                                'Sukses',
                                'Laporan berhasil dihapus',
                              );
                              setState(() {
                                _listLaporan.removeWhere(
                                  (item) => item.id == laporan.id,
                                );
                              });
                            } catch (e) {
                              Get.snackbar(
                                'Gagal',
                                'Gagal menghapus laporan: $e',
                              );
                            }
                          },
                        );
                      },
                      onUpvote: () {},
                      onDownvote: () {},
                    ),
                  );
                }, childCount: filtered.length),
              ),
            ),
        ],
      ),
    );
  }
}

class MahasiswaOwnAspirationsView extends StatefulWidget {
  final List<AspirasiModel> ownAspirasi;

  const MahasiswaOwnAspirationsView({super.key, required this.ownAspirasi});

  @override
  State<MahasiswaOwnAspirationsView> createState() =>
      _MahasiswaOwnAspirationsViewState();
}

class _MahasiswaOwnAspirationsViewState
    extends State<MahasiswaOwnAspirationsView> {
  late List<AspirasiModel> _listAspirasi;
  String _currentFilter = 'Terbaru'; // 'Terbaru' or 'Selesai'

  @override
  void initState() {
    super.initState();
    _listAspirasi = List.from(widget.ownAspirasi);
  }

  List<AspirasiModel> get _filteredAspirasi {
    var list = List<AspirasiModel>.from(_listAspirasi);
    if (_currentFilter == 'Terbaru') {
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } else if (_currentFilter == 'Selesai') {
      list = list.where((a) => a.status == StatusAspirasi.responded).toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  Widget _localSortChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: selected ? Colors.white : AppColors.title,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredAspirasi;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const AppSliverDetailAppBar(
            title: 'Aspirasi Saya',
            subtitle: 'Riwayat saran Anda',
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Row(
                children: [
                  _localSortChip(
                    label: 'Terbaru',
                    selected: _currentFilter == 'Terbaru',
                    onTap: () {
                      setState(() {
                        _currentFilter = 'Terbaru';
                      });
                    },
                  ),
                  const SizedBox(width: 8),
                  _localSortChip(
                    label: 'Selesai',
                    selected: _currentFilter == 'Selesai',
                    onTap: () {
                      setState(() {
                        _currentFilter = 'Selesai';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          if (filtered.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: LaporanFasilitasEmptyState(
                icon: Icons.campaign_outlined,
                title: 'Belum ada aspirasi',
                description: 'Aspirasi Anda akan muncul di bagian ini.',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final aspirasi = filtered[index];
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
                      onEdit: () {
                        final currentUser = AuthService().currentUser;
                        if (currentUser == null) return;
                        if (aspirasi.pelaporId != currentUser.id &&
                            aspirasi.pelaporId != currentUser.nomorInduk) {
                          Get.snackbar(
                            'Gagal',
                            'Anda hanya bisa mengubah aspirasi Anda sendiri',
                          );
                          return;
                        }
                        Get.to(() => AspirasiEditView(aspirasi: aspirasi));
                      },
                      onDelete: () {
                        final currentUser = AuthService().currentUser;
                        if (currentUser == null) return;
                        if (aspirasi.pelaporId != currentUser.id &&
                            aspirasi.pelaporId != currentUser.nomorInduk) {
                          Get.snackbar(
                            'Gagal',
                            'Anda hanya bisa menghapus aspirasi Anda sendiri',
                          );
                          return;
                        }
                        Get.defaultDialog(
                          title: 'Hapus Aspirasi',
                          middleText:
                              'Apakah Anda yakin ingin menghapus aspirasi ini?',
                          textConfirm: 'Hapus',
                          textCancel: 'Batal',
                          confirmTextColor: Colors.white,
                          buttonColor: AppColors.danger,
                          onConfirm: () async {
                            try {
                              await AspirasiService().deleteAspirasi(
                                aspirasi.id,
                              );
                              Get.back();
                              Get.snackbar(
                                'Sukses',
                                'Aspirasi berhasil dihapus',
                              );
                              setState(() {
                                _listAspirasi.removeWhere(
                                  (item) => item.id == aspirasi.id,
                                );
                              });
                            } catch (e) {
                              Get.snackbar(
                                'Gagal',
                                'Gagal menghapus aspirasi: $e',
                              );
                            }
                          },
                        );
                      },
                      onTap: () {
                        Get.to(
                          () => DetailAspirasiView(
                            aspirasi: aspirasi,
                            role: 'mahasiswa',
                          ),
                        );
                      },
                    ),
                  );
                }, childCount: filtered.length),
              ),
            ),
        ],
      ),
    );
  }
}
