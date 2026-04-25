import '../model/selesaikan_tugas_model.dart';

class SelesaikanTugasService {
  // TODO: Ganti dengan Dio/http call ke API

  Future<void> submitPenyelesaian(SelesaikanTugasModel data) async {
    // TODO:
    // 1. Upload fotoBuktiPaths ke storage (Firebase / S3)
    // 2. PATCH /laporan/{id}/resolve dengan catatan, durasi, dan url foto
    // 3. Jika offline → simpan ke SyncQueue (Hive) untuk auto-sync
    await Future.delayed(const Duration(seconds: 1));
  }
}
