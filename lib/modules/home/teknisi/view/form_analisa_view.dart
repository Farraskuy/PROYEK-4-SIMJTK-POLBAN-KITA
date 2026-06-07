import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/teknisi/model/analisa_kerusakan_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/tanggapan_tugas_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';

class FormAnalisaView extends StatefulWidget {
  const FormAnalisaView({super.key, required this.laporan});

  final LaporanFasilitasModel laporan;

  @override
  State<FormAnalisaView> createState() => _FormAnalisaViewState();
}

class _FormAnalisaViewState extends State<FormAnalisaView> {
  late final String _tag;
  late final TanggapanTugasController controller;

  @override
  void initState() {
    super.initState();
    _tag = 'tanggapan-${widget.laporan.id}';
    controller = Get.put(TanggapanTugasController(widget.laporan), tag: _tag);
  }

  @override
  void dispose() {
    Get.delete<TanggapanTugasController>(tag: _tag);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppDetailAppBar(
        title: 'Formulir Tanggapan',
        subtitle: 'Tanggapan masalah kerusakan',
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            _Section(
              title: 'Laporan',
              icon: Icons.assignment_outlined,
              child: _ReportSummary(laporan: widget.laporan),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Identitas Alat',
              icon: Icons.inventory_2_outlined,
              child: Column(
                children: [
                  _LineField(
                    label: 'Kode Alat',
                    hint: 'Contoh: PRY-LAB-C-001',
                    controller: controller.kodeAlatController,
                  ),
                  const Divider(height: 24),
                  _LineField(
                    label: 'No. Inventaris',
                    hint: 'Contoh: INV/2021/PRY/003',
                    controller: controller.noInventarisController,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Tanggapan Tugas',
              icon: Icons.chat_bubble_outline_rounded,
              child: _TextArea(
                controller: controller.tanggapanController,
                hint:
                    'Tuliskan hasil diagnosis dan temuan teknis mengenai tugas ini...',
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Perbaikan',
              icon: Icons.build_outlined,
              child: _TextArea(
                controller: controller.perbaikanController,
                hint: 'Tuliskan tindakan perbaikan yang dilakukan...',
              ),
            ),
            const SizedBox(height: 12),
            _Section(
              title: 'Tingkat Kerusakan',
              icon: Icons.info_outline_rounded,
              child: Obx(
                () => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: TingkatKerusakan.values.map((level) {
                    return ChoiceChip(
                      label: Text(level.label),
                      selected: controller.tingkatKerusakan.value == level,
                      onSelected: (_) =>
                          controller.tingkatKerusakan.value = level,
                      selectedColor: AppColors.blueSoft,
                      side: BorderSide(
                        color: controller.tingkatKerusakan.value == level
                            ? AppColors.primary
                            : AppColors.border,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Obx(
              () => Row(
                children: [
                  const Icon(
                    Icons.cloud_done_outlined,
                    size: 16,
                    color: AppColors.body,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    controller.syncLabel.value,
                    style: const TextStyle(color: AppColors.body, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        );
      }),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: const BoxDecoration(
            color: AppColors.surface,
            border: Border(top: BorderSide(color: AppColors.border)),
          ),
          child: Obx(
            () => Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: controller.isSaving.value
                        ? null
                        : () async {
                            final saved = await controller.saveDraft();
                            if (saved && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                    icon: const Icon(Icons.drafts_outlined),
                    label: const Text('Simpan Draft'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: controller.isSaving.value
                        ? null
                        : () async {
                            final completed = await controller.complete();
                            if (completed && context.mounted) {
                              Navigator.pop(context, true);
                            }
                          },
                    icon: controller.isSaving.value
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Selesaikan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.all(14), child: child),
        ],
      ),
    );
  }
}

class _ReportSummary extends StatelessWidget {
  const _ReportSummary({required this.laporan});

  final LaporanFasilitasModel laporan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.assignment_turned_in_outlined,
            color: AppColors.primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  laporan.judul,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.title,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  laporan.lokasi,
                  style: const TextStyle(fontSize: 12, color: AppColors.body),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LineField extends StatelessWidget {
  const _LineField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

class _TextArea extends StatelessWidget {
  const _TextArea({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 5,
      maxLines: null,
      decoration: InputDecoration(hintText: hint, border: InputBorder.none),
    );
  }
}
