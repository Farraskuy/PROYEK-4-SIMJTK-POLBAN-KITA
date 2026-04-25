import 'package:flutter/material.dart';
import '../controller/detail_laporan_fasilitas_controller.dart';
import '../model/laporan_fasilitas_model.dart';

class DetailLaporanFasilitasView extends StatefulWidget {
  final String laporanId;
  final RoleUser role;

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

  static const _primary = Color(0xFF1565C0);
  static const _bg = Color(0xFFF0F4F8);

  @override
  void initState() {
    super.initState();
    _controller.fetchLaporan(widget.laporanId);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0D1B2A),
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Tugas',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 17,
            letterSpacing: -0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE2E8F0)),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_controller.isLoading) {
      return const Center(child: CircularProgressIndicator(color: _primary));
    }
    if (_controller.errorMessage != null) {
      return Center(
        child: Text(
          _controller.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    final laporan = _controller.laporan!;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _StatusBadge(laporan: laporan),
          const SizedBox(height: 14),
          _InfoUtamaCard(laporan: laporan),
          const SizedBox(height: 12),
          _FotoKondisiSection(laporan: laporan),
          const SizedBox(height: 12),

          // ── Konten berbeda per role ──
          if (widget.role == RoleUser.mahasiswa) ...[
            _TimelineCard(laporan: laporan),
          ],

          if (widget.role == RoleUser.staff) ...[
            _FormSelesaikanCard(laporan: laporan),
          ],

          if (widget.role == RoleUser.admin) ...[
            _TimelineCard(laporan: laporan),
            const SizedBox(height: 12),
            _TombolDelegasi(
              laporan: laporan,
              onDelegasi: (id) => _controller.delegasikan(id),
            ),
          ],
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// WIDGETS
// ═══════════════════════════════════════════════════════════════

class _StatusBadge extends StatelessWidget {
  final LaporanFasilitasModel laporan;
  const _StatusBadge({required this.laporan});

  static const Map<StatusLaporan, (Color, String)> _cfg = {
    StatusLaporan.pending: (Color(0xFFF57C00), 'MENUNGGU'),
    StatusLaporan.assigned: (Color(0xFF1565C0), 'DITUGASKAN'),
    StatusLaporan.inProgress: (Color(0xFF0277BD), 'SEDANG DIKERJAKAN'),
    StatusLaporan.resolved: (Color(0xFF2E7D32), 'SELESAI'),
    StatusLaporan.rejected: (Color(0xFFC62828), 'DITOLAK'),
  };

  @override
  Widget build(BuildContext context) {
    final (color, label) = _cfg[laporan.status]!;
    final shortId =
        'T${laporan.id.substring(0, laporan.id.length.clamp(0, 10)).toUpperCase()}-094';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: color.withOpacity(0.35)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          shortId,
          style: const TextStyle(
            color: Color(0xFF90A4AE),
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _InfoUtamaCard extends StatelessWidget {
  final LaporanFasilitasModel laporan;
  const _InfoUtamaCard({required this.laporan});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            laporan.judul,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D1B2A),
              height: 1.3,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(
                Icons.place_outlined,
                size: 13,
                color: Color(0xFF90A4AE),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  laporan.lokasiLabKelas,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF90A4AE),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFEEF2F7)),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Pelapor',
            value: laporan.pelaporNama,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.schedule_rounded,
            label: 'Waktu Laporan',
            value:
                'Hari ini, ${laporan.createdAt.hour.toString().padLeft(2, '0')}.${laporan.createdAt.minute.toString().padLeft(2, '0')} WIB',
          ),
          const SizedBox(height: 14),
          Container(height: 1, color: const Color(0xFFEEF2F7)),
          const SizedBox(height: 14),
          Row(
            children: [
              const Icon(
                Icons.description_outlined,
                size: 14,
                color: Color(0xFF1565C0),
              ),
              const SizedBox(width: 6),
              const Text(
                'Deskripsi Masalah',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0D1B2A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            laporan.deskripsi,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4A5568),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF1565C0)),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF90A4AE),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF0D1B2A),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FotoKondisiSection extends StatelessWidget {
  final LaporanFasilitasModel laporan;
  const _FotoKondisiSection({required this.laporan});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto Kondisi Awal',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0D1B2A),
            ),
          ),
          const SizedBox(height: 12),
          if (laporan.fotoUrls.isEmpty)
            Row(
              children: List.generate(
                2,
                (i) => Container(
                  margin: EdgeInsets.only(right: i == 0 ? 8 : 0),
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F4F8),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFFB0BEC5),
                    size: 28,
                  ),
                ),
              ),
            )
          else
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: laporan.fotoUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    laporan.fotoUrls[i],
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  final LaporanFasilitasModel laporan;
  const _TimelineCard({required this.laporan});

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: const Icon(
                  Icons.timeline_rounded,
                  size: 15,
                  color: Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Status/Perbaikan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0D1B2A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          ...laporan.riwayat.asMap().entries.map(
            (e) =>
                _TimelineStep(tindakan: e.value, isLast: false, isDone: true),
          ),
          if (laporan.status != StatusLaporan.resolved)
            _TimelineStep(
              tindakan: TindakanFasilitas(
                id: 'end',
                aktivitas: 'Selesai',
                catatanPengerjaan:
                    'Perbaikan selesai dan fasilitas dapat digunakan kembali.',
                timestamp: DateTime.now(),
                aktorNama: '',
              ),
              isLast: true,
              isDone: false,
            ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final TindakanFasilitas tindakan;
  final bool isLast;
  final bool isDone;
  const _TimelineStep({
    required this.tindakan,
    required this.isLast,
    required this.isDone,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isDone ? const Color(0xFF1565C0) : const Color(0xFFCFD8DC);
    final lineColor = isDone
        ? const Color(0xFFBBDEFB)
        : const Color(0xFFECEFF1);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFFE3F2FD)
                        : const Color(0xFFF5F5F5),
                    shape: BoxShape.circle,
                    border: Border.all(color: dotColor, width: 2),
                  ),
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          size: 11,
                          color: Color(0xFF1565C0),
                        )
                      : null,
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.symmetric(vertical: 3),
                      color: lineColor,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tindakan.aktivitas,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDone
                          ? const Color(0xFF0D1B2A)
                          : const Color(0xFFB0BEC5),
                    ),
                  ),
                  if (tindakan.catatanPengerjaan != null &&
                      tindakan.catatanPengerjaan!.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      tindakan.catatanPengerjaan!,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDone
                            ? const Color(0xFF4A5568)
                            : const Color(0xFFCFD8DC),
                        height: 1.4,
                      ),
                    ),
                  ],
                  if (isDone) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${tindakan.timestamp.day} Okt ${tindakan.timestamp.year}, '
                      '${tindakan.timestamp.hour.toString().padLeft(2, '0')}:'
                      '${tindakan.timestamp.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: Color(0xFF90A4AE),
                        fontWeight: FontWeight.w500,
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
}

class _TombolDelegasi extends StatelessWidget {
  final LaporanFasilitasModel laporan;
  final Future<void> Function(String) onDelegasi;
  const _TombolDelegasi({required this.laporan, required this.onDelegasi});

  @override
  Widget build(BuildContext context) {
    final sudah = laporan.handlerId != null;
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: sudah
            ? null
            : () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Halaman delegasi belum dibuat')),
              ),
        icon: const Icon(Icons.assignment_ind_outlined, size: 18),
        label: Text(
          sudah
              ? 'Didelegasikan ke ${laporan.handlerNama}'
              : 'Delegasikan ke Teknisi',
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF1565C0),
          side: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STAFF: Form Selesaikan inline
// ═══════════════════════════════════════════════════════════════

class _FormSelesaikanCard extends StatefulWidget {
  final LaporanFasilitasModel laporan;
  const _FormSelesaikanCard({required this.laporan});

  @override
  State<_FormSelesaikanCard> createState() => _FormSelesaikanCardState();
}

class _FormSelesaikanCardState extends State<_FormSelesaikanCard> {
  final _catatanCtrl = TextEditingController();
  final _durasiCtrl = TextEditingController();
  final List<String> _fotoPaths = [];
  bool _isSubmitting = false;
  String? _error;

  bool get _isValid =>
      _catatanCtrl.text.trim().isNotEmpty &&
      _fotoPaths.isNotEmpty &&
      (int.tryParse(_durasiCtrl.text) ?? 0) > 0;

  @override
  void dispose() {
    _catatanCtrl.dispose();
    _durasiCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isValid) {
      setState(
        () => _error = 'Lengkapi semua field dan unggah minimal 1 foto.',
      );
      return;
    }
    setState(() {
      _isSubmitting = true;
      _error = null;
    });
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tugas berhasil diselesaikan!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _Card(
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEF2F7))),
            ),
            child: const Text(
              'Laporan Penyelesaian',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0D1B2A),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Foto bukti
                const _Label('Foto Bukti Perbaikan'),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._fotoPaths.asMap().entries.map(
                      (e) => _FotoThumb(
                        index: e.key,
                        onHapus: () =>
                            setState(() => _fotoPaths.removeAt(e.key)),
                      ),
                    ),
                    _TombolKamera(
                      onTap: () => setState(
                        () => _fotoPaths.add('dummy_${_fotoPaths.length}'),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Catatan
                const _Label('Tindakan & Catatan'),
                const SizedBox(height: 8),
                _Field(
                  controller: _catatanCtrl,
                  hint: 'Tuliskan detail perbaikan yang dilakukan...',
                  maxLines: 4,
                  onChanged: (_) => setState(() {}),
                ),

                const SizedBox(height: 16),

                // Durasi
                const _Label('Durasi Pengerjaan (Menit)'),
                const SizedBox(height: 8),
                _Field(
                  controller: _durasiCtrl,
                  hint: 'Contoh: 45',
                  keyboardType: TextInputType.number,
                  prefixIcon: Icons.timer_outlined,
                  onChanged: (_) => setState(() {}),
                ),

                if (_error != null) ...[
                  const SizedBox(height: 10),
                  Text(
                    _error!,
                    style: const TextStyle(
                      color: Color(0xFFC62828),
                      fontSize: 12,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _submit,
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.check_circle_outline_rounded,
                            size: 18,
                          ),
                    label: Text(
                      _isSubmitting ? 'Menyimpan...' : 'Selesaikan Tugas',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1565C0),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFB0BEC5),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Micro widgets ─────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  const _Card({required this.child, this.padding});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      color: Color(0xFF4A5568),
    ),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final IconData? prefixIcon;
  final ValueChanged<String>? onChanged;

  const _Field({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.prefixIcon,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: const TextStyle(fontSize: 13, color: Color(0xFF0D1B2A)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFFB0BEC5), fontSize: 13),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, size: 17, color: const Color(0xFF90A4AE))
            : null,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1565C0), width: 1.5),
        ),
      ),
    );
  }
}

class _FotoThumb extends StatelessWidget {
  final int index;
  final VoidCallback onHapus;
  const _FotoThumb({required this.index, required this.onHapus});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFBBDEFB)),
          ),
          child: const Icon(
            Icons.image_rounded,
            color: Color(0xFF1565C0),
            size: 28,
          ),
        ),
        Positioned(
          top: -6,
          right: -6,
          child: GestureDetector(
            onTap: onHapus,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: Color(0xFFC62828),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 13,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TombolKamera extends StatelessWidget {
  final VoidCallback onTap;
  const _TombolKamera({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF1565C0).withOpacity(0.3)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: Color(0xFF1565C0), size: 22),
            SizedBox(height: 4),
            Text(
              'Ketuk untuk\nunggah foto',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 9, color: Color(0xFF1565C0)),
            ),
          ],
        ),
      ),
    );
  }
}
