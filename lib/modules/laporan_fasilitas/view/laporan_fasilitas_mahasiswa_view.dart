// lib/modules/laporan_fasilitas/view/laporan_fasilitas_mahasiswa_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/interaksi_laporan_controller.dart';
import '../controller/lapor_fasilitas_controller.dart';
import '../model/laporan_fasilitas_model.dart';
import 'detail_laporan_fasilitas_view.dart';
import 'lapor_fasilitas_view.dart';

class LaporanFasilitasMahasiswaView extends StatelessWidget {
  const LaporanFasilitasMahasiswaView({super.key, this.role = 'mahasiswa'});

  final String role;

  String get _title {
    if (role == 'tu') return 'Cetak Laporan TU';
    if (role == 'teknisi' || role == 'petugas') return 'Tanggapan Laporan';
    return 'Laporan Fasilitas';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      InteraksiLaporanController(role: role),
      tag: 'laporan-$role',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          _title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3A6B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) => controller.sortLaporan(val),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'vote', child: Text('Vote Terbanyak')),
              PopupMenuItem(value: 'terbaru', child: Text('Terbaru')),
            ],
            icon: const Icon(Icons.sort_rounded, color: Color(0xFF1A3A6B)),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF1A3A6B)),
          );
        }

        if (controller.listLaporan.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.fetchLaporan,
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: const [
                SizedBox(height: 120),
                Icon(Icons.inbox_outlined, size: 56, color: Colors.grey),
                SizedBox(height: 12),
                Center(child: Text('Belum ada laporan untuk role ini.')),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.fetchLaporan,
          color: const Color(0xFF1A3A6B),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.listLaporan.length,
            itemBuilder: (context, index) {
              final laporan = controller.listLaporan[index];
              final currentUserId = controller.currentUserId.value;
              final isUpvoted = laporan.upvoter_ids.contains(currentUserId);
              final isDownvoted = laporan.downvoter_ids.contains(currentUserId);

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () async {
                    final changed = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DetailLaporanFasilitasView(
                          laporanId: laporan.id,
                          role: role,
                        ),
                      ),
                    );
                    if (changed == true) controller.fetchLaporan();
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    laporan.judul,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF1A1A2E),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    laporan.lokasi,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (controller.isMahasiswa)
                              PopupMenuButton<String>(
                                onSelected: (val) {
                                  if (val == 'edit') {
                                    final laporCtrl = Get.put(
                                      LaporFasilitasController(),
                                    );
                                    laporCtrl.setupEditPage(laporan);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const LaporFasilitasView(),
                                      ),
                                    );
                                  } else if (val == 'delete') {
                                    controller.deleteLaporan(laporan.id);
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
                        const SizedBox(height: 8),
                        if (laporan.catatanPetugas?.isNotEmpty == true)
                          Text(
                            'Petugas: ${laporan.catatanPetugas}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12),
                          ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusChip(
                              laporan.status,
                              laporan.sudahDicetak,
                            ),
                            if (controller.isMahasiswa)
                              _VoteBox(
                                score: laporan.vote_score,
                                isUpvoted: isUpvoted,
                                isDownvoted: isDownvoted,
                                onUpvote: () => controller.upvoteLaporan(
                                  currentUserId,
                                  index,
                                ),
                                onDownvote: () => controller.downvoteLaporan(
                                  currentUserId,
                                  index,
                                ),
                              )
                            else
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: Colors.grey,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      }),
      floatingActionButton: role == 'mahasiswa'
          ? FloatingActionButton.extended(
              onPressed: () async {
                final changed = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LaporFasilitasView(),
                  ),
                );
                if (changed == true) controller.fetchLaporan();
              },
              backgroundColor: const Color(0xFF1A3A6B),
              icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
              label: const Text(
                'Buat Laporan',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Widget _buildStatusChip(StatusLaporan status, bool printed) {
    final color = printed ? Colors.green : const Color(0xFF1565C0);
    final bg = printed ? const Color(0xFFE8F5E9) : const Color(0xFFE3F2FD);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        printed ? 'Sudah Dicetak' : status.label,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _VoteBox extends StatelessWidget {
  const _VoteBox({
    required this.score,
    required this.isUpvoted,
    required this.isDownvoted,
    required this.onUpvote,
    required this.onDownvote,
  });

  final int score;
  final bool isUpvoted;
  final bool isDownvoted;
  final VoidCallback onUpvote;
  final VoidCallback onDownvote;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FA),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onUpvote,
            icon: Icon(
              Icons.arrow_upward_rounded,
              size: 18,
              color: isUpvoted ? Colors.orange : Colors.grey,
            ),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
          Text(
            '$score',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: (isUpvoted || isDownvoted)
                  ? Colors.orange
                  : Colors.black87,
            ),
          ),
          IconButton(
            onPressed: onDownvote,
            icon: Icon(
              Icons.arrow_downward_rounded,
              size: 18,
              color: isDownvoted ? Colors.blue : Colors.grey,
            ),
            constraints: const BoxConstraints(),
            padding: const EdgeInsets.all(8),
          ),
        ],
      ),
    );
  }
}
