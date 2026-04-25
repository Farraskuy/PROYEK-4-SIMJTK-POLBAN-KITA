// ============================================================
// FILE: modules/aspirasi/view/aspirasi_view.dart
// Kelompok A7 – SIMJTK (Sistem Informasi Mahasiswa JTK)
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/aspirasi_controller.dart';
import '../model/aspirasi_model.dart';

// ============================================================
// DESIGN TOKENS
// ============================================================
class _C {
  static const primary = Color(0xFF1A3A6B);
  static const primaryLight = Color(0xFF2B5BAE);
  static const surface = Color(0xFFF5F7FA);
  static const white = Colors.white;
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textLight = Color(0xFFB0B8CC);
  static const divider = Color(0xFFE5E9F2);
  static const inputBorder = Color(0xFFDDE3EF);
  static const inputFocus = Color(0xFF1A3A6B);
  static const navActive = Color(0xFF1A3A6B);
  static const navInactive = Color(0xFF9CA3AF);
  static const upvoteActive = Color(0xFF1A3A6B);
  static const downvoteActive = Color(0xFFD32F2F);
  static const voteInactive = Color(0xFFBDBDBD);
  static const badgeSelesai = Color(0xFF2E7D32);
  static const badgeSelesaiBg = Color(0xFFE8F5E9);
  static const badgeProses = Color(0xFF1565C0);
  static const badgeProsesBg = Color(0xFFE3F2FD);
  static const tanggapanBg = Color(0xFFF0F4FF);
  static const tanggapanBorder = Color(0xFFB0C0E0);
  static const errorColor = Color(0xFFD32F2F);
  static const avatarBg = Color(0xFF2B5BAE);
  static const anonymousBg = Color(0xFFE5E9F2);
}

// ============================================================
// ASPIRASI VIEW — Entry Point
// ============================================================
class AspirasiView extends StatelessWidget {
  const AspirasiView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AspirasiController());

    return Scaffold(
      backgroundColor: _C.surface,
      appBar: _buildAppBar(ctrl),
      body: Obx(() => ctrl.showForm.value
          ? _AspirasiFormPage(ctrl: ctrl)
          : _AspirasiListPage(ctrl: ctrl)),
      floatingActionButton: Obx(() => ctrl.showForm.value
          ? const SizedBox.shrink()
          : FloatingActionButton.extended(
              onPressed: ctrl.onTambahAspirasi,
              backgroundColor: _C.primary,
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
              label: const Text('Tulis Aspirasi',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
            )),
      bottomNavigationBar: _buildBottomNavBar(ctrl),
    );
  }

  // ---- APP BAR ----
  PreferredSizeWidget _buildAppBar(AspirasiController ctrl) {
    return AppBar(
      backgroundColor: _C.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      title: Obx(() => ctrl.showForm.value
          ? Row(
              children: [
                GestureDetector(
                  onTap: ctrl.onTutupForm,
                  child: const Icon(Icons.arrow_back_rounded,
                      color: _C.textPrimary, size: 22),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Tambah/Edit Aspirasi Mahasiswa',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _C.textPrimary,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: _C.primary,
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halo, ${ctrl.currentUserName}',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary),
                    ),
                    const Text('Mahasiswa JTK',
                        style:
                            TextStyle(fontSize: 11, color: _C.textSecondary)),
                  ],
                ),
              ],
            )),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: _C.textPrimary, size: 24),
          onPressed: () {},
        ),
      ],
    );
  }

  // ---- BOTTOM NAV ----
  Widget _buildBottomNavBar(AspirasiController ctrl) {
    const items = [
      {'label': 'HOME', 'icon': Icons.home_rounded},
      {'label': 'LAYANAN', 'icon': Icons.grid_view_rounded},
      {'label': 'ASPIRASI', 'icon': Icons.campaign_rounded},
      {'label': 'PROFIL', 'icon': Icons.person_rounded},
    ];
    const activeIndex = 2;

    return Container(
      decoration: BoxDecoration(
        color: _C.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2))
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final active = i == activeIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!active) Get.back();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(items[i]['icon'] as IconData,
                          size: 24,
                          color: active ? _C.navActive : _C.navInactive),
                      const SizedBox(height: 2),
                      Text(items[i]['label'] as String,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: active
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: active ? _C.navActive : _C.navInactive)),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// PAGE 1: LIST ASPIRASI
// ============================================================
class _AspirasiListPage extends StatelessWidget {
  final AspirasiController ctrl;
  const _AspirasiListPage({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ---- HEADER ----
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(
            'Suara Mahasiswa',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.w800, color: _C.textPrimary),
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            'Sampaikan aspirasi, saran, dan masukan untuk kemajuan JTK.',
            style: TextStyle(
                fontSize: 13, color: _C.textSecondary, height: 1.5),
          ),
        ),

        // ---- TAB BAR ----
        Container(
          color: _C.white,
          child: TabBar(
            controller: ctrl.tabController,
            labelColor: _C.primary,
            unselectedLabelColor: _C.textSecondary,
            labelStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700),
            unselectedLabelStyle: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.w400),
            indicatorColor: _C.primary,
            indicatorWeight: 2.5,
            tabs: TabAspirasi.values
                .map((t) => Tab(text: t.label))
                .toList(),
          ),
        ),

        // ---- LIST ----
        Expanded(
          child: Obx(() {
            if (ctrl.isLoading.value) {
              return const Center(
                  child: CircularProgressIndicator(color: _C.primary));
            }

            if (ctrl.displayedAspirasi.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.campaign_outlined,
                        size: 56, color: _C.textLight),
                    const SizedBox(height: 12),
                    const Text('Belum ada aspirasi di sini',
                        style: TextStyle(color: _C.textSecondary)),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: _C.primary,
              onRefresh: ctrl.onRefresh,
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                itemCount: ctrl.displayedAspirasi.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: _C.divider),
                itemBuilder: (context, index) {
                  final item = ctrl.displayedAspirasi[index];
                  return _AspirasiCard(
                    aspirasi: item,
                    isUpvoted: ctrl.isUpvoted(item),
                    isDownvoted: ctrl.isDownvoted(item),
                    onUpvote: () => ctrl.onUpvote(item.id),
                    onDownvote: () => ctrl.onDownvote(item.id),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ============================================================
// PAGE 2: FORM ASPIRASI
// ============================================================
class _AspirasiFormPage extends StatelessWidget {
  final AspirasiController ctrl;
  const _AspirasiFormPage({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---- JUDUL ----
            const SizedBox(height: 8),
            const Text(
              'Suara Mahasiswa',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: _C.textPrimary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tulis dan sampaikan aspirasi, kritik, atau saran Anda untuk perbaikan lingkungan akademik. Suara Anda adalah fondasi perubahan.',
              style: TextStyle(
                  fontSize: 13, color: _C.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 24),

            // ---- FORM CARD ----
            Container(
              decoration: BoxDecoration(
                color: _C.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _C.divider, width: 1),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label bagian
                  const Padding(
                    padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Text(
                      'DETAIL ASPIRASI',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _C.textLight,
                          letterSpacing: 1.2),
                    ),
                  ),

                  // ---- TEXT AREA ----
                  Obx(() => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: ctrl.isiSaranController,
                          maxLines: 8,
                          maxLength: AspirasiController.maxIsiSaranLength,
                          style: const TextStyle(
                              fontSize: 14, color: _C.textPrimary, height: 1.5),
                          decoration: InputDecoration(
                            hintText:
                                'Jelaskan aspirasi Anda secara detail dan konstruktif...',
                            hintStyle: const TextStyle(
                                color: _C.textLight, fontSize: 14),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            counterText: ctrl.isiSaranCounter,
                            counterStyle: const TextStyle(
                                fontSize: 11, color: _C.textLight),
                            errorText: ctrl.errorIsiSaran.value.isEmpty
                                ? null
                                : ctrl.errorIsiSaran.value,
                            errorStyle: const TextStyle(
                                fontSize: 11, color: _C.errorColor),
                          ),
                        ),
                      )),

                  const Divider(height: 1, color: _C.divider),

                  // ---- TOGGLE ANONYMOUS ----
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Obx(() => Switch(
                              value: ctrl.isAnonymous.value,
                              onChanged: ctrl.onToggleAnonymous,
                              activeColor: _C.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                            )),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Post as Anonymous',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: _C.textPrimary),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Identitas Anda akan disembunyikan.',
                                style: TextStyle(
                                    fontSize: 12, color: _C.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ---- TOMBOL HAPUS & POST ----
            Row(
              children: [
                // Hapus
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      onPressed: ctrl.onHapusForm,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _C.errorColor,
                        side: const BorderSide(color: _C.errorColor, width: 1.5),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text(
                        'Hapus',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Post Aspirasi
                Expanded(
                  flex: 2,
                  child: Obx(() => SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: ctrl.isSubmitting.value
                              ? null
                              : ctrl.onPostAspirasi,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _C.primary,
                            disabledBackgroundColor:
                                _C.primary.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            elevation: 1,
                          ),
                          child: ctrl.isSubmitting.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2),
                                )
                              : const Text(
                                  'Post Aspirasi',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600),
                                ),
                        ),
                      )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// WIDGET: Aspirasi Card (List Item)
// ============================================================
class _AspirasiCard extends StatelessWidget {
  final AspirasiModel aspirasi;
  final bool isUpvoted;
  final bool isDownvoted;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  const _AspirasiCard({
    required this.aspirasi,
    required this.isUpvoted,
    required this.isDownvoted,
    required this.onUpvote,
    required this.onDownvote,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---- HEADER: Avatar + Nama + Status ----
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: aspirasi.isAnonymous
                    ? _C.anonymousBg
                    : _C.avatarBg,
                child: aspirasi.isAnonymous
                    ? const Icon(Icons.person_outline_rounded,
                        color: _C.textSecondary, size: 20)
                    : Text(
                        aspirasi.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
              const SizedBox(width: 10),

              // Nama + Prodi + Waktu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aspirasi.isAnonymous
                          ? 'Anonim'
                          : (aspirasi.pelaporName ?? 'Mahasiswa JTK'),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _C.textPrimary),
                    ),
                    Text(
                      '${aspirasi.isAnonymous ? '' : '${aspirasi.pelaporProdi ?? ''} · '}${aspirasi.waktuRelatif}',
                      style: const TextStyle(
                          fontSize: 11, color: _C.textSecondary),
                    ),
                  ],
                ),
              ),

              // Badge status
              _StatusBadge(status: aspirasi.status),
            ],
          ),
          const SizedBox(height: 12),

          // ---- TOPIK ----
          Text(
            aspirasi.topik,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _C.textPrimary,
                height: 1.3),
          ),
          const SizedBox(height: 6),

          // ---- ISI SARAN ----
          Text(
            aspirasi.isiSaran,
            style: const TextStyle(
                fontSize: 13, color: _C.textSecondary, height: 1.55),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),

          // ---- TANGGAPAN ADMIN (jika ada) ----
          if (aspirasi.tanggapanJurusan != null) ...[
            const SizedBox(height: 12),
            _TanggapanAdmin(tanggapan: aspirasi.tanggapanJurusan!),
          ],

          const SizedBox(height: 14),

          // ---- VOTE BUTTONS ----
          Row(
            children: [
              _VoteButton(
                label: 'Up vote',
                icon: Icons.keyboard_arrow_up_rounded,
                count: aspirasi.upvoteCount,
                isActive: isUpvoted,
                activeColor: _C.upvoteActive,
                onTap: onUpvote,
              ),
              const SizedBox(width: 10),
              _VoteButton(
                label: 'Down Vote',
                icon: Icons.keyboard_arrow_down_rounded,
                count: aspirasi.downvoteCount,
                isActive: isDownvoted,
                activeColor: _C.downvoteActive,
                onTap: onDownvote,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET: Status Badge
// ============================================================
class _StatusBadge extends StatelessWidget {
  final StatusAspirasi status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case StatusAspirasi.responded:
        bgColor = _C.badgeSelesaiBg;
        textColor = _C.badgeSelesai;
        icon = Icons.check_circle_rounded;
        break;
      case StatusAspirasi.inReview:
        bgColor = _C.badgeProsesBg;
        textColor = _C.badgeProses;
        icon = Icons.hourglass_top_rounded;
        break;
      case StatusAspirasi.open:
        return const SizedBox.shrink(); // open tidak tampilkan badge
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700, color: textColor),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET: Tanggapan Admin Box
// ============================================================
class _TanggapanAdmin extends StatelessWidget {
  final String tanggapan;
  const _TanggapanAdmin({required this.tanggapan});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _C.tanggapanBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _C.tanggapanBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_rounded, size: 13, color: _C.primaryLight),
              SizedBox(width: 5),
              Text(
                'TANGGAPAN ADMIN JTK',
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: _C.primaryLight,
                    letterSpacing: 0.8),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '"$tanggapan"',
            style: const TextStyle(
                fontSize: 12,
                color: _C.textSecondary,
                height: 1.55,
                fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WIDGET: Vote Button
// ============================================================
class _VoteButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _VoteButton({
    required this.label,
    required this.icon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? activeColor : _C.voteInactive;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.08) : _C.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? color : _C.divider, width: 1.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 5),
            Text(
              count > 0 ? '$label  $count' : label,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isActive ? FontWeight.w700 : FontWeight.w500,
                  color: color),
            ),
          ],
        ),
      ),
    );
  }
}