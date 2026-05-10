// lib/modules/home/teknisi/penghapusan/view/penghapusan_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/penghapusan_controller.dart';

class UsulanPenghapusanView extends StatelessWidget {
  const UsulanPenghapusanView({super.key});

  static const Color _primary = Color(0xFF1A3A6B);

  @override
  Widget build(BuildContext context) {
    final c = Get.put(PenghapusanController());
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _primary),
        title: const Text(
          'Data Usulan Penghapusan', 
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _primary)
        ), 
      ),
      body: Form(
        key: c.formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── INFORMASI USULAN ──
            _buildSectionCard(
              title: 'INFORMASI USULAN PENGHAPUSAN',
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

            // ── HEADER LIST BARANG ──
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('DAFTAR BARANG/ALAT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _primary)),
                TextButton.icon(
                  onPressed: c.addRow, 
                  icon: const Icon(Icons.add_circle_outline, size: 18), 
                  label: const Text('Tambah Barang', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(foregroundColor: _primary),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // ── LIST INPUT BARANG ──
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
                        child: Text('Barang ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: _primary)),
                      ),
                      const SizedBox(height: 12),
                      _buildTextField('Nama Barang/Alat', r['nama']!),
                      _buildTextField('Kondisi Barang/Alat', r['kondisi']!),
                      _buildTextField('No. Inventaris', r['no_inv']!),
                      _buildTextField('Keterangan', r['ket']!, req: false, maxLines: 2),
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