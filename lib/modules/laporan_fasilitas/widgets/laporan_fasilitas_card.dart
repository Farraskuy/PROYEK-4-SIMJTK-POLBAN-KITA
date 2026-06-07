import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_status_chip.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_vote_column.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_report_image.dart';

class LaporanFasilitasCard extends StatelessWidget {
  final LaporanFasilitasModel laporan;
  final String currentUserId;
  final bool showVoteColumn;
  final bool showActions;
  final bool showVoteButtons;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  const LaporanFasilitasCard({
    super.key,
    required this.laporan,
    required this.currentUserId,
    required this.showVoteColumn,
    required this.showActions,
    this.showVoteButtons = true,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onUpvote,
    required this.onDownvote,
  });

  @override
  Widget build(BuildContext context) {
    final isUpvoted = laporan.upvoter_ids.contains(currentUserId);
    final isDownvoted = laporan.downvoter_ids.contains(currentUserId);
    final fotoLaporanPath = laporan.foto_urls.isNotEmpty
        ? laporan.foto_urls.first
        : null;

    final initials = laporan.pelapor_nama.isNotEmpty
        ? (laporan.pelapor_nama.trim().split(' ').length >= 2
            ? '${laporan.pelapor_nama.trim().split(' ')[0][0]}${laporan.pelapor_nama.trim().split(' ')[1][0]}'
            : laporan.pelapor_nama[0])
        : '?';

    return Container(
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
              if (showVoteColumn)
                LaporanFasilitasVoteColumn(
                  voteScore: laporan.vote_score,
                  isUpvoted: isUpvoted,
                  isDownvoted: isDownvoted,
                  onUpvote: showVoteButtons ? onUpvote : () {},
                  onDownvote: showVoteButtons ? onDownvote : () {},
                ),
              if (showVoteColumn) const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LaporanFasilitasStatusChip(
                      status: laporan.status,
                      printed: laporan.sudahDicetak,
                    ),
                    const SizedBox(height: 10),
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
                                  initials.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
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
                                      laporan.pelapor_nama.isNotEmpty
                                          ? laporan.pelapor_nama
                                          : 'Mahasiswa JTK',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                        color: AppColors.title,
                                        fontFamily: 'Poppins',
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'D4 Teknik Informatika • ${_getWaktuRelatif(laporan.createdAt)}',
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
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.edit_outlined,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                  tooltip: 'Edit',
                                ),
                              const SizedBox(width: 6),
                              if (onDelete != null)
                                IconButton(
                                  onPressed: onDelete,
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: AppColors.danger,
                                    size: 20,
                                  ),
                                  tooltip: 'Hapus',
                                ),
                            ],
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      laporan.judul,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.title,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: AppColors.body,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            laporan.lokasi,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.body,
                              fontFamily: 'Poppins',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: LaporanFasilitasImage(
                        imagePath: fotoLaporanPath,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (laporan.catatanPetugas?.isNotEmpty == true) ...[
                      Text(
                        'Petugas: ${laporan.catatanPetugas}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.body,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (showVoteButtons) ...[
                      Row(
                        children: [
                          Expanded(
                            child: _VoteButton(
                              label: 'Up vote',
                              icon: Icons.keyboard_arrow_up_rounded,
                              count: laporan.upvoter_ids.length,
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
                              count: laporan.downvoter_ids.length,
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

  String _getWaktuRelatif(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}

class LaporanFasilitasImage extends StatelessWidget {
  final String? imagePath;

  const LaporanFasilitasImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return AppReportImage(source: imagePath, height: 160);
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
