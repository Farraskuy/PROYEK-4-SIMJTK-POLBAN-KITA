import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/laporan_fasilitas_sync_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/hive_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/log_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/network_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/role_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/user_credential_seeder.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/main_layout_shell.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/tanggapan_tugas_service.dart';

import 'modules/onboarding/view/onboarding_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    await dotenv.load(fileName: '.env.example');
  }
  AccessControlService.initSimjtkRoles();

  try {
    await MonggoDBServices().connect();
    await LaporanFasilitasSyncService().syncPending();
    await TanggapanTugasService().syncPendingDrafts();
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
  StreamSubscription<bool>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _connectivitySubscription = NetworkService().onOnlineChanged.listen(
      (isOnline) {
        if (isOnline) {
          unawaited(_syncPendingSafely());
        }
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _connectivitySubscription?.cancel();
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
      await MonggoDBServices().refreshConnection();
      await LaporanFasilitasSyncService().syncPending();
      await TanggapanTugasService().syncPendingDrafts();
    } catch (e) {
      await LogService.writeLog(
        "Failed to refresh MongoDB connection on resume: $e",
        source: "main.dart",
        level: 1,
      );
    }
  }

  Future<void> _syncPendingSafely() async {
    try {
      await LaporanFasilitasSyncService().syncPending();
      await TanggapanTugasService().syncPendingDrafts();
    } catch (e) {
      await LogService.writeLog(
        "Failed to sync pending data: $e",
        source: "main.dart",
        level: 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // UBAH MaterialApp menjadi GetMaterialApp di sini
    return GetMaterialApp(
      title: 'SIMJTK',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.navyDark,
          primary: AppColors.navy,
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
        primaryTextTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: AuthService().currentUser != null
          ? MainLayoutShell(userRole: AuthService().currentUser!.role)
          : const OnboardingView(),
    );
  }
}