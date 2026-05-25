import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

class AspirasiCard extends StatelessWidget {
  const AspirasiCard({
    super.key,
    required this.aspirasi,
    required this.isUpvoted,
    required this.isDownvoted,
    this.showActions = false,
    this.onEdit,
    this.onDelete,
    required this.onUpvote,
    required this.onDownvote,
  });

  final AspirasiModel aspirasi;
  final bool isUpvoted;
  final bool isDownvoted;
  final bool showActions;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: aspirasi.isAnonymous
                    ? AppColors.border
                    : AppColors.primary,
                child: aspirasi.isAnonymous
                    ? const Icon(
                        Icons.person_outline_rounded,
                        color: AppColors.body,
                        size: 20,
                      )
                    : Text(
                        aspirasi.initials,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
              const SizedBox(width: 10),
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
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${aspirasi.isAnonymous ? '' : '${aspirasi.pelaporProdi ?? ''} · '}${aspirasi.waktuRelatif}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.body,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _AspirasiStatusBadge(status: aspirasi.status),
                  if (showActions) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: onEdit,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          tooltip: 'Edit',
                        ),
                        const SizedBox(width: 6),
                        IconButton(
                          onPressed: onDelete,
                          constraints: const BoxConstraints(),
                          padding: EdgeInsets.zero,
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: AppColors.danger,
                          ),
                          tooltip: 'Hapus',
                        ),
                      ],
                    ),
                    
                  ],
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            aspirasi.topik,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.title,
              height: 1.25,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            aspirasi.isiSaran,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.body,
              height: 1.55,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
          if (aspirasi.tanggapanJurusan != null) ...[
            const SizedBox(height: 12),
            _AspirasiTanggapanBox(tanggapan: aspirasi.tanggapanJurusan!),
          ],
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
      ),
    );
  }
}

class _AspirasiStatusBadge extends StatelessWidget {
  const _AspirasiStatusBadge({required this.status});

  final StatusAspirasi status;

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case StatusAspirasi.open:
        return const SizedBox.shrink();
      case StatusAspirasi.inReview:
        return const _Badge(
          label: 'Diproses',
          icon: Icons.hourglass_top_rounded,
          backgroundColor: AppColors.blueSoft,
          foregroundColor: AppColors.primary,
        );
      case StatusAspirasi.responded:
        return const _Badge(
          label: 'Selesai',
          icon: Icons.check_circle_rounded,
          backgroundColor: AppColors.greenSoft,
          foregroundColor: AppColors.success,
        );
    }
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String label;
  final IconData icon;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: foregroundColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: foregroundColor,
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
    final color = isActive ? activeColor : AppColors.muted;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.08) : AppColors.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isActive ? color : AppColors.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 4),
              Text(
                '$label ${count.toString()}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
