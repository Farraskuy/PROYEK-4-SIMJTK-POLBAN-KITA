import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/controller/add_user_controller.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_button.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_text_field.dart';

class AdminAddUserView extends StatelessWidget {
  const AdminAddUserView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(AdminAddUserController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          const AppSliverDetailAppBar(
            title: 'Tambah User',
            subtitle: 'Kelola akun SIMJTK',
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _UserFormCard(ctrl: ctrl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UserFormCard extends StatelessWidget {
  const _UserFormCard({required this.ctrl});

  final AdminAddUserController ctrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionTitle(
            icon: Icons.badge_rounded,
            title: 'Identitas User',
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: 'Nama Lengkap',
            controller: ctrl.nameController,
            hintText: 'Masukkan nama lengkap',
            prefixIcon: Icons.person_outline_rounded,
            required: true,
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'NIM / NIP / NIDN',
            controller: ctrl.nomorIndukController,
            hintText: 'Contoh: 231511001',
            prefixIcon: Icons.credit_card_rounded,
            keyboardType: TextInputType.text,
            required: true,
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Email',
            controller: ctrl.emailController,
            hintText: 'nama@polban.ac.id',
            prefixIcon: Icons.alternate_email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          AppTextField(
            label: 'Program Studi / Unit',
            controller: ctrl.programStudyController,
            hintText: 'Contoh: D3 Teknik Informatika',
            prefixIcon: Icons.school_outlined,
          ),
          const SizedBox(height: 20),
          const _SectionTitle(
            icon: Icons.verified_user_rounded,
            title: 'Akses Akun',
          ),
          const SizedBox(height: 16),
          Obx(
            () => DropdownButtonFormField<String>(
              initialValue: ctrl.selectedRole.value,
              decoration: _inputDecoration(
                label: 'Role',
                icon: Icons.admin_panel_settings_outlined,
              ),
              items: AdminAddUserController.roles
                  .map(
                    (role) => DropdownMenuItem(
                      value: role,
                      child: Text(_roleLabel(role)),
                    ),
                  )
                  .toList(),
              onChanged: ctrl.setRole,
            ),
          ),
          const SizedBox(height: 14),
          Obx(
            () => AppTextField(
              label: 'Password',
              controller: ctrl.passwordController,
              hintText: 'Minimal 6 karakter',
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: !ctrl.isPasswordVisible.value,
              required: true,
              suffixIcon: IconButton(
                onPressed: ctrl.togglePasswordVisibility,
                icon: Icon(
                  ctrl.isPasswordVisible.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.body,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Obx(
            () => AppTextField(
              label: 'Konfirmasi Password',
              controller: ctrl.confirmPasswordController,
              hintText: 'Ulangi password',
              prefixIcon: Icons.lock_reset_rounded,
              obscureText: !ctrl.isConfirmPasswordVisible.value,
              required: true,
              suffixIcon: IconButton(
                onPressed: ctrl.toggleConfirmPasswordVisibility,
                icon: Icon(
                  ctrl.isConfirmPasswordVisible.value
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: AppColors.body,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Obx(
            () => SwitchListTile.adaptive(
              value: ctrl.isActive.value,
              onChanged: ctrl.toggleActive,
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primary,
              title: const Text(
                'Akun aktif',
                style: TextStyle(
                  color: AppColors.title,
                  fontWeight: FontWeight.w700,
                ),
              ),
              subtitle: const Text(
                'User dapat login setelah akun dibuat.',
                style: TextStyle(color: AppColors.body, fontSize: 12),
              ),
            ),
          ),
          Obx(
            () => ctrl.errorMessage.value.isEmpty
                ? const SizedBox.shrink()
                : Padding(
                    padding: const EdgeInsets.only(top: 6, bottom: 12),
                    child: _ErrorBanner(message: ctrl.errorMessage.value),
                  ),
          ),
          const SizedBox(height: 8),
          Obx(
            () => AppButton(
              label: 'Simpan User',
              leadingIcon: Icons.save_rounded,
              variant: AppButtonVariant.navy,
              isLoading: ctrl.isSaving.value,
              onPressed: ctrl.saveUser,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: AppColors.body),
      filled: true,
      fillColor: AppColors.field,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'mahasiswa':
        return 'Mahasiswa';
      case 'dosen':
        return 'Dosen';
      case 'teknisi':
        return 'Teknisi';
      case 'tu':
        return 'Tata Usaha';
      case 'admin':
        return 'Admin';
      default:
        return role;
    }
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.blueSoft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.title,
          ),
        ),
      ],
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.redSoft,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.danger),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
