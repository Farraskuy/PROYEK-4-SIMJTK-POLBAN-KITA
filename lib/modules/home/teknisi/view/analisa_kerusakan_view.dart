// lib/modules/teknisi/analisa_kerusakan/view/analisa_kerusakan_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import '../controller/analisa_kerusakan_controller.dart';
import '../model/analisa_kerusakan_model.dart';
import 'form_analisa_view.dart';

class AnalisaKerusakanView extends StatelessWidget {
  const AnalisaKerusakanView({super.key});

  static const Color _primary = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AnalisaKerusakanController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: _buildAppBar(ctrl, context),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _primary),
          );
        }
        return RefreshIndicator(
          color: _primary,
          onRefresh: ctrl.loadData,
          child: CustomScrollView(
            slivers: [
              // ── HEADER STATS & BANNER STATIS ──────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Tanggapan Tugas',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 24,
                          color: _primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Formulir Tanggapan Masalah Kerusakan — POLBAN',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      _buildStatsRow(ctrl),
                      const SizedBox(height: 12),

                      if (ctrl.laporanBelumDianalisa.isNotEmpty)
                        _buildStaticPendingBanner(ctrl),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // ── FILTER CHIPS & RUNNING TEXT DATA ──────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterChips(ctrl),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            '${ctrl.laporanBelumDianalisa.length} tugas baru, ${ctrl.filteredAnalisa.length} tanggapan terkirim',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          )),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // ── SEKSI 1: LIST TUGAS MENDESAK (BELUM DIRESPONS) ────────
              Obx(() {
                final pendingTasks = ctrl.laporanBelumDianalisa;
                if (pendingTasks.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return _PendingTaskCard(
                          task: pendingTasks[index],
                          ctrl: ctrl,
                        );
                      },
                      childCount: pendingTasks.length,
                    ),
                  ),
                );
              }),

              // ── SEKSI 2: RIWAYAT TANGGAPAN YANG SUDAH TERKIRIM ─────────
              Obx(() {
                final isEmpty = ctrl.filteredAnalisa.isEmpty && ctrl.laporanBelumDianalisa.isEmpty;
                
                if (isEmpty) {
                  return SliverFillRemaining(child: _buildEmpty());
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) => _AnalisaCard(
                        analisa: ctrl.filteredAnalisa[i],
                        formatRupiah: ctrl.formatRupiah,
                      ),
                      childCount: ctrl.filteredAnalisa.length,
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ctrl.resetForm();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FormAnalisaView()),
          );
        },
        backgroundColor: _primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Tambah Formulir',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AnalisaKerusakanController ctrl, BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _primary),
        onPressed: () => Navigator.pop(context),
      ),
      titleSpacing: 0,
      title: const Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: _primary,
            child: Icon(Icons.engineering, color: Colors.white, size: 18),
          ),
          SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Modul Teknisi',
                style: TextStyle(color: Colors.black, fontSize: 13, fontWeight: FontWeight.w700),
              ),
              Text(
                'Tanggapan Tugas',
                style: TextStyle(color: Colors.grey, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(AnalisaKerusakanController ctrl) {
    return Obx(() {
      final total = ctrl.analisaList.length;
      final berat = ctrl.analisaList.where((a) => a.tingkatKerusakan == TingkatKerusakan.berat || a.tingkatKerusakan == TingkatKerusakan.total).length;
      final pending = ctrl.laporanBelumDianalisa.length;

      return Row(
        children: [
          _StatChip(label: 'Total Formulir', count: total, color: _primary, icon: Icons.description_outlined),
          const SizedBox(width: 10),
          _StatChip(label: 'Kerusakan Berat', count: berat, color: Colors.red, icon: Icons.warning_amber_outlined),
          const SizedBox(width: 10),
          _StatChip(label: 'Belum Dianalisa', count: pending, color: Colors.orange, icon: Icons.pending_outlined),
        ],
      );
    });
  }

  Widget _buildStaticPendingBanner(AnalisaKerusakanController ctrl) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.orange.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.assignment_late_outlined, color: Colors.orange, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '${ctrl.laporanBelumDianalisa.length} laporan menunggu formulir analisa',
                style: const TextStyle(
                  color: Colors.orange,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips(AnalisaKerusakanController ctrl) {
    final filters = [
      {'key': 'semua', 'label': 'Semua'},
      {'key': 'hardware', 'label': 'Hardware'},
      {'key': 'software', 'label': 'Software'},
      {'key': 'jaringan', 'label': 'Jaringan'},
      {'key': 'instalasi', 'label': 'Instalasi'},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          return Obx(() {
            final isActive = ctrl.filterKategori.value == f['key'];
            return Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 8),
              child: GestureDetector(
                onTap: () => ctrl.filterKategori.value = f['key']!,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive ? _primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isActive ? _primary : Colors.grey.shade300),
                  ),
                  child: Text(
                    f['label']!,
                    style: TextStyle(
                      color: isActive ? Colors.white : Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            );
          });
        }).toList(),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.description_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('Belum ada tugas atau tanggapan', style: TextStyle(color: Colors.grey[400], fontSize: 14)),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$count',
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── KARTU TUGAS MENDESAK (100% MATCH DENGAN SCREENSHOT) ─────────────────────
class _PendingTaskCard extends StatelessWidget {
  final LaporanFasilitasModel task;
  final AnalisaKerusakanController ctrl;

  const _PendingTaskCard({required this.task, required this.ctrl});

  // Design Tokens menyelaraskan dengan Laporan Fasilitas View
  static const Color _primaryBlue = Color(0xFF1A3A6B);
  static const Color _borderCol = Color(0xFFDDE3EF);
  static const Color _textDark = Color(0xFF1A1A2E);
  static const Color _textGrey = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ctrl.resetForm();
        ctrl.setLaporan(task);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FormAnalisaView()),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderCol, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ikon Kotak Biru di Kiri (Sesuai Screenshot)
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _primaryBlue.withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Icon(
                  Icons.assignment_outlined,
                  color: _primaryBlue,
                  size: 24,
                ),
              ),
            ),
            const SizedBox(width: 14),
            
            // Konten Kanan
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    task.judul,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  
                  // Lokasi
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 14, color: _textGrey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          task.lokasi,
                          style: const TextStyle(color: _textGrey, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Baris Bawah: Tanggal & Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Tanggal (Kiri Bawah)
                      Text(
                        _formatDate(task.createdAt),
                        style: const TextStyle(
                          color: _textGrey, 
                          fontSize: 12, 
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      
                      // Badge Status & Upvote (Kanan Bawah)
                      Row(
                        children: [
                          _buildStatusBadge(task.status.toString()),
                          const SizedBox(width: 6),
                          _buildVoteBadge(task.vote_score ?? 0),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Tanggal ke format dd/MM/yyyy
  String _formatDate(dynamic date) {
    if (date == null) return '-';
    DateTime dt;
    if (date is DateTime) {
      dt = date;
    } else {
      dt = DateTime.tryParse(date.toString()) ?? DateTime.now();
    }
    
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  // Helper Status Badge (Warna identik dengan screenshot)
  Widget _buildStatusBadge(String statusRaw) {
    final s = statusRaw.toLowerCase();
    String text = 'Terkirim';
    Color bg = Colors.green.shade50;
    Color fg = Colors.green.shade700;

    if (s.contains('tolak') || s.contains('reject')) {
      text = 'Ditolak';
      bg = Colors.red.shade50;
      fg = Colors.red.shade700;
    } else if (s.contains('progress') || s.contains('proses')) {
      text = 'Diproses';
      bg = Colors.orange.shade50;
      fg = Colors.orange.shade800;
    } else if (s.contains('selesai') || s.contains('resolve')) {
      text = 'Selesai';
      bg = Colors.blue.shade50;
      fg = Colors.blue.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  // Helper Upvote Badge
  Widget _buildVoteBadge(int votes) {
    final bool isPositive = votes >= 0;
    final Color bg = isPositive ? Colors.green.shade50 : Colors.red.shade50;
    final Color fg = isPositive ? Colors.green.shade700 : Colors.red.shade700;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        children: [
          Icon(
            isPositive ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 12,
            color: fg,
          ),
          const SizedBox(width: 4),
          Text(
            '${votes.abs()}',
            style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

// ── KARTU RIWAYAT TANGGAPAN (DISELARASKAN DENGAN DESIGN SYSTEM BARU) ────────
class _AnalisaCard extends StatelessWidget {
  final AnalisaKerusakanModel analisa;
  final String Function(double?) formatRupiah;

  const _AnalisaCard({required this.analisa, required this.formatRupiah});

  static const Color _primaryBlue = Color(0xFF1A3A6B);
  static const Color _borderCol = Color(0xFFDDE3EF);
  static const Color _textDark = Color(0xFF1A1A2E);

  @override
  Widget build(BuildContext context) {
    final tingkatColor = _tingkatColor(analisa.tingkatKerusakan);
    final isCritical = analisa.tingkatKerusakan == TingkatKerusakan.total ||
                       analisa.tingkatKerusakan == TingkatKerusakan.berat;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCritical ? Colors.red.withOpacity(0.4) : _borderCol, 
          width: isCritical ? 1.5 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER KARTU (Layout disamakan dengan Laporan Card)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(Icons.build_circle_outlined, color: Colors.grey, size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        analisa.namaAlat,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: _textDark),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.qr_code, size: 12, color: Colors.grey.shade500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${analisa.kodeAlat} • ${analisa.noInventaris}',
                              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: tingkatColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              analisa.tingkatKerusakan.label,
                              style: TextStyle(color: tingkatColor, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                            child: Text(
                              analisa.kategoriKerusakan.label,
                              style: const TextStyle(color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w600),
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
          
          // PEMBATAS
          Divider(height: 1, color: Colors.grey.shade200),

          // ISI TANGGAPAN
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionInfo('TANGGAPAN MASALAH', analisa.analisaMasalah),
                const SizedBox(height: 12),
                _buildSectionInfo('REKOMENDASI PERBAIKAN', analisa.rekomendasiPerbaikan),
                const SizedBox(height: 16),
                
                // BARIS BAWAH: Meta Info & Sync
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _SyncBadge(status: analisa.syncStatus),
                        const SizedBox(width: 10),
                        Text(
                          _fmtDate(analisa.createdAt),
                          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                        ),
                      ],
                    ),
                    if (analisa.estimasiBiaya != null)
                      Text(
                        formatRupiah(analisa.estimasiBiaya),
                        style: const TextStyle(
                          color: _primaryBlue,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionInfo(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(color: Colors.grey.shade700, fontSize: 12, height: 1.4),
        ),
      ],
    );
  }

  Color _tingkatColor(TingkatKerusakan t) {
    switch (t) {
      case TingkatKerusakan.ringan: return Colors.green;
      case TingkatKerusakan.sedang: return Colors.orange;
      case TingkatKerusakan.berat: return Colors.red;
      case TingkatKerusakan.total: return Colors.red.shade900;
    }
  }

  Color _kategoriColor(KategoriKerusakan k) {
    switch (k) {
      case KategoriKerusakan.hardware: return Colors.blue;
      case KategoriKerusakan.software: return Colors.purple;
      case KategoriKerusakan.jaringan: return Colors.teal;
      case KategoriKerusakan.instalasi: return Colors.orange;
      case KategoriKerusakan.lainnya: return Colors.grey;
    }
  }

  String _fmtDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

// ── SYNC BADGE CLOUD STATE ───────────────────────────────────────────────────
class _SyncBadge extends StatelessWidget {
  final String status;
  const _SyncBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final isSynced = status == 'synced';
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isSynced ? Icons.cloud_done_outlined : Icons.cloud_off_outlined,
          size: 14,
          color: isSynced ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 4),
        Text(
          isSynced ? 'Tersinkron' : 'Lokal',
          style: TextStyle(
            fontSize: 10,
            color: isSynced ? Colors.green : Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}