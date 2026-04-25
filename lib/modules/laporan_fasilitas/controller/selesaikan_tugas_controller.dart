import 'package:flutter/material.dart';
import '../model/selesaikan_tugas_model.dart';
import '../service/selesaikan_tugas_service.dart';

class SelesaikanTugasController extends ChangeNotifier {
  final SelesaikanTugasService _service = SelesaikanTugasService();

  final TextEditingController catatanController = TextEditingController();
  final TextEditingController durasiController = TextEditingController();

  List<String> fotoBuktiPaths = [];
  bool isSubmitting = false;
  String? errorMessage;

  bool get isFormValid =>
      catatanController.text.trim().isNotEmpty &&
      fotoBuktiPaths.isNotEmpty &&
      (int.tryParse(durasiController.text) ?? 0) > 0;

  void tambahFoto(String path) {
    fotoBuktiPaths.add(path);
    notifyListeners();
  }

  void hapusFoto(int index) {
    fotoBuktiPaths.removeAt(index);
    notifyListeners();
  }

  Future<bool> submit(String laporanId) async {
    if (!isFormValid) {
      errorMessage = 'Lengkapi semua field dan unggah minimal 1 foto bukti.';
      notifyListeners();
      return false;
    }

    isSubmitting = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _service.submitPenyelesaian(
        SelesaikanTugasModel(
          laporanId: laporanId,
          catatanPengerjaan: catatanController.text,
          fotoBuktiPaths: fotoBuktiPaths,
          durasiMenit: int.parse(durasiController.text),
        ),
      );
      return true;
    } catch (e) {
      errorMessage = 'Gagal menyimpan: $e';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    catatanController.dispose();
    durasiController.dispose();
    super.dispose();
  }
}
