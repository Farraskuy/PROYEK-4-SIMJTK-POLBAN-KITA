import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/log_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/role_navigation_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/role_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/user_credential_seeder.dart';

import 'modules/onboarding/view/onboarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load();
  AccessControlService.initSimjtkRoles();

  try {
    await MonggoDBServices().connect();
    
    await UserCredentialSeeder.seedDefaults();
  } catch (e) {
    await LogService.writeLog(
      "Initial MongoDB connection failed: $e",
      source: "main.dart",
      level: 1,
    );
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_refreshMongoConnectionSafely());
    }
  }

  Future<void> _refreshMongoConnectionSafely() async {
    try {
      await MonggoDBServices().ensureConnected();
    } catch (e) {
      await LogService.writeLog(
        "Failed to refresh MongoDB connection on resume: $e",
        source: "main.dart",
        level: 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMJTK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A5F),
          primary: const Color(0xFF1E3A5F),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryTextTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: AuthService().currentUser != null
          ? RoleNavigationService.buildHomeByRole(AuthService().currentUser?.role)
          : const OnboardingView(),
    );
  }
}
