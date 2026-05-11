// lib/modules/laporan_fasilitas/view/detail_laporan_fasilitas_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/detail_laporan_fasilitas_controller.dart';
import '../model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/app_navigator.dart';

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
            _buildInfoRow(Icons.location_on, 'Lokasi', laporan.lokasi),
            _buildInfoRow(Icons.info_outline, 'Status', laporan.status.label),
            _buildInfoRow(Icons.person, 'Pelapor ID', laporan.pelapor_id),
            _buildInfoRow(
              Icons.engineering,
              'Petugas',
              laporan.teknisi_id ?? 'Belum ditangani',
            ),
            if (laporan.sudahDicetak)
              _buildInfoRow(Icons.print, 'Cetak TU', laporan.printedAt ?? '-'),
            const SizedBox(height: 16),
            const Text(
              'Deskripsi:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(laporan.deskripsi),
            const SizedBox(height: 16),
            if (laporan.catatanPetugas?.isNotEmpty == true) ...[
              const Text(
                'Tanggapan Petugas:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(laporan.catatanPetugas!),
              const SizedBox(height: 16),
            ],
            if (laporan.kebutuhanTu?.isNotEmpty == true) ...[
              const Text(
                'Pengajuan untuk TU:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(laporan.kebutuhanTu!),
              const SizedBox(height: 16),
            ],
            if (laporan.foto_urls.isNotEmpty) ...[
              const Text(
                'Lampiran Foto:',
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
                        errorBuilder: (_, __, ___) => Container(
                          width: 120,
                          color: Colors.grey.shade200,
                          child: const Icon(Icons.image_not_supported_outlined),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (_isPetugas) _buildPetugasForm(laporan),
            if (_isTu) _buildTuActions(laporan),
          ],
        ),
      ),
    );
  }

  Widget _buildPetugasForm(LaporanFasilitasModel laporan) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tanggapan Petugas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _catatanController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Catatan penanganan',
                border: OutlineInputBorder(),
              ),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _ajukanKeTu,
              onChanged: (value) =>
                  setState(() => _ajukanKeTu = value ?? false),
              title: const Text('Ajukan laporan ini ke TU untuk dicetak'),
            ),
            if (_ajukanKeTu) ...[
              TextField(
                controller: _kebutuhanTuController,
                minLines: 2,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Keterangan untuk TU',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.save_rounded),
                label: Text(
                  _ajukanKeTu ? 'Simpan & Ajukan ke TU' : 'Simpan Tanggapan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTuActions(LaporanFasilitasModel laporan) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cetak Laporan TU',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Nomor: ${laporan.id}'),
            Text('Judul: ${laporan.judul}'),
            Text('Lokasi: ${laporan.lokasi}'),
            Text('Petugas: ${laporan.teknisi_id ?? '-'}'),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
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
                icon: const Icon(Icons.print_rounded),
                label: Text(
                  laporan.sudahDicetak
                      ? 'Sudah Dicetak'
                      : 'Tandai Sudah Dicetak',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w600)),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
