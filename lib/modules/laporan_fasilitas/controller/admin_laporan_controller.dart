// modules/laporan_fasilitas/controller/admin_laporan_controller.dart
import 'package:get/get.dart';
import '../model/laporan_fasilitas_model.dart';
import '../service/laporan_fasilitas_service.dart';

class AdminLaporanController extends GetxController {
  final LaporanFasilitasService _service = LaporanFasilitasService();
  final RxList<LaporanFasilitasModel> laporanList = <LaporanFasilitasModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLaporan();
  }

  Future<void> fetchLaporan() async {
    isLoading.value = true;
    try {
      // Menggunakan method yang sudah ada di service Anda
      final data = await _service.fetchAll(); 
      laporanList.assignAll(data);
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data: $e');
    } finally {
      isLoading.value = false;
    }
  }
}