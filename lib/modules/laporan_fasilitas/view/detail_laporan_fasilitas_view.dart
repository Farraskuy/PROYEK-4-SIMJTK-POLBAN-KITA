// lib/modules/laporan_fasilitas/view/detail_laporan_fasilitas_view.dart

import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    _controller.fetchLaporan(widget.laporanId);
    _controller.addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_controller.laporan == null)
      return const Scaffold(
        body: Center(child: Text("Laporan tidak ditemukan")),
      );

    final laporan = _controller.laporan!;

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              laporan.judul,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow(Icons.location_on, "Lokasi", laporan.lokasi),
            _buildInfoRow(Icons.info_outline, "Status", laporan.status.label),
            _buildInfoRow(Icons.person, "Pelapor ID", laporan.pelapor_id),
            _buildInfoRow(
              Icons.engineering,
              "Teknisi",
              laporan.teknisi_id ?? "Belum ditugaskan",
            ),
            const SizedBox(height: 16),
            const Text(
              "Deskripsi:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(laporan.deskripsi),
            const SizedBox(height: 16),
            if (laporan.foto_urls.isNotEmpty) ...[
              const Text(
                "Lampiran Foto:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: laporan.foto_urls.length,
                  itemBuilder: (context, idx) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        laporan.foto_urls[idx],
                        width: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text("$label: ", style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }
}
