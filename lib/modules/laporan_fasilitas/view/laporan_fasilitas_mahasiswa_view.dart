// lib/modules/laporan_fasilitas/view/laporan_fasilitas_mahasiswa_view.dart
// VERSI LENGKAP — semua patch sudah diterapkan ke file asli.

import 'dart:io';
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

  // ── PERUBAHAN 1: title teknisi -> "Laporan Kerusakan" ──
  String get _title {
    if (role == 'tu') return 'Cetak Laporan TU';
    if (role == 'teknisi' || role == 'petugas') return 'Laporan Kerusakan';
    return 'Laporan Fasilitas';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(
      InteraksiLaporanController(role: role),
      tag: 'laporan-$role',
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1A3A6B)),
            );
          }

          return RefreshIndicator(
            onRefresh: controller.fetchLaporan,
            color: const Color(0xFF1A3A6B),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: controller.listLaporan.length + 1,
              itemBuilder: (context, index) {
                // ── HEADER ──
                if (index == 0) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundColor: Color(0xFF1A2E40),
                                child: Icon(Icons.person, color: Colors.white),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  RichText(
                                    text: const TextSpan(
                                      text: 'Halo, ',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xFF1A3A6B),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Budi',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Text(
                                    'Mahasiswa JTK',
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.notifications_none_rounded,
                                color: Color(0xFF1A3A6B)),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _title,
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A3A6B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Laporakan kerusakan fasilitas yang ada dilingkungan Jurusan Teknik Komputer dan Informatika',
                        style: TextStyle(
                            fontSize: 13, color: Colors.black54, height: 1.4),
                      ),
                      const SizedBox(height: 16),

                      // ── PERUBAHAN 2: Sort chips khusus teknisi ──
                      if (role == 'teknisi' || role == 'petugas') ...[
                        _TeknisiSortBar(controller: controller),
                        const SizedBox(height: 12),
                      ] else
                        const SizedBox(height: 4),
                    ],
                  );
                }

                final laporan = controller.listLaporan[index - 1];
                final currentUserId = controller.currentUserId.value;
                final isUpvoted = laporan.upvoter_ids.contains(currentUserId);
                final isDownvoted =
                    laporan.downvoter_ids.contains(currentUserId);
                final String? fotoLaporanPath = laporan.foto_urls.isNotEmpty
                    ? laporan.foto_urls.first
                    : null;

                // ── CARD LAPORAN ──
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Vote arrows — hanya mahasiswa
                          if (controller.isMahasiswa)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.keyboard_arrow_up_rounded,
                                    color: isUpvoted
                                        ? Colors.orange
                                        : Colors.grey,
                                    size: 22,
                                  ),
                                  Text(
                                    '${laporan.vote_score}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Color(0xFF1A3A6B),
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: isDownvoted
                                        ? Colors.blue
                                        : Colors.grey,
                                    size: 22,
                                  ),
                                ],
                              ),
                            ),
                          if (controller.isMahasiswa)
                            const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatusChip(
                                    laporan.status, laporan.sudahDicetak),
                                const SizedBox(height: 10),

                                // Profil pelapor + menu
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 14,
                                            backgroundColor: const Color(
                                                    0xFF1A3A6B)
                                                .withOpacity(0.1),
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Ahmad Hidayat',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                Text(
                                                  'D4 Teknik Informatika • 2 jam lalu',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (controller.isMahasiswa)
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
                                            final laporCtrl = Get.put(
                                                LaporFasilitasController());
                                            laporCtrl.setupEditPage(laporan);
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) =>
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
                                              child: Text('Edit')),
                                          PopupMenuItem(
                                            value: 'delete',
                                            child: Text('Hapus',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Judul & lokasi
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
                                    const Icon(Icons.location_on_outlined,
                                        size: 14, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(laporan.lokasi,
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Foto
                                if (fotoLaporanPath != null) ...[
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: fotoLaporanPath.startsWith('http')
                                        ? Image.network(
                                            fotoLaporanPath,
                                            height: 160,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _buildImagePlaceholder(),
                                          )
                                        : Image.file(
                                            File(fotoLaporanPath),
                                            height: 160,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                _buildImagePlaceholder(),
                                          ),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                if (laporan.catatanPetugas?.isNotEmpty ==
                                    true) ...[
                                  Text(
                                    'Petugas: ${laporan.catatanPetugas}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontSize: 12, color: Colors.black87),
                                  ),
                                  const SizedBox(height: 12),
                                ],

                                // Vote buttons — mahasiswa
                                if (controller.isMahasiswa)
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              controller.upvoteLaporan(
                                                  currentUserId, index - 1),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isUpvoted
                                                ? Colors.orange.shade50
                                                : const Color(0xFFEFEFEF),
                                            foregroundColor: isUpvoted
                                                ? Colors.orange
                                                : Colors.black87,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                          ),
                                          icon: const Icon(
                                              Icons.arrow_upward_rounded,
                                              size: 16),
                                          label: const Text('Up vote',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              controller.downvoteLaporan(
                                                  currentUserId, index - 1),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: isDownvoted
                                                ? Colors.blue.shade50
                                                : const Color(0xFFEFEFEF),
                                            foregroundColor: isDownvoted
                                                ? Colors.blue
                                                : Colors.black87,
                                            elevation: 0,
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8)),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8),
                                          ),
                                          icon: const Icon(
                                              Icons.arrow_downward_rounded,
                                              size: 16),
                                          label: const Text('Down Vote',
                                              style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      ),
                                    ],
                                  ),

                                // ── PERUBAHAN 3: Ambil & Kerjakan — teknisi ──
                                if ((role == 'teknisi' || role == 'petugas') &&
                                    (laporan.teknisi_id == null ||
                                        laporan.teknisi_id!.isEmpty))
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () =>
                                            controller.ambilLaporan(laporan),
                                        icon: const Icon(
                                            Icons.engineering_rounded,
                                            size: 16),
                                        label: const Text('Ambil & Kerjakan',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w700)),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF1A3A6B),
                                          foregroundColor: Colors.white,
                                          elevation: 0,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8)),
                                        ),
                                      ),
                                    ),
                                  ),

                                // Info sudah diambil teknisi lain
                                if ((role == 'teknisi' || role == 'petugas') &&
                                    laporan.teknisi_id != null &&
                                    laporan.teknisi_id!.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Row(
                                      children: const [
                                        Icon(Icons.person_rounded,
                                            size: 13, color: Colors.grey),
                                        SizedBox(width: 4),
                                        Text(
                                          'Sedang dikerjakan teknisi lain',
                                          style: TextStyle(
                                              fontSize: 11, color: Colors.grey),
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
                  ),
                );
              },
            ),
          );
        }),
      ),
      floatingActionButton: role == 'mahasiswa'
          ? SizedBox(
              width: 56,
              height: 56,
              child: FloatingActionButton(
                onPressed: () async {
                  final changed = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LaporFasilitasView()),
                  );
                  if (changed == true) controller.fetchLaporan();
                },
                backgroundColor: const Color(0xFF1E78E6),
                shape: const CircleBorder(),
                elevation: 4,
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
            )
          : null,
    );
  }

  Widget _buildStatusChip(StatusLaporan status, bool printed) {
    final color = printed ? Colors.teal : const Color(0xFF1E78E6);
    final bg =
        printed ? const Color(0xFFE0F2F1) : const Color(0xFFE3F2FD);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            printed ? 'Selesai' : status.label,
            style: TextStyle(
                fontSize: 11, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
          color: Colors.grey[200], borderRadius: BorderRadius.circular(12)),
      child: const Center(
          child: Icon(Icons.broken_image_outlined,
              color: Colors.grey, size: 40)),
    );
  }
}

// ============================================================
// WIDGET: Sort Bar khusus teknisi
// ============================================================
class _TeknisiSortBar extends StatefulWidget {
  final InteraksiLaporanController controller;
  const _TeknisiSortBar({required this.controller});

  @override
  State<_TeknisiSortBar> createState() => _TeknisiSortBarState();
}

class _TeknisiSortBarState extends State<_TeknisiSortBar> {
  bool _isTopUpvote = true;

  void _toggle(bool topUpvote) {
    if (_isTopUpvote == topUpvote) return;
    setState(() => _isTopUpvote = topUpvote);
    widget.controller.sortLaporan(byUpvote: topUpvote);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _chip(
          label: 'Top Upvote',
          icon: Icons.arrow_upward_rounded,
          active: _isTopUpvote,
          onTap: () => _toggle(true),
        ),
        const SizedBox(width: 8),
        _chip(
          label: 'Terbaru',
          icon: Icons.schedule_rounded,
          active: !_isTopUpvote,
          onTap: () => _toggle(false),
        ),
      ],
    );
  }

  Widget _chip({
    required String label,
    required IconData icon,
    required bool active,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF1A3A6B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active
                ? const Color(0xFF1A3A6B)
                : const Color(0xFFDDE3EF),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 13,
                color: active ? Colors.white : const Color(0xFF6B7280)),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active ? Colors.white : const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }
}