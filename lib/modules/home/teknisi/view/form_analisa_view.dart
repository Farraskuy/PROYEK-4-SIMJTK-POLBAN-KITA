// lib/modules/teknisi/analisa_kerusakan/view/form_analisa_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/analisa_kerusakan_controller.dart';
import '../model/analisa_kerusakan_model.dart';

class FormAnalisaView extends StatelessWidget {
  const FormAnalisaView({super.key});

  static const Color _primary = Color(0xFF1E3A5F);
  static const Color _bg = Color(0xFFF5F6FA);

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<AnalisaKerusakanController>();

    return Scaffold(
      backgroundColor: _bg,
      appBar: _buildAppBar(ctrl, context),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),

            // ── Seksi Tampilan Laporan Terkunci ──────────────────────────
            _buildSectionCard(
              title: 'Laporan', // DIUBAH DARI "Pilih Laporan"
              icon: Icons.assignment_outlined,
              child: _LaporanPicker(ctrl: ctrl), // Menggunakan komponen statis baru
            ),
            const SizedBox(height: 12),

            // ── Identitas Alat ──────────────────────────────────────────
            _buildSectionCard(
              title: 'Identitas Alat',
              icon: Icons.inventory_2_outlined,
              child: _IdentitasAlatSection(ctrl: ctrl),
            ),
            const SizedBox(height: 12),

            // ── Seksi Input Tanggapan Tugas ──────────────────────────────
            _buildSectionCard(
              title: 'Tanggapan Tugas', // DIUBAH DARI "Analisa Masalah"
              icon: Icons.chat_bubble_outline_rounded,
              child: _TextAreaField(
                controller: ctrl.analisaMasalahCtrl,
                hint: 'Tuliskan hasil diagnosa, temuan teknis, atau tanggapan lengkap mengenai tugas ini...',
                minLines: 5,
              ),
            ),
            const SizedBox(height: 12),

            // ── Perbaikan ───────────────────────────────────────────────
            _buildSectionCard(
              title: 'Perbaikan',
              icon: Icons.build_outlined,
              child: _TextAreaField(
                controller: ctrl.rekomendasiPerbaikanCtrl,
                hint: 'Tuliskan tindakan perbaikan yang direkomendasikan...',
                minLines: 4,
              ),
            ),
            const SizedBox(height: 12),

            // ── Info Tambahan ───────────────────────────────────────────
            _buildSectionCard(
              title: 'Informasi Tambahan',
              icon: Icons.info_outline,
              isOptional: true,
              child: _InfoTambahanSection(ctrl: ctrl),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(context, ctrl),
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
      title: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Formulir Tanggapan', // DIUBAH DARI "Formulir Analisa"
            style: TextStyle(color: _primary, fontSize: 15, fontWeight: FontWeight.bold),
          ),
          Text(
            'Tanggapan Masalah Kerusakan',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    bool isOptional = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.05),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: _primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _primary, decoration: TextDecoration.underline),
                ),
                if (isOptional) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
                    child: const Text('Opsional', style: TextStyle(fontSize: 9, color: Colors.grey)),
                  ),
                ],
              ],
            ),
          ),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, AnalisaKerusakanController ctrl) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, -3))]),
      child: Obx(() => Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: ctrl.isSubmitting.value ? null : () { ctrl.resetForm(); Navigator.pop(context); },
                  style: OutlinedButton.styleFrom(foregroundColor: _primary, side: const BorderSide(color: _primary), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: ctrl.isSubmitting.value ? null : () async {
                    final success = await ctrl.submitAnalisa();
                    if (success && context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: _primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), elevation: 0),
                  child: ctrl.isSubmitting.value
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.save_outlined, size: 18), SizedBox(width: 8), Text('Simpan Tanggapan', style: TextStyle(fontWeight: FontWeight.bold))]),
                ),
              ),
            ],
          )),
    );
  }
}

// ── KOMPONEN SELEKTOR LAPORAN YANG SEKARANG MENJADI STATIS KONTEN ───────────
class _LaporanPicker extends StatelessWidget {
  final AnalisaKerusakanController ctrl;
  const _LaporanPicker({required this.ctrl});

  static const Color _primary = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final laporan = ctrl.selectedLaporan.value;
      
      // Defensif programming jika data null (tidak sengaja masuk tanpa parameter)
      if (laporan == null) {
        return const Text(
          'Tidak ada data laporan yang dipilih.',
          style: TextStyle(color: Colors.red, fontSize: 12, fontWeight: FontWeight.bold),
        );
      }

      // Tampilan Card Informasi Tunggal (Statis, Mengunci Context)
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: _primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: _primary.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.assignment_turned_in_outlined, color: _primary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    laporan.judul,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _primary),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 12, color: Colors.grey.shade600),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          laporan.lokasi,
                          style: TextStyle(color: Colors.grey.shade700, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
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
    });
  }
}

// ── Sub-Widgets Tetap Dipertahankan Sesuai Kebutuhan Form ───────────────────
class _IdentitasAlatSection extends StatelessWidget {
  final AnalisaKerusakanController ctrl; const _IdentitasAlatSection({required this.ctrl});
  @override Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _FormRow(label: 'Kode Alat', child: _InlineTextField(controller: ctrl.kodeAlatCtrl, hint: 'Contoh: PRY-LAB-C-001')),
      const _FormDivider(),
      _FormRow(label: 'No. Inventaris', child: _InlineTextField(controller: ctrl.noInventarisCtrl, hint: 'Contoh: INV/2021/PRY/003')),
    ]);
  }
}

class _InfoTambahanSection extends StatelessWidget {
  final AnalisaKerusakanController ctrl; const _InfoTambahanSection({required this.ctrl});
  @override Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Tingkat Kerusakan', style: TextStyle(fontSize: 12, color: Colors.grey)),
      const SizedBox(height: 6),
      Obx(() => Wrap(spacing: 8, runSpacing: 8, children: TingkatKerusakan.values.map((t) {
            final sel = ctrl.tingkatKerusakan.value == t; final color = _tingkatColor(t);
            return GestureDetector(
              onTap: () => ctrl.setTingkatKerusakan(t),
              child: AnimatedContainer(duration: const Duration(milliseconds: 150), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: sel ? color.withOpacity(0.12) : Colors.grey.shade100, borderRadius: BorderRadius.circular(8), border: Border.all(color: sel ? color : Colors.grey.shade200, width: sel ? 1.5 : 1)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(t.label, style: TextStyle(fontSize: 12, color: sel ? color : Colors.grey.shade600, fontWeight: sel ? FontWeight.bold : FontWeight.normal)), Text(t.deskripsi, style: TextStyle(fontSize: 9, color: sel ? color.withOpacity(0.8) : Colors.grey.shade400))])),
            );
          }).toList())),
    ]);
  }
  Color _tingkatColor(TingkatKerusakan t) { switch (t) { case TingkatKerusakan.ringan: return Colors.green; case TingkatKerusakan.sedang: return Colors.orange; case TingkatKerusakan.berat: return Colors.red; case TingkatKerusakan.total: return Colors.red.shade900; } }
}

class _FormRow extends StatelessWidget {
  final String label; final Widget child; const _FormRow({required this.label, required this.child});
  @override Widget build(BuildContext context) { return Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 130, child: Text(label, style: const TextStyle(fontSize: 12, color: Colors.black87, fontWeight: FontWeight.w500))), const Text(': ', style: TextStyle(fontSize: 12, color: Colors.black54)), Expanded(child: child)])); }
}
class _FormDivider extends StatelessWidget { const _FormDivider(); @override Widget build(BuildContext context) { return Divider(height: 12, color: Colors.grey.shade100); } }
class _InlineTextField extends StatelessWidget {
  final TextEditingController controller; final String hint; const _InlineTextField({required this.controller, required this.hint});
  @override Widget build(BuildContext context) { return TextField(controller: controller, style: const TextStyle(fontSize: 13), decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400), isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 6), border: InputBorder.none, enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade300)), focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1E3A5F), width: 1.5)))); }
}
class _TextAreaField extends StatelessWidget {
  final TextEditingController controller; final String hint; final int minLines; const _TextAreaField({required this.controller, required this.hint, this.minLines = 4});
  @override Widget build(BuildContext context) { return TextField(controller: controller, minLines: minLines, maxLines: null, keyboardType: TextInputType.multiline, style: const TextStyle(fontSize: 13, height: 1.6), decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400), isDense: true, contentPadding: EdgeInsets.zero, border: InputBorder.none)); }
}