import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/lapor_fasilitas_controller.dart';
import '../model/lapor_fasilitas_model.dart';

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
  static const divider = Color(0xFFE5E9F2);
  static const navActive = Color(0xFF1A3A6B);
  static const navInactive = Color(0xFF9CA3AF);
  static const buttonText = Color(0xFFFFFFFF);
  static const fotoChipBg = Color(0xFFE8EDF5);
}

// ============================================================
// LAPOR FASILITAS VIEW
// ============================================================
class LaporFasilitasView extends StatelessWidget {
  const LaporFasilitasView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LaporFasilitasController());

    return Scaffold(
      backgroundColor: _AppColors.surface,
      appBar: _buildAppBar(controller),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---- JUDUL & DESKRIPSI HALAMAN ----
                _buildPageHeader(controller),
                const SizedBox(height: 28),

                // ---- FIELD: KATEGORI LAPORAN ----
                _buildKategoriDropdown(controller),
                const SizedBox(height: 16),

                // ---- FIELD: LOKASI / RUANGAN ----
                _buildLokasiField(controller),
                const SizedBox(height: 16),

                // ---- FIELD: DESKRIPSI MASALAH ----
                _buildDeskripsiField(controller),
                const SizedBox(height: 16),

                // ---- FIELD: UNGGAH FOTO ----
                _buildUnggahFoto(controller),
                const SizedBox(height: 32),

                // ---- TOMBOL KIRIM ----
                _buildSubmitButton(controller),
                const SizedBox(height: 14),

                // ---- BATAL & KEMBALI ----
                _buildBatalButton(controller),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================
  PreferredSizeWidget _buildAppBar(LaporFasilitasController controller) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded,
            color: _AppColors.textPrimary, size: 22),
        onPressed: controller.onBatalKembali,
      ),
      title: const Text(
        'Academic Monolith',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: _AppColors.textPrimary,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined,
              color: _AppColors.textPrimary, size: 24),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: CircleAvatar(
            radius: 17,
            backgroundColor: _AppColors.primary,
            child: const Icon(Icons.person, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }

  // ============================================================
  // PAGE HEADER
  // ============================================================
  Widget _buildPageHeader(LaporFasilitasController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text(
              controller.pageTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _AppColors.textPrimary,
                height: 1.25,
              ),
            )),
        const SizedBox(height: 8),
        const Text(
          'Silakan lengkapi formulir di bawah ini untuk melaporkan masalah atau kerusakan pada fasilitas kampus.',
          style: TextStyle(
            fontSize: 13,
            color: _AppColors.textSecondary,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  // ============================================================
  // KATEGORI DROPDOWN
  // ============================================================
  Widget _buildKategoriDropdown(LaporFasilitasController controller) {
    return Obx(() => _FormFieldWrapper(
          label: 'Kategori Laporan',
          isRequired: true,
          errorText: controller.errorKategori.value,
          child: Container(
            decoration: BoxDecoration(
              color: _AppColors.cardBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: controller.errorKategori.value.isNotEmpty
                    ? _AppColors.inputError
                    : _AppColors.inputBorder,
                width: 1.2,
              ),
            ),
            child: controller.isLoadingKategori.value
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: _AppColors.primary),
                        ),
                        SizedBox(width: 12),
                        Text('Memuat kategori...',
                            style: TextStyle(
                                color: _AppColors.textLight, fontSize: 14)),
                      ],
                    ),
                  )
                : DropdownButtonHideUnderline(
                    child: DropdownButton<KategoriFasilitasModel>(
                      value: controller.selectedKategori.value,
                      isExpanded: true,
                      hint: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: Text(
                          'Pilih Kategori...',
                          style: TextStyle(
                            color: _AppColors.textLight,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      borderRadius: BorderRadius.circular(10),
                      icon: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(Icons.keyboard_arrow_down_rounded,
                            color: _AppColors.textSecondary),
                      ),
                      items: controller.kategoriList.map((kat) {
                        return DropdownMenuItem<KategoriFasilitasModel>(
                          value: kat,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              kat.namaKategori,
                              style: const TextStyle(
                                fontSize: 14,
                                color: _AppColors.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: controller.onKategoriSelected,
                    ),
                  ),
          ),
        ));
  }

  // ============================================================
  // LOKASI FIELD
  // ============================================================
  Widget _buildLokasiField(LaporFasilitasController controller) {
    return Obx(() => _FormFieldWrapper(
          label: 'Lokasi / Ruangan',
          isRequired: true,
          errorText: controller.errorLokasi.value,
          child: _StyledTextField(
            controller: controller.lokasiController,
            hintText: 'Contoh: Lab Komputer 2, Gedung A',
            hasError: controller.errorLokasi.value.isNotEmpty,
            textInputAction: TextInputAction.next,
          ),
        ));
  }

  // ============================================================
  // DESKRIPSI FIELD
  // ============================================================
  Widget _buildDeskripsiField(LaporFasilitasController controller) {
    return Obx(() => _FormFieldWrapper(
          label: 'Deskripsi Masalah',
          isRequired: true,
          errorText: controller.errorDeskripsi.value,
          child: _StyledTextField(
            controller: controller.deskripsiController,
            hintText:
                'Jelaskan secara detail masalah yang\nAnda temukan...',
            hasError: controller.errorDeskripsi.value.isNotEmpty,
            maxLines: 5,
            maxLength: LaporFasilitasController.maxDeskripsiLength,
            textInputAction: TextInputAction.done,
          ),
        ));
  }

  // ============================================================
  // UNGGAH FOTO
  // ============================================================
  Widget _buildUnggahFoto(LaporFasilitasController controller) {
    return _FormFieldWrapper(
      label: 'Unggah Foto (Opsional)',
      child: Obx(() {
        final paths = controller.selectedFotoPaths;
        return Column(
          children: [
            // Area upload utama
            GestureDetector(
              onTap: () => _showFotoOptions(controller),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24),
                decoration: BoxDecoration(
                  color: _AppColors.uploadBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _AppColors.uploadBorder,
                    style: BorderStyle.solid,
                    width: 1.2,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 36,
                      color: _AppColors.primaryLight,
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'Klik untuk unggah ',
                            style: TextStyle(
                              color: _AppColors.primaryLight,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: 'Atau Ambil Gambar',
                            style: TextStyle(color: _AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'PNG, JPG, GIF hingga 5MB',
                      style: TextStyle(
                        fontSize: 11,
                        color: _AppColors.textLight,
                      ),
                    ),
                    if (paths.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${paths.length}/${LaporFasilitasController.maxFoto} foto dipilih',
                        style: const TextStyle(
                          fontSize: 11,
                          color: _AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Chip preview foto yang sudah dipilih
            if (paths.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(paths.length, (index) {
                  return _FotoChip(
                    label: paths[index],
                    onRemove: () => controller.onRemoveFoto(index),
                  );
                }),
              ),
            ],
          ],
        );
      }),
    );
  }

  void _showFotoOptions(LaporFasilitasController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: _AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Pilih Foto',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: _AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              _BottomSheetOption(
                icon: Icons.photo_library_outlined,
                label: 'Pilih dari Galeri',
                onTap: () {
                  Get.back();
                  controller.onPickFoto();
                },
              ),
              const Divider(height: 1, color: _AppColors.divider),
              _BottomSheetOption(
                icon: Icons.camera_alt_outlined,
                label: 'Ambil Foto',
                onTap: () {
                  Get.back();
                  controller.onTakeFoto();
                },
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Batal',
                      style: TextStyle(color: _AppColors.textSecondary)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // SUBMIT BUTTON
  // ============================================================
  Widget _buildSubmitButton(LaporFasilitasController controller) {
    return Obx(() => SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed:
                controller.isSubmitting.value ? null : controller.onSubmitLaporan,
            style: ElevatedButton.styleFrom(
              backgroundColor: _AppColors.primary,
              disabledBackgroundColor: _AppColors.primary.withOpacity(0.6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            icon: controller.isSubmitting.value
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.send_rounded,
                    color: Colors.white, size: 18),
            label: Text(
              controller.isSubmitting.value
                  ? 'Mengirim...'
                  : controller.submitButtonLabel,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ));
  }

  // ============================================================
  // BATAL BUTTON
  // ============================================================
  Widget _buildBatalButton(LaporFasilitasController controller) {
    return Center(
      child: TextButton(
        onPressed: controller.onBatalKembali,
        child: const Text(
          'Batal & Kembali',
          style: TextStyle(
            fontSize: 14,
            color: _AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ============================================================
  // BOTTOM NAVIGATION BAR (Layanan aktif)
  // ============================================================
  Widget _buildBottomNavBar() {
    const items = [
      {'label': 'HOME', 'icon': Icons.home_rounded, 'index': 0},
      {'label': 'LAYANAN', 'icon': Icons.grid_view_rounded, 'index': 1},
      {'label': 'ASPIRASI', 'icon': Icons.campaign_rounded, 'index': 2},
      {'label': 'PROFIL', 'icon': Icons.person_rounded, 'index': 3},
    ];
    const activeIndex = 1; // Layanan aktif

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: items.map((item) {
              final isActive = item['index'] == activeIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!isActive) Get.back();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        item['icon'] as IconData,
                        size: 24,
                        color: isActive
                            ? _AppColors.navActive
                            : _AppColors.navInactive,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isActive
                              ? _AppColors.navActive
                              : _AppColors.navInactive,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REUSABLE WIDGETS
// ============================================================

/// Wrapper label + error untuk setiap field
class _FormFieldWrapper extends StatelessWidget {
  final String label;
  final bool isRequired;
  final String? errorText;
  final Widget child;

  const _FormFieldWrapper({
    required this.label,
    required this.child,
    this.isRequired = false,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
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
                    )
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 8),
        child,
        // Error text
        if (errorText != null && errorText!.isNotEmpty) ...[
          const SizedBox(height: 5),
          Row(
            children: [
              const Icon(Icons.info_outline_rounded,
                  size: 13, color: _AppColors.inputError),
              const SizedBox(width: 4),
              Text(
                errorText!,
                style: const TextStyle(
                  fontSize: 11,
                  color: _AppColors.inputError,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

/// TextField dengan styling konsisten
class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final bool hasError;
  final int maxLines;
  final int? maxLength;
  final TextInputAction textInputAction;

  const _StyledTextField({
    required this.controller,
    required this.hintText,
    this.hasError = false,
    this.maxLines = 1,
    this.maxLength,
    this.textInputAction = TextInputAction.next,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      maxLength: maxLength,
      textInputAction: textInputAction,
      style: const TextStyle(
        fontSize: 14,
        color: _AppColors.textPrimary,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: _AppColors.textLight,
          fontSize: 14,
        ),
        filled: true,
        fillColor: _AppColors.cardBg,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        counterText: maxLength != null ? null : '',
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? _AppColors.inputError : _AppColors.inputBorder,
            width: 1.2,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: hasError ? _AppColors.inputError : _AppColors.inputFocused,
            width: 1.8,
          ),
        ),
      ),
    );
  }
}

/// Chip foto yang bisa dihapus
class _FotoChip extends StatelessWidget {
  final String label;
  final VoidCallback onRemove;

  const _FotoChip({required this.label, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    // Tampilkan nama file saja (bukan path penuh)
    final shortName = label.split('/').last;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _AppColors.fotoChipBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _AppColors.uploadBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.image_outlined,
              size: 14, color: _AppColors.primary),
          const SizedBox(width: 5),
          Text(
            shortName,
            style: const TextStyle(
              fontSize: 11,
              color: _AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 5),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded,
                size: 14, color: _AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

/// Item opsi di bottom sheet foto
class _BottomSheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomSheetOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: _AppColors.primary),
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          color: _AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }
}