import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import '../model/log_harian_teknis_model.dart'; 

class LogHarianTeknisController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final isSubmitting = false.obs;

  final isEditing = false.obs;
  String? editingId;

  final selectedDate = DateTime.now().obs;
  final keteranganCtrl = TextEditingController();

  final RxList<LogHarianTeknisModel> items = <LogHarianTeknisModel>[].obs;

  Future<void> pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1A3A6B)),
        ),
        child: child!,
      ),
    );
    if (picked != null) selectedDate.value = picked;
  }

  Future<void> submit() async {
    if (!formKey.currentState!.validate()) return;
    
    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 400));

    if (isEditing.value && editingId != null) {
      final index = items.indexWhere((e) => e.id == editingId);
      if (index != -1) {
        items[index] = LogHarianTeknisModel(
          id: editingId!,
          teknisiId: items[index].teknisiId,
          tanggal: selectedDate.value,
          keterangan: keteranganCtrl.text,
          syncStatus: LogHarianSyncStatus.local,
          createdAt: items[index].createdAt,
        );
      }
    } else {
      items.insert(
        0,
        LogHarianTeknisModel(
          id: const Uuid().v4(),
          teknisiId: 'TKS001', 
          tanggal: selectedDate.value,
          keterangan: keteranganCtrl.text,
          syncStatus: LogHarianSyncStatus.local,
          createdAt: DateTime.now(),
        ),
      );
    }

    _resetForm();
    isSubmitting.value = false;
    
    Get.snackbar(
      'Berhasil',
      isEditing.value ? 'Log harian diperbarui' : 'Log harian ditambahkan',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade50,
      colorText: Colors.green.shade800,
    );
  }

  void prepareUpdate(LogHarianTeknisModel log) {
    isEditing.value = true;
    editingId = log.id;
    selectedDate.value = log.tanggal;
    keteranganCtrl.text = log.keterangan;
  }

  void deleteLog(String id) {
    items.removeWhere((e) => e.id == id);
    if (editingId == id) _resetForm(); 
  }

  void cancelEdit() => _resetForm();

  void _resetForm() {
    isEditing.value = false;
    editingId = null;
    keteranganCtrl.clear();
    selectedDate.value = DateTime.now();
  }

  @override
  void onClose() {
    keteranganCtrl.dispose();
    super.onClose();
  }
}