import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'modules/home_screen/view/home_view.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: const HomeView(),
    );
  }
}
