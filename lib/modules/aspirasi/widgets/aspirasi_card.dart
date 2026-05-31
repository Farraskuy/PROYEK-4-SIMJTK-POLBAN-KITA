import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_vote_column.dart';

class AspirasiCard extends StatelessWidget {
  const AspirasiCard({
    super.key,
    required this.aspirasi,
    required this.isUpvoted,
    required this.isDownvoted,
    this.showActions = false,
    this.showVoteButtons = true,
    this.showVoteColumn = true,
    this.onEdit,
    this.onDelete,
    required this.onUpvote,
    required this.onDownvote,
    required this.onTap,
  });

  final AspirasiModel aspirasi;
  final bool isUpvoted;
  final bool isDownvoted;
  final bool showActions;
  final bool showVoteButtons;
  final bool showVoteColumn;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final overallVote = aspirasi.upvoteCount - aspirasi.downvoteCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kolom Vote Kiri (100% Identik dengan Laporan Fasilitas)
              if (showVoteColumn) ...[
                LaporanFasilitasVoteColumn(
                  voteScore: overallVote,
                  isUpvoted: isUpvoted,
                  isDownvoted: isDownvoted,
                  onUpvote: showVoteButtons ? onUpvote : () {},
                  onDownvote: showVoteButtons ? onDownvote : () {},
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Status Chip di bagian paling atas (Sama persis seperti LaporanFasilitasCard)
                    _AspirasiStatusBadge(status: aspirasi.status),
                    const SizedBox(height: 10),

                    // 2. Baris data pelapor (Sama persis seperti LaporanFasilitasCard)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: AppColors.primary.withOpacity(0.1),
                                child: Text(
                                  aspirasi.initials.toUpperCase(),
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      aspirasi.pelaporName ?? 'Mahasiswa JTK',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.title,
                                        fontFamily: 'Poppins',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      '${aspirasi.pelaporProdi ?? 'D4 Teknik Informatika'} • ${aspirasi.waktuRelatif}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.body,
                                        fontFamily: 'Poppins',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (showActions && (onEdit != null || onDelete != null))
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (onEdit != null)
                                IconButton(
                                  onPressed: onEdit,
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    size: 20,
                                    color: AppColors.primary,
                                  ),
                                  tooltip: 'Edit',
                                ),
                              const SizedBox(width: 6),
                              if (onDelete != null)
                                IconButton(
                                  onPressed: onDelete,
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    size: 20,
                                    color: AppColors.danger,
                                  ),
                                  tooltip: 'Hapus',
                                ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // 3. Judul / Topik
                    Text(
                      aspirasi.topik,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                        height: 1.25,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 4. Deskripsi / Isi
                    Text(
                      aspirasi.isiSaran,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.body,
                        height: 1.55,
                        fontFamily: 'Poppins',
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),

                    if (aspirasi.tanggapanJurusan != null) ...[
                      const SizedBox(height: 12),
                      _AspirasiTanggapanBox(tanggapan: aspirasi.tanggapanJurusan!),
                    ],

                    if (showVoteButtons) ...[
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: _VoteButton(
                              label: 'Up vote',
                              icon: Icons.keyboard_arrow_up_rounded,
                              count: aspirasi.upvoteCount,
                              isActive: isUpvoted,
                              activeColor: AppColors.primary,
                              onTap: onUpvote,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _VoteButton(
                              label: 'Down Vote',
                              icon: Icons.keyboard_arrow_down_rounded,
                              count: aspirasi.downvoteCount,
                              isActive: isDownvoted,
                              activeColor: AppColors.danger,
                              onTap: onDownvote,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AspirasiStatusBadge extends StatelessWidget {
  const _AspirasiStatusBadge({required this.status});

  final StatusAspirasi status;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case StatusAspirasi.open:
        bg = AppColors.blueSoft;
        fg = AppColors.primary;
        label = 'Terbuka';
        icon = Icons.info_outline_rounded;
        break;
      case StatusAspirasi.inReview:
        bg = AppColors.orangeSoft;
        fg = AppColors.warning;
        label = 'Diproses';
        icon = Icons.hourglass_top_rounded;
        break;
      case StatusAspirasi.responded:
        bg = AppColors.greenSoft;
        fg = AppColors.success;
        label = 'Selesai';
        icon = Icons.check_circle_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20), // 20px border radius for chip consistency
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: fg),
          const SizedBox(width: 4),
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: fg,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _AspirasiTanggapanBox extends StatelessWidget {
  const _AspirasiTanggapanBox({required this.tanggapan});

  final String tanggapan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.verified_rounded, size: 13, color: AppColors.primary),
              SizedBox(width: 5),
              Text(
                'TANGGAPAN JURUSAN',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                  letterSpacing: 0.8,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            tanggapan,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.body,
              height: 1.5,
              fontStyle: FontStyle.italic,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _VoteButton extends StatelessWidget {
  const _VoteButton({
    required this.label,
    required this.icon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUpvote = label.toLowerCase().contains('up');
    final color = isUpvote ? AppColors.primary : AppColors.danger;
    final bgColor = isActive ? color : color.withOpacity(0.06);
    final borderColor = isActive ? color : color.withOpacity(0.3);
    final textColor = isActive ? Colors.white : color;
    final iconColor = isActive ? Colors.white : color;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: 4),
              Text(
                '$label ${count.toString()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color: textColor,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
