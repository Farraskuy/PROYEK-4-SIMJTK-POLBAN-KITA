import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
  final _catatanController = TextEditingController();
  final _kebutuhanTuController = TextEditingController();
  bool _ajukanKeTu = false;

  bool get _isPetugas => widget.role == 'teknisi' || widget.role == 'petugas';
  bool get _isTu => widget.role == 'tu';

  static const Color _primaryBlue = Color(0xFF1A9AD7);

  @override
  void initState() {
    super.initState();
    _controller.fetchLaporan(widget.laporanId);
    _controller.addListener(_onControllerChanged);
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final laporan = _controller.laporan;
    if (laporan != null && _catatanController.text.isEmpty) {
      _catatanController.text = laporan.catatanPetugas ?? '';
      _kebutuhanTuController.text = laporan.kebutuhanTu ?? '';
      _ajukanKeTu = laporan.diajukanKeTu;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _catatanController.dispose();
    _kebutuhanTuController.dispose();
    super.dispose();
  }

  Color _statusColor(String status) {
    final s = status.toLowerCase();
    if (s.contains('perbaiki')) return const Color(0xFFF59E0B);
    if (s.contains('selesai')) return const Color(0xFF22C55E);
    if (s.contains('teknisi') || s.contains('ditugaskan')) return _primaryBlue;
    return Colors.grey;
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
      backgroundColor: const Color(0xFFF5F5F5),
      body: CustomScrollView(
        slivers: [
          // ── Hero + AppBar ──────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _primaryBlue,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  laporan.foto_urls.isNotEmpty
                      ? Image.network(
                          laporan.foto_urls.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _heroDark(),
                        )
                      : _heroDark(),
                  // gradient gelap di bawah supaya badge terbaca
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xAA000000)],
                      ),
                    ),
                  ),
                  // Badge status pojok kanan atas
                  Positioned(
                    top: 16,
                    right: 12,
                    child: _buildStatusBadge(laporan.status.label),
                  ),
                ],
              ),
            ),
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
                          color: Color(0xFF1A1A1A),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Deskripsi
                      Text(
                        laporan.deskripsi,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF555555),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      const SizedBox(height: 14),
                      // Grid meta
                      Row(
                        children: [
                          Expanded(
                            child: _metaItem(
                              label: 'DILAPORKAN OLEH',
                              value: laporan.pelapor_id,
                            ),
                          ),
                          Expanded(
                            child: _metaItem(
                              label: 'TANGGAL LAPORAN',
                              value: laporan.createdAt != null
                                  ? _formatDate(laporan.createdAt!)
                                  : '-',
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
                            color: Color(0xFF555555),
                          ),
                        ),
                      ],
                    ),
                  ),

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
                            color: Color(0xFF555555),
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
                                child: Image.network(
                                  laporan.foto_urls[idx],
                                  width: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    width: 100,
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.image_not_supported_outlined,
                                    ),
                                  ),
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
                            color: _primaryBlue,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Status Perbaikan',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
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
        colors: [Color(0xFF1a1a2e), Color(0xFF16213e), Color(0xFF0f3460)],
      ),
    ),
    child: const Center(
      child: Icon(
        Icons.desktop_windows_outlined,
        size: 64,
        color: Color(0x33FFFFFF),
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
          color: Color(0xFF1A1A1A),
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
            color: Color(0xFF444444),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
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
      color: Color(0xFF1A1A1A),
    ),
  );

  // ── Timeline ──────────────────────────────────────────────────────
  Widget _buildTimeline(LaporanFasilitasModel laporan) {
    final statusLabel = laporan.status.label.toLowerCase();
    final steps = [
      _TlStep(
        title: 'Laporan Dibuat',
        desc: 'Laporan berhasil diterima oleh sistem.',
        time: laporan.createdAt != null
            ? _formatDatetime(laporan.createdAt!)
            : '',
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
        dotColor = _primaryBlue;
        dotIcon = const Icon(Icons.check, size: 13, color: Colors.white);
        titleColor = const Color(0xFF1A1A1A);
        break;
      case _TlState.active:
        dotColor = const Color(0xFFF59E0B);
        dotIcon = const Icon(
          Icons.build_outlined,
          size: 12,
          color: Colors.white,
        );
        titleColor = const Color(0xFFF59E0B);
        break;
      case _TlState.pending:
        dotColor = const Color(0xFFE5E5E5);
        dotIcon = const SizedBox.shrink();
        titleColor = const Color(0xFFBBBBBB);
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
                        ? Border.all(color: const Color(0xFFCCCCCC), width: 2)
                        : null,
                  ),
                  child: Center(child: dotIcon),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: step.state == _TlState.done
                          ? _primaryBlue
                          : const Color(0xFFE5E5E5),
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
                          ? const Color(0xFFCCCCCC)
                          : const Color(0xFF888888),
                      height: 1.5,
                    ),
                  ),
                  if (step.time.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      step.time,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFAAAAAA),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tanggapan Petugas',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _catatanController,
            minLines: 2,
            maxLines: 4,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              labelText: 'Catatan penanganan',
              labelStyle: const TextStyle(fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
            ),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _ajukanKeTu,
            activeColor: _primaryBlue,
            onChanged: (v) => setState(() => _ajukanKeTu = v ?? false),
            title: const Text(
              'Ajukan laporan ini ke TU untuk dicetak',
              style: TextStyle(fontSize: 13),
            ),
          ),
          if (_ajukanKeTu) ...[
            TextField(
              controller: _kebutuhanTuController,
              minLines: 2,
              maxLines: 3,
              style: const TextStyle(fontSize: 13),
              decoration: InputDecoration(
                labelText: 'Keterangan untuk TU',
                labelStyle: const TextStyle(fontSize: 13),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          const SizedBox(height: 4),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              onPressed: _controller.isSubmitting
                  ? null
                  : () async {
                      final ok = await _controller.tanggapiPetugas(
                        catatan: _catatanController.text,
                        ajukanKeTu: _ajukanKeTu,
                        kebutuhanTu: _kebutuhanTuController.text,
                      );
                      if (ok && mounted) {
                        Get.snackbar('Sukses', 'Tanggapan petugas tersimpan');
                        Navigator.pop(context, true);
                      }
                    },
              icon: const Icon(Icons.save_rounded, size: 18),
              label: Text(
                _ajukanKeTu ? 'Simpan & Ajukan ke TU' : 'Simpan Tanggapan',
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
              color: Color(0xFF1A1A1A),
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
                    : _primaryBlue,
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
