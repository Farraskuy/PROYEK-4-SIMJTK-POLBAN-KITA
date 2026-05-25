// lib/modules/laporan_fasilitas/view/lapor_fasilitas_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';
import '../controller/lapor_fasilitas_controller.dart';
import '../view/vision_view.dart';

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
class LaporFasilitasView extends StatefulWidget {
  const LaporFasilitasView({super.key});

  @override
  State<LaporFasilitasView> createState() => _LaporFasilitasViewState();
}

class _LaporFasilitasViewState extends State<LaporFasilitasView> {
  // Ambil atau daftarkan instance controller menggunakan GetX lifecycle aman
  final LaporFasilitasController controller =
      Get.isRegistered<LaporFasilitasController>()
      ? Get.find<LaporFasilitasController>()
      : Get.put(LaporFasilitasController());

  @override
  void initState() {
    super.initState();
    // Jika TIDAK dalam mode edit (artinya membuat laporan baru), reset seluruh inputan form
    if (!controller.isEditMode.value) {
      controller.judulController.clear();
      controller.lokasiController.clear();
      controller.deskripsiController.clear();
      controller.selectedFotoPaths.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          onPressed: () {
            // Pastikan saat keluar dari form, status edit dikembalikan ke false
            controller.isEditMode.value = false;
            Navigator.pop(context);
          },
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

                // FIELD: UNGGAH FOTO
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () async {
              // Navigasi native Flutter ke halaman VisionView
              final String? resultPath = await Navigator.push<String?>(
                context,
                MaterialPageRoute(builder: (context) => const VisionView()),
              );

              // Masukkan ke controller jika hasil tangkapan kamera valid
              if (resultPath != null && resultPath.isNotEmpty) {
                controller.tambahFotoPath(resultPath);
              }
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
                    Icons.camera_enhance_outlined,
                    size: 36,
                    color: _AppColors.primaryLight,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Klik untuk Ambil Gambar via Vision Camera',
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

          // PREVIEW FOTO YANG TELAH DIAMBIL
          Obx(() {
            if (controller.selectedFotoPaths.isEmpty) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SizedBox(
                height: 90,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.selectedFotoPaths.length,
                  itemBuilder: (context, index) {
                    final path = controller.selectedFotoPaths[index];
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _AppColors.inputBorder),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: path.startsWith('http')
                            ? Image.network(path, fit: BoxFit.cover)
                            : Image.file(File(path), fit: BoxFit.cover),
                      ),
                    );
                  },
                ),
              ),
            );
          }),
        ],
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
                    // Kembalikan nilai true ke halaman list laporan agar otomatis memicu refresh data terbaru
                    controller.isEditMode.value = false;
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
