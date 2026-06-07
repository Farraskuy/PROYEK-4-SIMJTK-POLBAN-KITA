// lib/modules/laporan_fasilitas/view/selesaikan_tugas_view.dart

import 'package:flutter/material.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import '../controller/selesaikan_tugas_controller.dart';
import '../model/laporan_fasilitas_model.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Selesaikan Tugas',
          style: TextStyle(
            color: AppColors.title,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Laporan Singkat
            _buildInfoCard(),
            const SizedBox(height: 20),

            const Text(
              "Bukti Perbaikan",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),

            // Area Upload Foto (Integrasi dengan Vision/Camera)
            _buildPhotoPicker(),
            const SizedBox(height: 20),

            const Text(
              "Catatan Teknisi",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 10),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                hintText: "Masukkan detail perbaikan yang dilakukan...",
                fillColor: AppColors.surface,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Tombol Submit
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.laporan.judul,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 4),
            Text(
              "Lokasi: ${widget.laporan.lokasi}",
              style: const TextStyle(color: AppColors.body),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return GestureDetector(
      onTap: () {
        // Logika ambil foto perbaikan
      },
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.camera_alt_outlined, size: 40, color: AppColors.muted),
            Text(
              "Ambil Foto Hasil Perbaikan",
              style: TextStyle(color: AppColors.body),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _controller.isSubmitting
            ? null
            : () async {
                // Mengirim ID laporan (mapping dari _id database)
                final success = await _controller.submit(widget.laporan.id);
                if (success) Navigator.pop(context);
              },
        child: _controller.isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Konfirmasi Selesai",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}
