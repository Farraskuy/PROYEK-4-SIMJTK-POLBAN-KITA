// lib/modules/home/teknisi/kontrol_barang/view/kontrol_barang_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/kontrol_barang_controller.dart';

class DataKontrolBarangView extends StatelessWidget {
  const DataKontrolBarangView({super.key});

  static const Color _primary = Color(0xFF1A3A6B);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(DataKontrolBarangController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _primary),
        title: const Text(
          'Data Kontrol Barang/Alat', 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primary)
        ), 
      ),
      body: Form(
        key: c.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── SECTION A: IDENTITAS ──
            _buildSectionCard(
              title: 'A. IDENTITAS BARANG/ALAT',
              icon: Icons.info_outline,
              child: Column(
                children: [
                  _buildTextField('Nama Ruang/Lab', c.namaRuangCtrl),
                  _buildTextField('Nama Barang/Alat', c.namaBarangCtrl),
                  _buildTextField('No. Inventaris', c.noInventarisCtrl),
                  _buildTextField('ID Komputer', c.idKomputerCtrl, req: false),
                  _buildTextField('Status Barang/Alat', c.statusBarangCtrl),
                  _buildTextField('Asal Barang', c.asalBarangCtrl),
                  Row(
                    children: [
                      Expanded(child: _buildTextField('Tahun Perolehan', c.tahunPerolehanCtrl, type: TextInputType.number)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildTextField('Prakiraan Harga', c.prakiraanHargaCtrl, req: false, type: TextInputType.number)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── SECTION B: HARDWARE ──
            _buildSectionCard(
              title: 'B. SPESIFIKASI BARANG/ALAT',
              icon: Icons.memory_outlined,
              child: Column(
                children: List.generate(
                  12, 
                  (i) => _buildTextField(c.hardwareLabels[i], c.hardwareCtrls[i], req: false)
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── SECTION C: SOFTWARE ──
            _buildSectionCard(
              title: 'C. SPESIFIKASI SOFTWARE',
              icon: Icons.terminal_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField('Operating System', c.osCtrl, req: false),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Aplikasi Terinstal:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _primary)),
                        TextButton.icon(
                          onPressed: c.addAplikasiRow,
                          icon: const Icon(Icons.add_circle_outline, size: 16),
                          label: const Text('Tambah Aplikasi Baru', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            foregroundColor: _primary,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(50, 30),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(() => Column(
                    children: c.aplikasiCtrls.asMap().entries.map((entry) {
                      final index = entry.key;
                      final ctrl = entry.value;
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _buildTextField('Aplikasi ${index + 1}', ctrl, req: false),
                          ),
                          if (c.aplikasiCtrls.length > 1) // Prevent deleting the very last input
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline, color: Colors.red, size: 20),
                              onPressed: () => c.removeAplikasiRow(index),
                              padding: const EdgeInsets.only(left: 8, bottom: 12),
                              constraints: const BoxConstraints(),
                            )
                        ],
                      );
                    }).toList(),
                  )),
                ],
              ),
            ),

            // ── SECTION F: BIAYA PERBAIKAN ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('F. BIAYA PERBAIKAN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _primary)),
                TextButton.icon(
                  onPressed: c.addBiayaRow, 
                  icon: const Icon(Icons.add_circle_outline, size: 18), 
                  label: const Text('Tambah Biaya', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: _primary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Obx(() => Column(
              children: c.biayaRows.asMap().entries.map((entry) {
                final i = entry.key;
                final r = entry.value;
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: _primary.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                        child: Text('Perbaikan ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: _primary)),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField('Komponen Rusak', r['komponen_rusak']!, req: false),
                      _buildTextField('Komponen Pengganti', r['komponen_pengganti']!, req: false),
                      _buildTextField('Biaya Perbaikan (Rp)', r['biaya']!, req: false, type: TextInputType.number),
                      _buildTextField('Sumber Dana', r['sumber_dana']!, req: false),
                      _buildTextField('Ditangani Oleh', r['ditangani']!, req: false),
                    ]
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 24),

            // ── TOMBOL SUBMIT ──
            Obx(() => ElevatedButton(
              onPressed: c.isSubmitting.value ? null : c.submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary, 
                padding: const EdgeInsets.symmetric(vertical: 14), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: c.isSubmitting.value
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan Data Kontrol', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            )),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ==============================================================================
  // FUNGSI PEMBANGUN UI LOKAL
  // ==============================================================================
  
  Widget _buildTextField(String label, TextEditingController ctrl, {bool req = true, int maxLines = 1, TextInputType? type}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        maxLines: maxLines,
        keyboardType: type,
        style: const TextStyle(fontSize: 13),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Colors.grey.shade200)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: _primary, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          isDense: true,
        ),
        validator: req ? (v) => (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null : null,
      ),
    );
  }

  Widget _buildSectionCard({required String title, required IconData icon, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: _primary),
              const SizedBox(width: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: _primary, letterSpacing: 0.5)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}