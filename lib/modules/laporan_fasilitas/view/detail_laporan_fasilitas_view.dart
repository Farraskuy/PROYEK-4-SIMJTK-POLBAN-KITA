import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/teknisi/view/form_analisa_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_report_image.dart';
import '../controller/detail_laporan_fasilitas_controller.dart';
import '../model/laporan_fasilitas_model.dart';

class DetailLaporanFasilitasView extends StatefulWidget {
  final String laporanId;
  final String role;

  const DetailLaporanFasilitasView({
    super.key,
    required this.laporanId,
    required this.role,
  });

  @override
  State<DetailLaporanFasilitasView> createState() =>
      _DetailLaporanFasilitasViewState();
}

class _DetailLaporanFasilitasViewState
    extends State<DetailLaporanFasilitasView> {
  final _controller = DetailLaporanFasilitasController();

  bool get _isPetugas => widget.role == 'teknisi' || widget.role == 'petugas';
  bool get _isTu => widget.role == 'tu';

  @override
  void initState() {
    super.initState();
    _controller.fetchLaporan(widget.laporanId);
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('perbaiki')) return AppColors.warning;
    if (s.contains('selesai')) return AppColors.success;
    if (s.contains('teknisi') || s.contains('ditugaskan')) return AppColors.primary;
    return AppColors.body;
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_controller.laporan == null) {
      return const Scaffold(
        body: Center(child: Text('Laporan tidak ditemukan')),
      );
    }

    final laporan = _controller.laporan!;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Hero + AppBar ──────────────────────────────────────────
          AppSliverDetailAppBar(
            title: 'Detail Laporan',
            subtitle: 'Portal Petugas JTK',
            onBack: () => Navigator.pop(context),
          ),

          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Kartu info utama ──
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildStatusBadge(laporan.status.label),
                          const Spacer(),
                          const Icon(
                            Icons.engineering_outlined,
                            color: AppColors.primary,
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AppReportImage(
                          source: laporan.foto_urls.isEmpty
                              ? null
                              : laporan.foto_urls.first,
                          height: 190,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 14),
                      // Lokasi sebagai sub-label kecil
                      Text(
                        laporan.lokasi.toUpperCase(),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Judul besar
                      Text(
                        laporan.judul,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.title,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Deskripsi
                      Text(
                        laporan.deskripsi,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.body,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: AppColors.border),
                      const SizedBox(height: 14),
                      // Grid meta
                      Row(
                        children: [
                          Expanded(
                            child: _metaItem(
                              label: 'DILAPORKAN OLEH',
                              value: laporan.pelapor_nama, // <-- Diubah menggunakan pelapor_nama
                            ),
                          ),
                          Expanded(
                            child: _metaItem(
                              label: 'TANGGAL LAPORAN',
                              value: _formatDate(laporan.createdAt),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // ── Info petugas/cetak ──
                if (laporan.teknisi_id != null || laporan.sudahDicetak)
                  _card(
                    child: Column(
                      children: [
                        if (laporan.teknisi_id != null)
                          _infoRow(
                            Icons.engineering_outlined,
                            'Petugas',
                            laporan.teknisi_id!,
                          ),
                        if (laporan.sudahDicetak)
                          _infoRow(
                            Icons.print_outlined,
                            'Cetak TU',
                            laporan.printedAt ?? '-',
                          ),
                      ],
                    ),
                  ),

                // ── Catatan petugas ──
                if (laporan.catatanPetugas?.isNotEmpty == true)
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Tanggapan Petugas'),
                        const SizedBox(height: 6),
                        Text(
                          laporan.catatanPetugas!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.body,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_controller.tanggapan != null)
                  _buildTanggapanDetail(_controller.tanggapan!),

                // ── Kebutuhan TU ──
                if (laporan.kebutuhanTu?.isNotEmpty == true)
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Pengajuan untuk TU'),
                        const SizedBox(height: 6),
                        Text(
                          laporan.kebutuhanTu!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.body,
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Lampiran foto (skip index 0 karena sudah di hero) ──
                if (laporan.foto_urls.length > 1)
                  _card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _sectionLabel('Lampiran Foto'),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: laporan.foto_urls.length,
                            itemBuilder: (context, idx) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: AppReportImage(
                                  source: laporan.foto_urls[idx],
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Timeline Status Perbaikan ──
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.settings_outlined,
                            size: 18,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Status Perbaikan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.title,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildTimeline(laporan),
                    ],
                  ),
                ),

                // ── Form Petugas ──
                if (_isPetugas) _buildPetugasForm(laporan),

                // ── Aksi TU ──
                if (_isTu) _buildTuActions(laporan),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero gelap ────────────────────────────────────────────────────
  Widget _heroDark() => Container(
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [AppColors.navyDark, AppColors.navy, AppColors.primary],
      ),
    ),
    child: Center(
      child: Icon(
        Icons.desktop_windows_outlined,
        size: 64,
        color: AppColors.surface.withValues(alpha: 0.2),
      ),
    ),
  );

  // ── Badge status ──────────────────────────────────────────────────
  Widget _buildStatusBadge(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: _statusColor(label).withOpacity(0.88),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.build_circle_outlined,
            size: 13,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── Card wrapper ──────────────────────────────────────────────────
  Widget _card({required Widget child}) => Container(
    width: double.infinity,
    color: Colors.white,
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(16),
    child: child,
  );

  // ── Meta item ─────────────────────────────────────────────────────
  Widget _metaItem({required String label, required String value}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.grey,
          letterSpacing: 0.5,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.title,
        ),
      ),
    ],
  );

  // ── Info row ──────────────────────────────────────────────────────
  Widget _infoRow(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: Colors.grey),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.neutral,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: AppColors.body),
          ),
        ),
      ],
    ),
  );

  // ── Section label ─────────────────────────────────────────────────
  Widget _sectionLabel(String text) => Text(
    text,
    style: const TextStyle(
      fontSize: 13,
      fontWeight: FontWeight.w600,
      color: AppColors.title,
    ),
  );

  Widget _buildTanggapanDetail(Map<String, dynamic> data) {
    final photos = (data['foto_analisa_urls'] as List?)
            ?.map((item) => item.toString())
            .where((item) => item.isNotEmpty)
            .toList() ??
        const <String>[];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.engineering_outlined,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              _sectionLabel('Detail Tanggapan Petugas'),
            ],
          ),
          const SizedBox(height: 14),
          _detailValue('Petugas', data['teknisi_name']),
          _detailValue('Kode Petugas', data['teknisi_id']),
          _detailValue('Kode Alat', data['kode_alat']),
          _detailValue('No. Inventaris', data['no_inventaris']),
          _detailValue('Tingkat Kerusakan', data['tingkat_kerusakan']),
          _detailValue('Diagnosis / Tanggapan', data['analisa_masalah']),
          _detailValue(
            'Tindakan Perbaikan',
            data['rekomendasi_perbaikan'],
          ),
          if (photos.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Text(
              'Foto Bukti Perbaikan',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.title,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, index) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: AppReportImage(
                    source: photos[index],
                    width: 110,
                    height: 110,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _detailValue(String label, Object? rawValue) {
    final value = rawValue?.toString().trim() ?? '';
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.muted,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value.replaceAll('_', ' '),
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.title,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  // ── Timeline ──────────────────────────────────────────────────────
  Widget _buildTimeline(LaporanFasilitasModel laporan) {
    final statusLabel = laporan.status.label.toLowerCase();
    final steps = [
      _TlStep(
        title: 'Laporan Dibuat',
        desc: 'Laporan berhasil diterima oleh sistem.',
        time: _formatDatetime(laporan.createdAt),
        state: _TlState.done,
      ),
      _TlStep(
        title: 'Ditugaskan ke Teknisi',
        desc: laporan.teknisi_id != null
            ? 'Teknisi ${laporan.teknisi_id} telah ditugaskan untuk menangani laporan ini.'
            : 'Menunggu penugasan teknisi.',
        time: '',
        state: laporan.teknisi_id != null ? _TlState.done : _TlState.pending,
      ),
      _TlStep(
        title: 'Sedang Diperbaiki',
        desc:
            'Teknisi sedang melakukan pengecekan dan penggantian komponen di lokasi.',
        time: '',
        state: statusLabel.contains('perbaiki')
            ? _TlState.active
            : statusLabel.contains('selesai')
            ? _TlState.done
            : _TlState.pending,
      ),
      _TlStep(
        title: 'Selesai',
        desc: 'Perbaikan selesai dan fasilitas dapat digunakan kembali.',
        time: '',
        state: statusLabel.contains('selesai')
            ? _TlState.done
            : _TlState.pending,
      ),
    ];

    return Column(
      children: List.generate(steps.length, (i) {
        return _tlItem(steps[i], isLast: i == steps.length - 1);
      }),
    );
  }

  Widget _tlItem(_TlStep step, {required bool isLast}) {
    Color dotColor;
    Widget dotIcon;
    Color titleColor;

    switch (step.state) {
      case _TlState.done:
        dotColor = AppColors.primary;
        dotIcon = const Icon(Icons.check, size: 13, color: Colors.white);
        titleColor = AppColors.title;
        break;
      case _TlState.active:
        dotColor = AppColors.warning;
        dotIcon = const Icon(
          Icons.build_outlined,
          size: 12,
          color: Colors.white,
        );
        titleColor = AppColors.warning;
        break;
      case _TlState.pending:
        dotColor = AppColors.border;
        dotIcon = const SizedBox.shrink();
        titleColor = AppColors.muted;
        break;
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                    border: step.state == _TlState.pending
                        ? Border.all(color: AppColors.border, width: 2)
                        : null,
                  ),
                  child: Center(child: dotIcon),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: step.state == _TlState.done
                          ? AppColors.primary
                          : AppColors.border,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.desc,
                    style: TextStyle(
                      fontSize: 12,
                      color: step.state == _TlState.pending
                          ? AppColors.border
                          : AppColors.body,
                      height: 1.5,
                    ),
                  ),
                  if (step.time.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      step.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Form Petugas ──────────────────────────────────────────────────
  Widget _buildPetugasForm(LaporanFasilitasModel laporan) {
    return _card(
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () async {
            final changed = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => FormAnalisaView(laporan: laporan),
              ),
            );
            if (changed == true) {
              await _controller.fetchLaporan(laporan.id);
            }
          },
          icon: const Icon(Icons.edit_note_rounded),
          label: const Text('Buka Formulir Tanggapan'),
        ),
      ),
    );
  }

  // ── Aksi TU ───────────────────────────────────────────────────────
  Widget _buildTuActions(LaporanFasilitasModel laporan) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cetak Laporan TU',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.title,
            ),
          ),
          const SizedBox(height: 12),
          _infoRow(Icons.tag, 'Nomor', laporan.id),
          _infoRow(Icons.title, 'Judul', laporan.judul),
          _infoRow(Icons.location_on_outlined, 'Lokasi', laporan.lokasi),
          _infoRow(
            Icons.engineering_outlined,
            'Petugas',
            laporan.teknisi_id ?? '-',
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: laporan.sudahDicetak
                    ? Colors.grey.shade300
                    : AppColors.primary,
                foregroundColor: laporan.sudahDicetak
                    ? Colors.grey.shade600
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: laporan.sudahDicetak || _controller.isSubmitting
                  ? null
                  : () async {
                      final ok = await _controller.tandaiDicetak();
                      if (ok && mounted) {
                        Get.snackbar(
                          'Sukses',
                          'Laporan ditandai sudah dicetak',
                        );
                        Navigator.pop(context, true);
                      }
                    },
              icon: const Icon(Icons.print_rounded, size: 18),
              label: Text(
                laporan.sudahDicetak ? 'Sudah Dicetak' : 'Tandai Sudah Dicetak',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Format tanggal ────────────────────────────────────────────────
  String _formatDate(DateTime dt) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year},\n${_p(dt.hour)}:${_p(dt.minute)}';
  }

  String _formatDatetime(DateTime dt) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agt',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${dt.day} ${m[dt.month - 1]} ${dt.year}, ${_p(dt.hour)}:${_p(dt.minute)}';
  }

  String _p(int n) => n.toString().padLeft(2, '0');
}

// ── Helper classes ────────────────────────────────────────────────────
enum _TlState { done, active, pending }

class _TlStep {
  final String title;
  final String desc;
  final String time;
  final _TlState state;
  const _TlStep({
    required this.title,
    required this.desc,
    required this.time,
    required this.state,
  });
}
