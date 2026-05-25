import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/profile/view/role_profile_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_button.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';
import '../controller/home_controller.dart';

class HomeDosenView extends StatelessWidget {
  const HomeDosenView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeDosenController());

    return Scaffold(
      appBar: const AppSimpleAppBar(title: 'Home Dosen'),
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
              const SizedBox(height: 16),
              AppButton(
                label: 'Buka Profil Dosen',
                leadingIcon: Icons.person_rounded,
                variant: AppButtonVariant.navy,
                fullWidth: false,
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const RoleProfileView(role: 'dosen'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
