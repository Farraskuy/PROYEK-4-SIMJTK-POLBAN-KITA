import 'package:get/get.dart';
import '../model/home_model.dart';

enum HomeTuNavTarget { laporanFasilitas }

class HomeTuController extends GetxController {
  final Rx<TuHomeModel> state = TuHomeModel.placeholder().obs;
  final RxInt selectedNavIndex = 0.obs;
  final RxInt unreadNotif = 2.obs;

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 11) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  void onNotificationTapped() => unreadNotif.value = 0;

  HomeTuNavTarget? onNavTapped(int index) {
    selectedNavIndex.value = index;
    if (index == 1 || index == 2) {
      return HomeTuNavTarget.laporanFasilitas;
    }
    if (index != 0) {
      Get.snackbar('Navigasi TU', 'Menu ini sedang disiapkan.');
    }
    return null;
  }

  HomeTuNavTarget? onQuickAction(String label) {
    if (label == 'Surat Keterangan' || label == 'Arsip Layanan') {
      return HomeTuNavTarget.laporanFasilitas;
    }
    Get.snackbar('Akses Cepat', 'Menu $label sedang disiapkan.');
    return null;
  }
}
