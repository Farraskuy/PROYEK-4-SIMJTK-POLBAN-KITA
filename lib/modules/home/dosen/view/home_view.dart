import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/home_controller.dart';

class HomeDosenView extends StatelessWidget {
  const HomeDosenView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeDosenController());

    return Scaffold(
      appBar: AppBar(title: const Text('Home Dosen')),
      body: Center(
        child: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                controller.state.value.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(controller.state.value.subtitle),
            ],
          ),
        ),
      ),
    );
  }
}
