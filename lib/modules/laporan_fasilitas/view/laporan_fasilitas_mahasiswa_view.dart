// lib/modules/laporan_fasilitas/view/laporan_fasilitas_mahasiswa_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/interaksi_laporan_controller.dart';
import '../controller/lapor_fasilitas_controller.dart'; // Dibutuhkan untuk fungsi edit
import '../model/laporan_fasilitas_model.dart';
import 'detail_laporan_fasilitas_view.dart';
import 'lapor_fasilitas_view.dart';

class LaporanFasilitasMahasiswaView extends StatelessWidget {
  const LaporanFasilitasMahasiswaView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller utama
    final controller = Get.put(InteraksiLaporanController());
    const String currentUserId =
        'user_dummy_123'; // Sesuaikan dengan session user nanti

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Laporan Fasilitas',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A3A6B),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            onSelected: (val) => controller.sortLaporan(val),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'vote', child: Text('Vote Terbanyak')),
              const PopupMenuItem(value: 'terbaru', child: Text('Terbaru')),
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

        // Pull-to-refresh untuk sinkronisasi data
        return RefreshIndicator(
          onRefresh: controller.fetchLaporan,
          color: const Color(0xFF1A3A6B),
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: controller.listLaporan.length,
            itemBuilder: (context, index) {
              final laporan = controller.listLaporan[index];
              final bool isUpvoted = laporan.upvoter_ids.contains(
                currentUserId,
              );
              final bool isDownvoted = laporan.downvoter_ids.contains(
                currentUserId,
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => Get.to(
                    () => DetailLaporanFasilitasView(
                      laporanId: laporan.id,
                      role: 'mahasiswa',
                    ),
                  ),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // BAGIAN ATAS: Informasi Laporan & Menu
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
                            // Menu Titik Tiga untuk Edit/Delete
                            PopupMenuButton<String>(
                              onSelected: (val) {
                                if (val == 'edit') {
                                  final laporCtrl = Get.put(
                                    LaporFasilitasController(),
                                  );
                                  laporCtrl.setupEditPage(laporan);
                                  Get.to(() => const LaporFasilitasView());
                                } else if (val == 'delete') {
                                  controller.deleteLaporan(laporan.id);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Edit'),
                                ),
                                const PopupMenuItem(
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
                        // BAGIAN BAWAH: Status & Interaksi Voting
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStatusChip(laporan.status),

                            // Kotak Voting dinamis
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0F4FA),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () => controller.upvoteLaporan(
                                      currentUserId,
                                      index,
                                    ),
                                    icon: Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 18,
                                      color: isUpvoted
                                          ? Colors.orange
                                          : Colors.grey,
                                    ),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                  Text(
                                    '${laporan.vote_score}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: (isUpvoted || isDownvoted)
                                          ? Colors.orange
                                          : Colors.black87,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => controller.downvoteLaporan(
                                      currentUserId,
                                      index,
                                    ),
                                    icon: Icon(
                                      Icons.arrow_downward_rounded,
                                      size: 18,
                                      color: isDownvoted
                                          ? Colors.blue
                                          : Colors.grey,
                                    ),
                                    constraints: const BoxConstraints(),
                                    padding: const EdgeInsets.all(8),
                                  ),
                                ],
                              ),
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
      // Tombol mengambang untuk lapor baru
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Get.to(() => const LaporFasilitasView()),
        backgroundColor: const Color(0xFF1A3A6B),
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: const Text(
          'Buat Laporan',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildStatusChip(StatusLaporan status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: const TextStyle(
          fontSize: 11,
          color: Color(0xFF1565C0),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
