// lib/modules/home/teknisi/usulan_pemeliharaan/view/usulan_pemeliharaan_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/usulan_pemeliharaan_controller.dart';

class UsulanPemeliharaanView extends StatelessWidget {
  const UsulanPemeliharaanView({super.key});
  
  // Menggunakan warna primary yang selaras dengan home_view
  static const Color _primary = Color(0xFF1A3A6B);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(UsulanPemeliharaanController());
    
    return Scaffold(
      // Background disamakan dengan analisa_kerusakan_view.dart (Color(0xFFF5F6FA))
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        // Desain AppBar dibuat clean (putih) seperti pada analisa_kerusakan_view.dart
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _primary),
        title: const Text(
          'Usulan Pemeliharaan & Perbaikan', 
          style: TextStyle(
            fontSize: 16, 
            fontWeight: FontWeight.bold,
            color: _primary,
          )
        ), 
      ),
      body: Form(
        key: c.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── INFORMASI USULAN ──
            _buildSectionCard(
              title: 'INFORMASI USULAN',
              icon: Icons.info_outline,
              child: Column(
                children: [
                  Row(children: [
                    Expanded(child: _buildTextField('Tahun Usulan', c.tahunUsulanCtrl, type: TextInputType.number)),
                    const SizedBox(width: 10),
                    Expanded(child: _buildTextField('Tahun Anggaran', c.tahunAnggaranCtrl, type: TextInputType.number)),
                  ]),
                  _buildTextField('Pengelola Data', c.pengelolaCtrl),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Penanggung Gugat: Ketua Jurusan', style: TextStyle(fontSize: 11, color: Colors.grey, fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // ── HEADER DAFTAR ITEM ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('DAFTAR USULAN ITEM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _primary)),
                TextButton.icon(
                  onPressed: c.addRow, 
                  icon: const Icon(Icons.add_circle_outline, size: 18), 
                  label: const Text('Tambah Item', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: _primary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── LIST INPUT ITEM ──
            Obx(() => Column(
              children: c.rows.asMap().entries.map((e) {
                final i = e.key; 
                final r = e.value;
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
                        child: Text('Item ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: _primary)),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField('Nama Barang/Alat', r['nama']!),
                      _buildTextField('Spesifikasi', r['spesifikasi']!),
                      _buildTextField('Kegiatan Perbaikan', r['kegiatan']!),
                      _buildTextField('Tingkat Kerusakan', r['tingkat']!),
                      Row(children: [
                        Expanded(child: _buildTextField('Volume', r['vol']!, type: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTextField('Satuan', r['sat']!)),
                      ]),
                      Row(children: [
                        Expanded(child: _buildTextField('Harga Sat (Rp)', r['harga']!, type: TextInputType.number)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTextField('Jumlah (Rp)', r['jumlah']!, type: TextInputType.number)),
                      ]),
                    ]
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 24),
            
            // ── TOMBOL SUBMIT ──
            Obx(() => ElevatedButton(
              onPressed: c.isSubmitting.value
                  ? null
                  : () async {
                      final success = await c.submit();
                      if (success && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary, 
                padding: const EdgeInsets.symmetric(vertical: 14), 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
              ),
              child: c.isSubmitting.value
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Simpan Usulan', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
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
