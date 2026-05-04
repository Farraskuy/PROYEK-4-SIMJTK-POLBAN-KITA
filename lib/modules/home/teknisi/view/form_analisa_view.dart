// lib/modules/teknisi/analisa_kerusakan/view/form_analisa_view.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controller/analisa_kerusakan_controller.dart';
import '../model/analisa_kerusakan_model.dart';

class FormAnalisaView extends StatelessWidget {
  const FormAnalisaView({super.key});

  static const Color _primary = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AnalisaKerusakanController>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _primary),
          onPressed: () => _confirmBack(ctrl),
        ),
        title: const Text(
          'Tambah Analisa Kerusakan',
          style: TextStyle(
              color: _primary, fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Section 1: Pilih Laporan ────────────────────────────
            _SectionCard(
              title: 'PILIH LAPORAN',
              icon: Icons.assignment_outlined,
              child: _buildPilihLaporan(ctrl),
            ),
            const SizedBox(height: 16),

            // ── Section 2: Diagnosa Teknis ──────────────────────────
            _SectionCard(
              title: 'DIAGNOSA TEKNIS',
              icon: Icons.search_outlined,
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Diagnosa Masalah',
                    hint:
                        'Jelaskan hasil pemeriksaan teknis secara detail...',
                    controller: ctrl.diagnosaMasalahCtrl,
                    maxLines: 4,
                    isRequired: true,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    label: 'Komponen/Bagian yang Rusak',
                    hint: 'Cth: Lampu proyektor, Motherboard, Kapasitor...',
                    controller: ctrl.komponenRusakCtrl,
                    isRequired: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Section 3: Kategori & Tingkat ───────────────────────
            _SectionCard(
              title: 'KLASIFIKASI KERUSAKAN',
              icon: Icons.category_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kategori kerusakan
                  _fieldLabel('Kategori Kerusakan', isRequired: true),
                  const SizedBox(height: 8),
                  _buildKategoriSelector(ctrl),
                  const SizedBox(height: 16),

                  // Tingkat kerusakan
                  _fieldLabel('Tingkat Kerusakan', isRequired: true),
                  const SizedBox(height: 8),
                  _buildTingkatSelector(ctrl),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Section 4: Rekomendasi ──────────────────────────────
            _SectionCard(
              title: 'REKOMENDASI TINDAKAN',
              icon: Icons.recommend_outlined,
              child: Column(
                children: [
                  _buildTextField(
                    label: 'Tindakan yang Direkomendasikan',
                    hint:
                        'Cth: Penggantian komponen, Perbaikan, Penghapusan barang...',
                    controller: ctrl.tindakanCtrl,
                    maxLines: 3,
                    isRequired: true,
                  ),
                  const SizedBox(height: 14),

                  // Estimasi dalam satu row
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          label: 'Estimasi Waktu (Hari)',
                          hint: 'Cth: 3',
                          controller: ctrl.estimasiHariCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          prefixIcon: Icons.schedule_outlined,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildTextField(
                          label: 'Estimasi Biaya (Rp)',
                          hint: 'Cth: 1500000',
                          controller: ctrl.estimasiBiayaCtrl,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly
                          ],
                          prefixIcon: Icons.payments_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  _buildTextField(
                    label: 'Catatan Tambahan (Opsional)',
                    hint:
                        'Informasi tambahan yang perlu diketahui...',
                    controller: ctrl.catatanCtrl,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Section 5: Foto Analisa ─────────────────────────────
            _SectionCard(
              title: 'FOTO DOKUMENTASI',
              icon: Icons.camera_alt_outlined,
              child: _buildFotoSection(),
            ),

            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(ctrl),
    );
  }

  // ── Pilih Laporan ─────────────────────────────────────────────────────────

  Widget _buildPilihLaporan(AnalisaKerusakanController ctrl) {
    return Obx(() {
      final laporanList = ctrl.laporanBelumDianalisa;

      if (laporanList.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.withOpacity(0.2)),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle_outline,
                  color: Colors.green, size: 18),
              SizedBox(width: 8),
              Text('Semua laporan sudah dianalisa',
                  style: TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${laporanList.length} laporan menunggu analisa',
            style: TextStyle(color: Colors.grey[500], fontSize: 12),
          ),
          const SizedBox(height: 10),
          ...laporanList.map((laporan) {
            final isSelected =
                ctrl.selectedLaporan.value?.id == laporan.id;
            return GestureDetector(
              onTap: () => ctrl.setLaporan(laporan),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1E3A5F).withOpacity(0.05)
                      : Colors.grey[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF1E3A5F)
                        : Colors.grey.shade200,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF1E3A5F)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.assignment_outlined,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(laporan.judul,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                  color: isSelected
                                      ? const Color(0xFF1E3A5F)
                                      : Colors.black87)),
                          const SizedBox(height: 2),
                          Text(
                            laporan.lokasi,
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(laporan.kategori,
                                style: const TextStyle(
                                    color: Colors.orange,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      const Icon(Icons.check_circle,
                          color: Color(0xFF1E3A5F), size: 20),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }

  // ── Kategori Selector ─────────────────────────────────────────────────────

  Widget _buildKategoriSelector(AnalisaKerusakanController ctrl) {
    return Obx(() => Wrap(
          spacing: 8,
          runSpacing: 8,
          children: KategoriKerusakan.values.map((k) {
            final isSelected = ctrl.kategoriKerusakan.value == k;
            final color = _kategoriColor(k);
            return GestureDetector(
              onTap: () => ctrl.setKategoriKerusakan(k),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.12)
                      : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? color : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  k.label,
                  style: TextStyle(
                      color: isSelected ? color : Colors.grey.shade500,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            );
          }).toList(),
        ));
  }

  // ── Tingkat Selector ──────────────────────────────────────────────────────

  Widget _buildTingkatSelector(AnalisaKerusakanController ctrl) {
    return Obx(() => Column(
          children: TingkatKerusakan.values.map((t) {
            final isSelected = ctrl.tingkatKerusakan.value == t;
            final color = _tingkatColor(t);
            return GestureDetector(
              onTap: () => ctrl.setTingkatKerusakan(t),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color.withOpacity(0.07)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? color : Colors.grey.shade200,
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isSelected ? color : Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.label,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: isSelected
                                    ? color
                                    : Colors.black87),
                          ),
                          Text(
                            t.deskripsi,
                            style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? color.withOpacity(0.8)
                                    : Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle,
                          color: color, size: 18),
                  ],
                ),
              ),
            );
          }).toList(),
        ));
  }

  // ── Foto Section ──────────────────────────────────────────────────────────

  Widget _buildFotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Foto saat melakukan diagnosa (opsional)',
            style: TextStyle(color: Colors.grey[500], fontSize: 12)),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            Get.snackbar('Info', 'Fitur kamera akan diintegrasikan',
                snackPosition: SnackPosition.BOTTOM,
                margin: const EdgeInsets.all(16));
          },
          child: Container(
            width: double.infinity,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.camera_alt_outlined,
                    color: Colors.grey[400], size: 28),
                const SizedBox(height: 6),
                Text('Ketuk untuk unggah foto',
                    style: TextStyle(
                        color: Colors.grey[400], fontSize: 12)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Bottom Bar ────────────────────────────────────────────────────────────

  Widget _buildBottomBar(AnalisaKerusakanController ctrl) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      child: Obx(() => SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed:
                  ctrl.isSubmitting.value ? null : ctrl.submitAnalisa,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary,
                disabledBackgroundColor: _primary.withOpacity(0.5),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: ctrl.isSubmitting.value
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2.5))
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.save_outlined,
                            color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Simpan Analisa',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                      ],
                    ),
            ),
          )),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _confirmBack(AnalisaKerusakanController ctrl) {
    Get.dialog(
      AlertDialog(
        title: const Text('Batalkan Analisa?'),
        content: const Text(
            'Data yang sudah diisi akan hilang. Yakin ingin kembali?'),
        actions: [
          TextButton(
              onPressed: () => Get.back(),
              child: const Text('Lanjut Isi')),
          TextButton(
            onPressed: () {
              ctrl.resetForm();
              Get.back();
              Get.back();
            },
            child: const Text('Ya, Batalkan',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label, {bool isRequired = false}) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Colors.black87)),
        if (isRequired)
          const Text(' *',
              style: TextStyle(color: Colors.red, fontSize: 13)),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    IconData? prefixIcon,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label, isRequired: isRequired),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: const TextStyle(fontSize: 13),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: Colors.grey)
                : null,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide:
                  const BorderSide(color: _primary, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(14),
          ),
        ),
      ],
    );
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

  Color _tingkatColor(TingkatKerusakan t) {
    switch (t) {
      case TingkatKerusakan.ringan: return Colors.green;
      case TingkatKerusakan.sedang: return Colors.orange;
      case TingkatKerusakan.berat: return Colors.red;
      case TingkatKerusakan.total: return Colors.red.shade900;
    }
  }
}

// ── Section Card ──────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard(
      {required this.title, required this.icon, required this.child});

  static const Color _primary = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              Container(
                width: 3,
                height: 16,
                decoration: BoxDecoration(
                    color: _primary,
                    borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 8),
              Icon(icon, size: 15, color: _primary),
              const SizedBox(width: 6),
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: _primary,
                      letterSpacing: 0.8)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}