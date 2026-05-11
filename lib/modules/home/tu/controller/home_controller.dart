import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../laporan_fasilitas/view/laporan_fasilitas_mahasiswa_view.dart';
import '../model/home_model.dart';

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

  void onNavTapped(BuildContext context, int index) {
    selectedNavIndex.value = index;
    if (index == 1 || index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LaporanFasilitasMahasiswaView(role: 'tu'),
        ),
      );
      return;
    }
    if (index != 0) {
      Get.snackbar('Navigasi TU', 'Menu ini sedang disiapkan.');
    }
  }

  void onQuickAction(BuildContext context, String label) {
    if (label == 'Surat Keterangan' || label == 'Arsip Layanan') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const LaporanFasilitasMahasiswaView(role: 'tu'),
        ),
      );
      return;
    }
    Get.snackbar('Akses Cepat', 'Menu $label sedang disiapkan.');
  }
}
