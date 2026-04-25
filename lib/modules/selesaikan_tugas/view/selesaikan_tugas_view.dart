import 'dart:io'; // Penting: Untuk membaca file gambar asli
import 'package:flutter/material.dart';
import '../controller/selesaikan_tugas_controller.dart';
import '../model/selesaikan_tugas_model.dart';
import 'vision_view.dart';

class SelesaikanTugasView extends StatefulWidget {
  final LaporanFasilitasModel laporan;

  const SelesaikanTugasView({super.key, required this.laporan});

  @override
  State<SelesaikanTugasView> createState() => _SelesaikanTugasViewState();
}

class _SelesaikanTugasViewState extends State<SelesaikanTugasView> {
  final _controller = SelesaikanTugasController();

  @override
  void initState() {
    super.initState();
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1A3557),
        elevation: 0,
        title: const Text(
          'Selesaikan Tugas',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _RingkasanLaporanCard(laporan: widget.laporan),
            const SizedBox(height: 16),
            _FotoBuktiSection(controller: _controller),
            const SizedBox(height: 16),
            _CatatanSection(controller: _controller),
            const SizedBox(height: 16),
            _DurasiSection(controller: _controller),

            if (_controller.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _controller.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 13),
              ),
            ],

            const SizedBox(height: 24),
            _TombolSelesaikan(
              controller: _controller,
              laporanId: widget.laporan.id,
              onSuccess: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tugas berhasil diselesaikan!'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Widgets ─────────────────────────────────────────────────

class _RingkasanLaporanCard extends StatelessWidget {
  final LaporanFasilitasModel laporan;
  const _RingkasanLaporanCard({required this.laporan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A7FC1).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1A7FC1).withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            laporan.judul,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1A3557),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: Colors.grey,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  laporan.lokasiLabKelas,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FotoBuktiSection extends StatelessWidget {
  final SelesaikanTugasController controller;
  const _FotoBuktiSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Laporan Penyelesaian',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Color(0xFF1A3557),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Foto Bukti Perbaikan',
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              // Menampilkan List Foto Asli
              ...controller.fotoBuktiPaths.asMap().entries.map(
                (e) => _FotoItem(
                  path: e.value,
                  index: e.key,
                  onHapus: () => controller.hapusFoto(e.key),
                ),
              ),
              _TombolTambahFoto(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VisionView()),
                  );

                  if (result != null) {
                    controller.tambahFoto(result);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FotoItem extends StatelessWidget {
  final String path;
  final int index;
  final VoidCallback onHapus;

  const _FotoItem({
    required this.path,
    required this.index,
    required this.onHapus,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: FileImage(File(path)), // Load gambar asli dari storage
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 2,
          right: 2,
          child: GestureDetector(
            onTap: onHapus,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _TombolTambahFoto extends StatelessWidget {
  final VoidCallback onTap;
  const _TombolTambahFoto({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: const Color(0xFFF0F7FF),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFF1A7FC1).withOpacity(0.3)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, color: Color(0xFF1A7FC1), size: 22),
            SizedBox(height: 4),
            Text(
              'Ketuk untuk\nunggah foto',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 10, color: Color(0xFF1A7FC1)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatatanSection extends StatelessWidget {
  final SelesaikanTugasController controller;
  const _CatatanSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tindakan & Catatan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1A3557),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller.catatanController,
            maxLines: 4,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Tuliskan detail perbaikan yang dilakukan...',
              hintStyle: const TextStyle(color: Colors.grey, fontSize: 13),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1A7FC1)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

class _DurasiSection extends StatelessWidget {
  final SelesaikanTugasController controller;
  const _DurasiSection({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Durasi Pengerjaan (Menit)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF1A3557),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller.durasiController,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Contoh: 45',
              hintStyle: const TextStyle(color: Colors.grey),
              prefixIcon: const Icon(
                Icons.timer_outlined,
                color: Color(0xFF1A7FC1),
                size: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF1A7FC1)),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

class _TombolSelesaikan extends StatelessWidget {
  final SelesaikanTugasController controller;
  final String laporanId;
  final VoidCallback onSuccess;
  const _TombolSelesaikan({
    required this.controller,
    required this.laporanId,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: controller.isSubmitting
            ? null
            : () async {
                final sukses = await controller.submit(laporanId);
                if (sukses) onSuccess();
              },
        icon: controller.isSubmitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.check_circle_outline),
        label: Text(
          controller.isSubmitting ? 'Menyimpan...' : 'Selesaikan Tugas',
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A7FC1),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }
}
