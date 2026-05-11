import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyek_4_poki_polban_kita/modules/login/widgets/brand_mark.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/role_navigation_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_button.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_text_field.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _nimController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _rememberMe = false;
  bool _obscurePassword = true;
  String? _status;

  void _navigateByRole() {
    final role = AuthService().currentUser?.role;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => RoleNavigationService.buildHomeByRole(role),
      ),
      (_) => false,
    );
  }

  @override
  void dispose() {
    _nimController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _loginHandler() async {
    FocusScope.of(context).unfocus();

    final nim = _nimController.text.trim();
    final password = _passwordController.text.trim();

    if (nim.isEmpty || password.isEmpty) {
      setState(() => _status = 'NIM/NIP dan kata sandi wajib diisi.');
      return;
    }

    setState(() {
      _isLoading = true;
      _status = null;
    });

    final authService = AuthService();
    final localLoginSuccess = await authService.login(nim, password);

    if (!mounted) return;

    if (localLoginSuccess) {
      setState(() => _isLoading = false);
      _navigateByRole();
      return;
    }

    setState(() {
      _isLoading = false;
      _status = 'Login gagal. Periksa kembali NIM/NIP dan kata sandi.';
    });
  }

  void _showSupportMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Hubungi IT Support untuk pembuatan akun SIMJTK.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // SizedBox(
                        //   height: 52,
                        // ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const BrandMark(compact: true),
                            const SizedBox(height: 72),
                            Text(
                              'Masuk',
                              style: GoogleFonts.poppins(
                                color: AppColors.title,
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                height: 36 / 30,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Gunakan akun akademik anda untuk\nmengakases sistem',
                              style: GoogleFonts.poppins(
                                color: AppColors.body,
                                fontSize: 16,
                                fontWeight: FontWeight.w400,
                                height: 24 / 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        AppTextField(
                          label: 'NIM / NIP',
                          controller: _nimController,
                          prefixIcon: Icons.person_outline,
                          hintText: 'Masukkan nomor identitas',
                          enabled: !_isLoading,
                        ),
                        const SizedBox(height: 24),
                        AppTextField(
                          label: 'Kata Sandi',
                          controller: _passwordController,
                          prefixIcon: Icons.lock_outline,
                          hintText: '........',
                          enabled: !_isLoading,
                          obscureText: _obscurePassword,
                          suffixIcon: IconButton(
                            onPressed: _isLoading
                                ? null
                                : () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: AppColors.body,
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        AppButton(
                          label: 'Masuk',
                          isLoading: _isLoading,
                          onPressed: _loginHandler,
                          size: AppButtonSize.small,
                          trailingIcon: Icons.arrow_forward,
                        ),
                        if (_status != null) ...[
                          const SizedBox(height: 14),
                          Text(
                            _status!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: AppColors.danger,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              height: 16 / 12,
                            ),
                          ),
                        ],
                        SizedBox(height: 62),
                        Center(
                          child: TextButton(
                            onPressed: _showSupportMessage,
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: EdgeInsets.zero,
                            ),
                            child: Text.rich(
                              TextSpan(
                                text: '  Belum punya akun? ',
                                style: GoogleFonts.poppins(
                                  color: AppColors.body,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  height: 20 / 14,
                                ),
                                children: [
                                  TextSpan(
                                    text: 'Hubungi IT Support    ',
                                    style: GoogleFonts.poppins(
                                      color: AppColors.primary,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      height: 20 / 14,
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
