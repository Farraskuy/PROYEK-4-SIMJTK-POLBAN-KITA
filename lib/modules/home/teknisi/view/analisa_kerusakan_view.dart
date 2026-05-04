// lib/modules/teknisi/analisa_kerusakan/view/analisa_kerusakan_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      appBar: _buildAppBar(ctrl),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
              child: CircularProgressIndicator(color: _primary));
        }
        return RefreshIndicator(
          color: _primary,
          onRefresh: ctrl.loadData,
          child: CustomScrollView(
            slivers: [
              // ── Header stats ────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analisa Masalah',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: _primary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Diagnosa teknis terhadap barang yang rusak',
                        style: TextStyle(
                            color: Colors.grey[500], fontSize: 13),
                      ),
                      const SizedBox(height: 16),
                      _buildStatsRow(ctrl),
                      const SizedBox(height: 12),

                      // Banner laporan belum dianalisa
                      if (ctrl.laporanBelumDianalisa.isNotEmpty)
                        _buildPendingBanner(ctrl),
                      const SizedBox(height: 8),

                      // Filter chips
                      _buildFilterChips(ctrl),
                      const SizedBox(height: 4),
                      Obx(() => Text(
                            '${ctrl.filteredAnalisa.length} analisa ditemukan',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12),
                          )),
                    ],
                  ),
                ),
              ),

              // ── List analisa ────────────────────────────────────────
              Obx(() => ctrl.filteredAnalisa.isEmpty
                  ? SliverFillRemaining(child: _buildEmpty())
                  : SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => _AnalisaCard(
                            analisa: ctrl.filteredAnalisa[i],
                          ),
                          childCount: ctrl.filteredAnalisa.length,
                        ),
                      ),
                    )),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ctrl.resetForm();
          Get.to(() => const FormAnalisaView());
        },
        backgroundColor: _primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Analisa',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600)),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(AnalisaKerusakanController ctrl) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: _primary),
        onPressed: () => Get.back(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: _primary,
            child: Icon(Icons.engineering, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Modul Teknisi',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 13,
                      fontWeight: FontWeight.w700)),
              Text('Analisa Kerusakan',
                  style: TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ],
      ),
      actions: [
        Obx(() {
          final pending = ctrl.laporanBelumDianalisa.length;
          return Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined,
                    color: Colors.black),
                onPressed: () {},
              ),
              if (pending > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                        color: Colors.red, shape: BoxShape.circle),
                    child: Center(
                      child: Text('$pending',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold)),
                    ),
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildStatsRow(AnalisaKerusakanController ctrl) {
    return Obx(() {
      final total = ctrl.analisaList.length;
      final berat = ctrl.analisaList
          .where((a) =>
              a.tingkatKerusakan == TingkatKerusakan.berat ||
              a.tingkatKerusakan == TingkatKerusakan.total)
          .length;
      final pending = ctrl.laporanBelumDianalisa.length;

      return Row(
        children: [
          _StatChip(
              label: 'Total Analisa',
              count: total,
              color: _primary,
              icon: Icons.analytics_outlined),
          const SizedBox(width: 10),
          _StatChip(
              label: 'Kerusakan Berat',
              count: berat,
              color: Colors.red,
              icon: Icons.warning_amber_outlined),
          const SizedBox(width: 10),
          _StatChip(
              label: 'Belum Dianalisa',
              count: pending,
              color: Colors.orange,
              icon: Icons.pending_outlined),
        ],
      );
    });
  }

  Widget _buildPendingBanner(AnalisaKerusakanController ctrl) {
    return Obx(() => GestureDetector(
          onTap: () {
            ctrl.resetForm();
            Get.to(() => const FormAnalisaView());
          },
          child: Container(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: Colors.orange.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.assignment_late_outlined,
                    color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${ctrl.laporanBelumDianalisa.length} laporan menunggu analisa teknis',
                    style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 13, color: Colors.orange),
              ],
            ),
          ),
        ));
  }

  Widget _buildFilterChips(AnalisaKerusakanController ctrl) {
    final filters = [
      {'key': 'semua', 'label': 'Semua'},
      {'key': 'hardware', 'label': 'Hardware'},
      {'key': 'software', 'label': 'Software'},
      {'key': 'jaringan', 'label': 'Jaringan'},
      {'key': 'instalasi', 'label': 'Instalasi'},
    ];

    return Obx(() => SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: filters.map((f) {
              final isActive = ctrl.filterKategori.value == f['key'];
              return Padding(
                padding: const EdgeInsets.only(right: 8, bottom: 8),
                child: GestureDetector(
                  onTap: () =>
                      ctrl.filterKategori.value = f['key']!,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isActive ? _primary : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color:
                              isActive ? _primary : Colors.grey.shade300),
                    ),
                    child: Text(
                      f['label']!,
                      style: TextStyle(
                          color: isActive ? Colors.white : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ));
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text('Belum ada analisa kerusakan',
              style: TextStyle(color: Colors.grey[400], fontSize: 14)),
          const SizedBox(height: 4),
          Text('Ketuk tombol + untuk menambahkan',
              style: TextStyle(color: Colors.grey[400], fontSize: 12)),
        ],
      ),
    );
  }
}

// ── Stat Chip ─────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  final IconData icon;

  const _StatChip(
      {required this.label,
      required this.count,
      required this.color,
      required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$count',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: color)),
                  Text(label,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 9),
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Analisa Card ──────────────────────────────────────────────────────────────

class _AnalisaCard extends StatelessWidget {
  final AnalisaKerusakanModel analisa;

  const _AnalisaCard({required this.analisa});

  static const Color _primary = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    final tingkatColor = _tingkatColor(analisa.tingkatKerusakan);
    final kategoriColor = _kategoriColor(analisa.kategoriKerusakan);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: analisa.tingkatKerusakan == TingkatKerusakan.total ||
                analisa.tingkatKerusakan == TingkatKerusakan.berat
            ? Border.all(color: Colors.red.withOpacity(0.2), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3)),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: kategori + tingkat kerusakan
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: kategoriColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(analisa.kategoriKerusakan.label,
                      style: TextStyle(
                          color: kategoriColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
                const Spacer(),
                // Tingkat kerusakan badge
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 9, vertical: 4),
                  decoration: BoxDecoration(
                    color: tingkatColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: tingkatColor.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.circle, size: 6, color: tingkatColor),
                      const SizedBox(width: 4),
                      Text(analisa.tingkatKerusakan.label,
                          style: TextStyle(
                              color: tingkatColor,
                              fontSize: 10,
                              fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // ID
            Text(
              '#ANA-${analisa.id.substring(analisa.id.length > 8 ? analisa.id.length - 8 : 0).toUpperCase()}',
              style: const TextStyle(
                  color: Colors.grey, fontSize: 10, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 4),

            // Judul laporan
            Text(analisa.judulLaporan,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: _primary)),
            const SizedBox(height: 6),

            // Diagnosa singkat
            Text(
              analisa.diagnosaMasalah,
              style: TextStyle(
                  color: Colors.grey[500], fontSize: 12, height: 1.4),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            // Meta info row
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                _metaItem(Icons.location_on_outlined,
                    analisa.lokasiLaporan),
                _metaItem(Icons.build_outlined,
                    'Komponen: ${analisa.komponenRusak}'),
                if (analisa.estimasiWaktuPerbaikanHari != null)
                  _metaItem(Icons.schedule_outlined,
                      '${analisa.estimasiWaktuPerbaikanHari} hari'),
                if (analisa.estimasiBiaya != null)
                  _metaItem(
                    Icons.payments_outlined,
                    _formatRupiah(analisa.estimasiBiaya!),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Tindakan rekomendasi
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.04),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _primary.withOpacity(0.1)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.recommend_outlined,
                      size: 14, color: _primary),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      analisa.tindakanDirekomendasikan,
                      style: const TextStyle(
                          fontSize: 12,
                          color: _primary,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Sync status + tanggal
            Row(
              children: [
                _SyncBadge(status: analisa.syncStatus),
                const Spacer(),
                Text(
                  _fmtDate(analisa.createdAt),
                  style: const TextStyle(
                      color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey),
        const SizedBox(width: 3),
        Text(text,
            style: const TextStyle(color: Colors.grey, fontSize: 11),
            overflow: TextOverflow.ellipsis),
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

  String _formatRupiah(double val) {
    final s = val.toStringAsFixed(0);
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      if (count > 0 && count % 3 == 0) buf.write('.');
      buf.write(s[i]);
      count++;
    }
    return 'Rp ${buf.toString().split('').reversed.join()}';
  }

  String _fmtDate(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

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
          size: 12,
          color: isSynced ? Colors.green : Colors.orange,
        ),
        const SizedBox(width: 3),
        Text(
          isSynced ? 'Synced' : 'Local',
          style: TextStyle(
              fontSize: 10,
              color: isSynced ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}