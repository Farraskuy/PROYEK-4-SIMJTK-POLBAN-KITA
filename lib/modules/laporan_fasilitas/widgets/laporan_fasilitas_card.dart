import 'dart:io';

import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_status_chip.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_vote_column.dart';

class LaporanFasilitasCard extends StatelessWidget {
  final LaporanFasilitasModel laporan;
  final String currentUserId;
  final bool showVoteColumn;
  final bool showActions;
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

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
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
                  onUpvote: onUpvote,
                  onDownvote: onDownvote,
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
                                backgroundColor: const Color(
                                  0xFF1A3A6B,
                                ).withValues(alpha: 0.1),
                                child: const Text(
                                  'AH',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A3A6B),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Ahmad Hidayat',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      'D4 Teknik Informatika • 2 jam lalu',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (showActions)
                          PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(
                              Icons.more_vert_rounded,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onSelected: (val) {
                              if (val == 'edit') {
                                onEdit?.call();
                              } else if (val == 'delete') {
                                onDelete?.call();
                              }
                            },
                            itemBuilder: (context) => const [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text(
                                  'Hapus',
                                  style: TextStyle(color: Colors.red),
                                ),
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
                        fontSize: 18,
                        color: Color(0xFF1A3A6B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            laporan.lokasi,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (fotoLaporanPath != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: LaporanFasilitasImage(
                          imagePath: fotoLaporanPath,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (laporan.catatanPetugas?.isNotEmpty == true) ...[
                      Text(
                        'Petugas: ${laporan.catatanPetugas}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (showVoteColumn)
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: onUpvote,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isUpvoted
                                    ? Colors.orange.shade50
                                    : const Color(0xFFEFEFEF),
                                foregroundColor: isUpvoted
                                    ? Colors.orange
                                    : Colors.black87,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              icon: const Icon(
                                Icons.arrow_upward_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                'Up vote',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: onDownvote,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isDownvoted
                                    ? Colors.blue.shade50
                                    : const Color(0xFFEFEFEF),
                                foregroundColor: isDownvoted
                                    ? Colors.blue
                                    : Colors.black87,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                              ),
                              icon: const Icon(
                                Icons.arrow_downward_rounded,
                                size: 16,
                              ),
                              label: const Text(
                                'Down Vote',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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

class LaporanFasilitasImage extends StatelessWidget {
  final String imagePath;

  const LaporanFasilitasImage({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return imagePath.startsWith('http')
        ? Image.network(
            imagePath,
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
          )
        : Image.file(
            File(imagePath),
            height: 160,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => const _ImagePlaceholder(),
          );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      width: double.infinity,
      color: Colors.grey[200],
      child: const Center(
        child: Icon(Icons.broken_image_outlined, color: Colors.grey, size: 40),
      ),
    );
  }
}
