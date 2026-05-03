import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/log_harian_teknis_controller.dart';

class LogHarianTeknisView extends StatelessWidget {
  const LogHarianTeknisView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LogHarianTeknisController());

    return Scaffold(
      appBar: AppBar(title: const Text('Log Harian Teknis')),
      body: Center(
        child: Obx(
          () => Text(
            'Jumlah log: ${controller.items.length}',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
      ),
    );
  }
}