import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/controller/aspirasi_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_page_header.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';

class AspirasiCreateView extends StatefulWidget {
  const AspirasiCreateView({super.key});

  @override
  State<AspirasiCreateView> createState() => _AspirasiCreateViewState();
}

class _AspirasiCreateViewState extends State<AspirasiCreateView> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<AspirasiController>();
    controller.prepareCreateForm();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AspirasiController>();
    return _AspirasiFormScaffold(
      controller: controller,
      title: 'Tambah Aspirasi',
      description:
          'Tulis aspirasi, kritik, atau saran untuk perbaikan lingkungan akademik.',
      submitLabel: 'Post Aspirasi',
      onSubmit: () async {
        await controller.submitAspirasi();
        if (context.mounted) Navigator.pop(context, true);
      },
    );
  }
}

class AspirasiEditView extends StatefulWidget {
  const AspirasiEditView({super.key, required this.aspirasi});

  final AspirasiModel aspirasi;

  @override
  State<AspirasiEditView> createState() => _AspirasiEditViewState();
}

class _AspirasiEditViewState extends State<AspirasiEditView> {
  @override
  void initState() {
    super.initState();
    final controller = Get.find<AspirasiController>();
    controller.prepareEditForm(widget.aspirasi);
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AspirasiController>();
    return _AspirasiFormScaffold(
      controller: controller,
      title: 'Edit Aspirasi',
      description:
          'Ubah isi aspirasi Anda tanpa mengubah alur tampilan halaman list.',
      submitLabel: 'Simpan Perubahan',
      onSubmit: () async {
        await controller.submitAspirasi();
        if (context.mounted) Navigator.pop(context, true);
      },
    );
  }
}

class _AspirasiFormScaffold extends StatelessWidget {
  const _AspirasiFormScaffold({
    required this.controller,
    required this.title,
    required this.description,
    required this.submitLabel,
    required this.onSubmit,
  });

  final AspirasiController controller;
  final String title;
  final String description;
  final String submitLabel;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppSimpleAppBar(
        title: title,
        subtitle: 'Mahasiswa JTK',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.title,
              size: 24,
            ),
            onPressed: controller.onNotificationTapped,
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppPageHeader(
                title: 'Aspirasi Mahasiswa',
                description:
                    'Tulis aspirasi dengan singkat, jelas, dan tetap konstruktif.',
                padding: EdgeInsets.fromLTRB(4, 8, 4, 18),
              ),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border, width: 1),
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
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: Text(
                        'DETAIL ASPIRASI',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.muted,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    Obx(
                      () => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: TextField(
                          controller: controller.isiSaranController,
                          maxLines: 8,
                          maxLength: AspirasiController.maxIsiSaranLength,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.title,
                            height: 1.5,
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Jelaskan aspirasi Anda secara detail dan konstruktif...',
                            hintStyle: const TextStyle(
                              color: AppColors.muted,
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            counterText: controller.isiSaranCounter,
                            counterStyle: const TextStyle(
                              fontSize: 11,
                              color: AppColors.muted,
                            ),
                            errorText: controller.errorIsiSaran.value.isEmpty
                                ? null
                                : controller.errorIsiSaran.value,
                            errorStyle: const TextStyle(
                              fontSize: 11,
                              color: AppColors.danger,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: AppColors.border),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Post as Anonymous',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.title,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Identitas Anda akan disembunyikan.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.body,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: OutlinedButton(
                        onPressed: controller.canHapusForm()
                            ? () => controller.onHapusFormConfirmed()
                            : null,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.danger,
                          side: const BorderSide(
                            color: AppColors.danger,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Hapus',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: Obx(
                      () => SizedBox(
                        height: 50,
                        child: ElevatedButton(
                          onPressed: controller.isSubmitting.value
                              ? null
                              : onSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            disabledBackgroundColor:
                                AppColors.primary.withOpacity(0.6),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 1,
                          ),
                          child: controller.isSubmitting.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  submitLabel,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}