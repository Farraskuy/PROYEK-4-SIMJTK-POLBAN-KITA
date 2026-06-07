import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/service/aspirasi_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_service.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';

class AdminDashboardController extends GetxController {
  final LaporanFasilitasService _laporanService = LaporanFasilitasService();
  final AspirasiService _aspirasiService = AspirasiService();

  UserModel? get user => AuthService().currentUser;

  final RxString adminName = 'Admin'.obs;
  final RxBool isLoading = false.obs;

  final RxInt totalLaporan = 0.obs;
  final RxInt laporanAktif = 0.obs;
  final RxInt laporanSelesai = 0.obs;
  final RxInt totalAspirasi = 0.obs;
  final RxInt aspirasiBelumDitanggapi = 0.obs;
  final RxInt aspirasiDitanggapi = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    isLoading.value = true;
    try {
      final user =
          AuthService().currentUser ?? await AuthService().loadSavedSession();
      adminName.value = user?.name.isNotEmpty == true ? user!.name : 'Admin';

      final results = await Future.wait([
        _laporanService.getAll(),
        _aspirasiService.fetchAllAspirasi(),
      ]);

      final laporan = results[0] as List<LaporanFasilitasModel>;
      final aspirasi = results[1] as List<AspirasiModel>;

      totalLaporan.value = laporan.length;
      laporanSelesai.value = laporan
          .where((item) => item.status == StatusLaporan.resolved)
          .length;
      laporanAktif.value = laporan
          .where(
            (item) =>
                item.status != StatusLaporan.resolved &&
                item.status != StatusLaporan.cancelled,
          )
          .length;

      totalAspirasi.value = aspirasi.length;
      aspirasiDitanggapi.value = aspirasi
          .where((item) => item.status == StatusAspirasi.responded)
          .length;
      aspirasiBelumDitanggapi.value =
          aspirasi.length - aspirasiDitanggapi.value;
    } catch (_) {
      Get.snackbar('Gagal', 'Dashboard admin tidak dapat dimuat.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRefresh() => loadDashboardData();

  String get sapaanAdmin {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }
}
