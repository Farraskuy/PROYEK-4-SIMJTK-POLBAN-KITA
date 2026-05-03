import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/kategori_fasilitas_controller.dart';

class KategoriFasilitasView extends StatelessWidget {
  const KategoriFasilitasView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(KategoriFasilitasController());

    return Scaffold(
      appBar: AppBar(title: const Text('Kategori Fasilitas')),
      body: Obx(
        () => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: controller.items.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final item = controller.items[index];
            return ListTile(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              tileColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              title: Text(item.namaKategori),
              subtitle: Text(item.deskripsi),
            );
          },
        ),
      ),
    );
  }
}