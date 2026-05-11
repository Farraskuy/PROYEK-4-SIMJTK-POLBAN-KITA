// lib/modules/laporan_fasilitas/view/lapor_fasilitas_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/lapor_fasilitas_controller.dart';

// ============================================================
// DESIGN TOKENS
// ============================================================
class _AppColors {
  static const primary = Color(0xFF1A3A6B);
  static const primaryLight = Color(0xFF2B5BAE);
  static const surface = Color(0xFFF5F7FA);
  static const cardBg = Color(0xFFFFFFFF);
  static const inputBorder = Color(0xFFDDE3EF);
  static const inputFocused = Color(0xFF1A3A6B);
  static const inputError = Color(0xFFD32F2F);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textLight = Color(0xFFB0B8CC);
  static const uploadBg = Color(0xFFF0F4FF);
  static const uploadBorder = Color(0xFFB0C0E0);
}

// ============================================================
// LAPOR FASILITAS VIEW
// ============================================================
class LaporFasilitasView extends StatelessWidget {
  const LaporFasilitasView({super.key});

  @override
  Widget build(BuildContext context) {
    // Inisialisasi controller[cite: 10, 27]
    final controller = Get.put(LaporFasilitasController());

    return Scaffold(
      backgroundColor: _AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: _AppColors.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lapor Kerusakan',
          style: TextStyle(
            color: _AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPageHeader(controller),
                const SizedBox(height: 24),

                // FIELD: JUDUL LAPORAN
                _FormFieldWrapper(
                  label: 'Judul Laporan',
                  isRequired: true,
                  child: _StyledTextField(
                    controller: controller.judulController,
                    hintText: 'Contoh: AC Mati, Lampu Berkedip',
                  ),
                ),
                const SizedBox(height: 16),

                // FIELD: LOKASI / RUANGAN
                _FormFieldWrapper(
                  label: 'Lokasi / Ruangan',
                  isRequired: true,
                  child: _StyledTextField(
                    controller: controller.lokasiController,
                    hintText: 'Contoh: Lab Komputer 2, Gedung A',
                  ),
                ),
                const SizedBox(height: 16),

                // FIELD: DESKRIPSI MASALAH
                _FormFieldWrapper(
                  label: 'Deskripsi Kerusakan',
                  isRequired: true,
                  child: _StyledTextField(
                    controller: controller.deskripsiController,
                    hintText: 'Jelaskan detail kerusakan yang ditemukan...',
                    maxLines: 4,
                  ),
                ),
                const SizedBox(height: 16),

                // FIELD: UNGGAH FOTO (OPSIONAL)[cite: 5]
                _buildUnggahFoto(controller),
                const SizedBox(height: 32),

                // TOMBOL KIRIM
                _buildSubmitButton(context, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPageHeader(LaporFasilitasController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          controller.pageTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: _AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Lengkapi formulir di bawah ini agar teknisi dapat segera menangani masalah fasilitas.',
          style: TextStyle(
            fontSize: 13,
            color: _AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildUnggahFoto(LaporFasilitasController controller) {
    return _FormFieldWrapper(
      label: 'Unggah Foto (Opsional)',
      child: GestureDetector(
        onTap: () {
          // Logika ambil foto[cite: 5, 12]
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 24),
          decoration: BoxDecoration(
            color: _AppColors.uploadBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _AppColors.uploadBorder, width: 1.2),
          ),
          child: const Column(
            children: [
              Icon(
                Icons.add_photo_alternate_outlined,
                size: 36,
                color: _AppColors.primaryLight,
              ),
              SizedBox(height: 8),
              Text(
                'Klik untuk Ambil Gambar',
                style: TextStyle(
                  fontSize: 13,
                  color: _AppColors.primaryLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton(
    BuildContext context,
    LaporFasilitasController controller,
  ) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 52,
          child: ElevatedButton(
            onPressed: controller.isSubmitting.value
                ? null
                : () async {
                    final success = await controller.onSubmitLaporan();
                    if (success && context.mounted) {
                      Navigator.pop(context, true);
                    }
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: _AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isSubmitting.value
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  controller.submitButtonLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }
}

// ============================================================
// REUSABLE WIDGETS
// ============================================================

class _FormFieldWrapper extends StatelessWidget {
  final String label;
  final bool isRequired;
  final Widget child;

  const _FormFieldWrapper({
    required this.label,
    required this.child,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _AppColors.textPrimary,
            ),
            children: isRequired
                ? const [
                    TextSpan(
                      text: ' *',
                      style: TextStyle(color: _AppColors.inputError),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: _AppColors.textLight, fontSize: 14),
        filled: true,
        fillColor: _AppColors.cardBg,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: _AppColors.inputBorder,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: _AppColors.inputFocused,
            width: 1.8,
          ),
        ),
      ),
    );
  }
}
