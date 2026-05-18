import 'package:bcrypt/bcrypt.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/service/user_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/role_service.dart';

class AdminAddUserController extends GetxController {
  AdminAddUserController({UserService? userService})
    : _userService = userService ?? UserService();

  final UserService _userService;

  final nameController = TextEditingController();
  final nomorIndukController = TextEditingController();
  final emailController = TextEditingController();
  final programStudyController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final RxString selectedRole = AccessControlService.roleMahasiswa.obs;
  final RxBool isActive = true.obs;
  final RxBool isPasswordVisible = false.obs;
  final RxBool isConfirmPasswordVisible = false.obs;
  final RxBool isSaving = false.obs;
  final RxString errorMessage = ''.obs;

  static const List<String> roles = [
    AccessControlService.roleMahasiswa,
    AccessControlService.roleDosen,
    AccessControlService.roleTeknisi,
    AccessControlService.roleTu,
    AccessControlService.roleAdmin,
  ];

  @override
  void onClose() {
    nameController.dispose();
    nomorIndukController.dispose();
    emailController.dispose();
    programStudyController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void setRole(String? role) {
    if (role == null) return;
    selectedRole.value = AccessControlService.normalizeRole(role);
  }

  void toggleActive(bool value) => isActive.value = value;
  void togglePasswordVisibility() => isPasswordVisible.toggle();
  void toggleConfirmPasswordVisibility() => isConfirmPasswordVisible.toggle();

  Future<void> saveUser() async {
    final name = nameController.text.trim();
    final nomorInduk = nomorIndukController.text.trim();
    final email = emailController.text.trim();
    final programStudy = programStudyController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    errorMessage.value = '';

    final validationError = _validate(
      name: name,
      nomorInduk: nomorInduk,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
    );

    if (validationError != null) {
      errorMessage.value = validationError;
      return;
    }

    isSaving.value = true;
    try {
      final existingUsers = await _userService.getAll();
      final alreadyExists = existingUsers.any(
        (user) => user.nomorInduk == nomorInduk || user.id == nomorInduk,
      );

      if (alreadyExists) {
        errorMessage.value = 'Nomor induk sudah terdaftar.';
        return;
      }

      final now = DateTime.now().toIso8601String();
      final passwordHash = BCrypt.hashpw(password, BCrypt.gensalt());

      await _userService.create(
        UserModel(
          id: nomorInduk,
          name: name,
          nomorInduk: nomorInduk,
          passwordHash: passwordHash,
          role: selectedRole.value,
          isActive: isActive.value,
          createdAt: now,
          email: email,
          programStudy: programStudy,
          source: 'admin',
        ),
      );

      _clearForm();
      Get.snackbar(
        'User Ditambahkan',
        'Akun $name berhasil dibuat.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFE8F5E9),
        colorText: const Color(0xFF1B5E20),
      );
    } catch (e) {
      errorMessage.value = 'Gagal menambahkan user. $e';
    } finally {
      isSaving.value = false;
    }
  }

  String? _validate({
    required String name,
    required String nomorInduk,
    required String email,
    required String password,
    required String confirmPassword,
  }) {
    if (name.isEmpty) return 'Nama lengkap wajib diisi.';
    if (nomorInduk.isEmpty) return 'NIM/NIP/NIDN wajib diisi.';
    if (email.isNotEmpty && !GetUtils.isEmail(email)) {
      return 'Format email tidak valid.';
    }
    if (password.length < 6) return 'Password minimal 6 karakter.';
    if (password != confirmPassword) return 'Konfirmasi password tidak sama.';
    return null;
  }

  void _clearForm() {
    nameController.clear();
    nomorIndukController.clear();
    emailController.clear();
    programStudyController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    selectedRole.value = AccessControlService.roleMahasiswa;
    isActive.value = true;
  }
}
