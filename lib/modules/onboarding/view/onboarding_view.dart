import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyek_4_poki_polban_kita/modules/onboarding/widgets/splash_loading_dots.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

import '../../login/view/login_view.dart';
import '../../login/widgets/brand_mark.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 1800), _goToLogin);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _goToLogin() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginView()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: InkWell(
          onTap: _goToLogin,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 27),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const BrandMark(),
                  const SizedBox(height: 48),
                  const SplashLoadingDots(),
                  const SizedBox(height: 24),
                  Text(
                    'Sistem Informasi mahasiswa\nJurusan teknik komputer dan\ninformatika',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.muted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      height: 16 / 12,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Mudahkan langkahmu dalam setiap harinya',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.body,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 20 / 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
