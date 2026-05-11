// lib/modules/teknisi/analisa_kerusakan/view/form_analisa_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/analisa_kerusakan_controller.dart';
import '../model/analisa_kerusakan_model.dart';

class FormAnalisaView extends StatelessWidget {
  const FormAnalisaView({super.key});

  static const Color _primary = Color(0xFF1E3A5F);
  static const Color _accent = Color(0xFFE8720C); // POLBAN orange
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
            //  Kop Formulir 
            _buildFormHeader(),
            const SizedBox(height: 16),

            //  Pilih Laporan 
            _buildSectionCard(
              title: 'Pilih Laporan',
              icon: Icons.assignment_outlined,
              child: _LaporanPicker(ctrl: ctrl),
            ),
            const SizedBox(height: 12),

            //  Identitas Alat 
            _buildSectionCard(
              title: 'Identitas Alat',
              icon: Icons.inventory_2_outlined,
              child: _IdentitasAlatSection(ctrl: ctrl),
            ),
            const SizedBox(height: 12),

            //  Analisa Masalah 
            _buildSectionCard(
              title: 'Analisa Masalah',
              icon: Icons.search_outlined,
              child: _TextAreaField(
                controller: ctrl.analisaMasalahCtrl,
                hint:
                    'Tuliskan hasil diagnosa dan temuan teknis secara lengkap...',
                minLines: 5,
              ),
            ),
            const SizedBox(height: 12),

            //  Rekomendasi Perbaikan 
            _buildSectionCard(
              title: 'Rekomendasi Perbaikan',
              icon: Icons.build_outlined,
              child: _TextAreaField(
                controller: ctrl.rekomendasiPerbaikanCtrl,
                hint: 'Tuliskan tindakan perbaikan yang direkomendasikan...',
                minLines: 4,
              ),
            ),
            const SizedBox(height: 12),

            //  Rekomendasi Tempat Perbaikan 
            _buildSectionCard(
              title: 'Rekomendasi Tempat Perbaikan',
              icon: Icons.location_on_outlined,
              child: _TextAreaField(
                controller: ctrl.rekomendasiTempatCtrl,
                hint: 'Contoh: Bengkel TK POLBAN / Service Center Resmi...',
                minLines: 3,
              ),
            ),
            const SizedBox(height: 12),

            //  Info Tambahan (opsional) 
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

  PreferredSizeWidget _buildAppBar(
    AnalisaKerusakanController ctrl,
    BuildContext context,
  ) {
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
            'Formulir Analisa',
            style: TextStyle(
              color: _primary,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Analisa Masalah Kerusakan',
            style: TextStyle(color: Colors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }

  /// Kop surat bergaya formulir POLBAN
  Widget _buildFormHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Kop atas
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo POLBAN
                Container(
                  width: 80,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'POLBAN',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: _primary,
                        ),
                      ),
                    ],
                  ),
                ),
                // Judul
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'JURUSAN TEKNIK KOMPUTER',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: _primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'POLITEKNIK NEGERI BANDUNG',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                            color: _primary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: Colors.grey.shade300),

          // Sub-header: FORMULIR | ANALISA MASALAH KERUSAKAN
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 80,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      right: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'FORMULIR',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                        color: _primary,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: const Center(
                      child: Text(
                        'ANALISA MASALAH KERUSAKAN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: _primary,
                        ),
                        textAlign: TextAlign.center,
                      ),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header â€” mirip label tabel di surat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: _primary.withOpacity(0.05),
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: _primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _primary,
                    decoration: TextDecoration.underline,
                  ),
                ),
                if (isOptional) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 7,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Opsional',
                      style: TextStyle(fontSize: 9, color: Colors.grey),
                    ),
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

  Widget _buildBottomBar(
    BuildContext context,
    AnalisaKerusakanController ctrl,
  ) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Obx(
        () => Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: ctrl.isSubmitting.value
                    ? null
                    : () {
                        ctrl.resetForm();
                        Navigator.pop(context);
                      },
                style: OutlinedButton.styleFrom(
                  foregroundColor: _primary,
                  side: const BorderSide(color: _primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Batal'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: ctrl.isSubmitting.value
                    ? null
                    : () async {
                        final success = await ctrl.submitAnalisa();
                        if (success && context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: ctrl.isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save_outlined, size: 18),
                          SizedBox(width: 8),
                          Text(
                            'Simpan Formulir',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//  Laporan Picker 

class _LaporanPicker extends StatelessWidget {
  final AnalisaKerusakanController ctrl;
  const _LaporanPicker({required this.ctrl});

  static const Color _primary = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final belum = ctrl.laporanBelumDianalisa;
      if (belum.isEmpty) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Colors.green.shade600,
                size: 18,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Semua laporan aktif sudah memiliki analisa',
                  style: TextStyle(color: Colors.green, fontSize: 12),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Selected display
          if (ctrl.selectedLaporan.value != null)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: _primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: _primary.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.assignment_turned_in_outlined,
                    color: _primary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ctrl.selectedLaporan.value!.judul,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: _primary,
                          ),
                        ),
                        Text(
                          ctrl.selectedLaporan.value!.lokasi,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Daftar laporan
          ...belum.map(
            (lap) => _LaporanTile(
              laporan: lap,
              isSelected: ctrl.selectedLaporan.value?.id == lap.id,
              onTap: () => ctrl.setLaporan(lap),
            ),
          ),
        ],
      );
    });
  }
}

class _LaporanTile extends StatelessWidget {
  final LaporanSingkat laporan;
  final bool isSelected;
  final VoidCallback onTap;

  const _LaporanTile({
    required this.laporan,
    required this.isSelected,
    required this.onTap,
  });

  static const Color _primary = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? _primary.withOpacity(0.08) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? _primary : Colors.grey.shade200,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: laporan.id,
              groupValue: isSelected ? laporan.id : null,
              onChanged: (_) => onTap(),
              activeColor: _primary,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    laporan.judul,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: isSelected ? _primary : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 11,
                        color: Colors.grey.shade500,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          laporan.lokasi,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
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
      ),
    );
  }
}

//  Identitas Alat Section 

class _IdentitasAlatSection extends StatelessWidget {
  final AnalisaKerusakanController ctrl;
  const _IdentitasAlatSection({required this.ctrl});

  static const Color _primary = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //  Dasar Pemeriksaan 
        _FormRow(
          label: 'Dasar Pemeriksaan',
          child: Obx(
            () => Wrap(
              spacing: 12,
              children: DasarPemeriksaan.values.map((d) {
                final sel = ctrl.dasarPemeriksaan.value == d;
                return GestureDetector(
                  onTap: () => ctrl.setDasarPemeriksaan(d),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Radio<DasarPemeriksaan>(
                        value: d,
                        groupValue: ctrl.dasarPemeriksaan.value,
                        onChanged: (_) => ctrl.setDasarPemeriksaan(d),
                        activeColor: _primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      ),
                      Text(
                        d.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                          color: sel ? _primary : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        const _FormDivider(),

        //  Nama Alat 
        _FormRow(
          label: 'Nama Alat',
          child: _InlineTextField(
            controller: ctrl.namaAlatCtrl,
            hint: 'Contoh: Proyektor Epson EB-X41',
          ),
        ),

        const _FormDivider(),

        //  Kode Alat 
        _FormRow(
          label: 'Kode Alat',
          child: _InlineTextField(
            controller: ctrl.kodeAlatCtrl,
            hint: 'Contoh: PRY-LAB-C-001',
          ),
        ),

        const _FormDivider(),

        //  No. Inventaris 
        _FormRow(
          label: 'No. Inventaris',
          child: _InlineTextField(
            controller: ctrl.noInventarisCtrl,
            hint: 'Contoh: INV/2021/PRY/003',
          ),
        ),

        const _FormDivider(),

        //  Lokasi (otomatis dari laporan) 
        Obx(
          () => _FormRow(
            label: 'Lokasi',
            child: ctrl.selectedLaporan.value != null
                ? Text(
                    ctrl.selectedLaporan.value!.lokasi,
                    style: const TextStyle(
                      fontSize: 13,
                      color: _primary,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                : Text(
                    'â€” (pilih laporan terlebih dahulu)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
                  ),
          ),
        ),

        const _FormDivider(),

        //  No. Kerusakan 
        _FormRow(
          label: 'No. Kerusakan',
          child: _InlineTextField(
            controller: ctrl.noKerusakanCtrl,
            hint: 'Contoh: KRS-2024-0042',
          ),
        ),
      ],
    );
  }
}

//  Informasi Tambahan (opsional) 

class _InfoTambahanSection extends StatelessWidget {
  final AnalisaKerusakanController ctrl;
  const _InfoTambahanSection({required this.ctrl});

  static const Color _primary = Color(0xFF1E3A5F);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Kategori Kerusakan
        const Text(
          'Kategori Kerusakan',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: KategoriKerusakan.values.map((k) {
              final sel = ctrl.kategoriKerusakan.value == k;
              return GestureDetector(
                onTap: () => ctrl.setKategoriKerusakan(k),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? _primary : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: sel ? _primary : Colors.grey.shade200,
                    ),
                  ),
                  child: Text(
                    k.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: sel ? Colors.white : Colors.grey.shade600,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        // Tingkat Kerusakan
        const Text(
          'Tingkat Kerusakan',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 6),
        Obx(
          () => Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TingkatKerusakan.values.map((t) {
              final sel = ctrl.tingkatKerusakan.value == t;
              final color = _tingkatColor(t);
              return GestureDetector(
                onTap: () => ctrl.setTingkatKerusakan(t),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: sel ? color.withOpacity(0.12) : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: sel ? color : Colors.grey.shade200,
                      width: sel ? 1.5 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.label,
                        style: TextStyle(
                          fontSize: 12,
                          color: sel ? color : Colors.grey.shade600,
                          fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      Text(
                        t.deskripsi,
                        style: TextStyle(
                          fontSize: 9,
                          color: sel
                              ? color.withOpacity(0.8)
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 14),

        // Estimasi Waktu & Biaya
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimasi Hari',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  _InlineTextField(
                    controller: ctrl.estimasiHariCtrl,
                    hint: 'Hari',
                    keyboardType: TextInputType.number,
                    suffix: 'hari',
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimasi Biaya',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  _InlineTextField(
                    controller: ctrl.estimasiBiayaCtrl,
                    hint: '0',
                    keyboardType: TextInputType.number,
                    prefix: 'Rp',
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Color _tingkatColor(TingkatKerusakan t) {
    switch (t) {
      case TingkatKerusakan.ringan:
        return Colors.green;
      case TingkatKerusakan.sedang:
        return Colors.orange;
      case TingkatKerusakan.berat:
        return Colors.red;
      case TingkatKerusakan.total:
        return Colors.red.shade900;
    }
  }
}

//  Helper Widgets 

/// Row dengan label kiri (seperti tabel surat) + konten kanan
class _FormRow extends StatelessWidget {
  final String label;
  final Widget child;

  const _FormRow({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Text(
            ': ',
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _FormDivider extends StatelessWidget {
  const _FormDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(height: 12, color: Colors.grey.shade100);
  }
}

/// Input satu baris (digunakan dalam _FormRow)
class _InlineTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final String? prefix;
  final String? suffix;

  const _InlineTextField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    this.prefix,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        prefixText: prefix != null ? '$prefix ' : null,
        prefixStyle: const TextStyle(fontSize: 13, color: Colors.black54),
        suffixText: suffix,
        suffixStyle: const TextStyle(fontSize: 12, color: Colors.grey),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 6, horizontal: 0),
        border: InputBorder.none,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1E3A5F), width: 1.5),
        ),
      ),
    );
  }
}

/// Textarea multi-baris (Analisa Masalah, Rekomendasi)
class _TextAreaField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int minLines;

  const _TextAreaField({
    required this.controller,
    required this.hint,
    this.minLines = 4,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: minLines,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      style: const TextStyle(fontSize: 13, height: 1.6),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        isDense: true,
        contentPadding: EdgeInsets.zero,
        border: InputBorder.none,
      ),
    );
  }
}
