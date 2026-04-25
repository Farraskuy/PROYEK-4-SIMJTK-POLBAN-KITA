import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:proyek_4_poki_polban_kita/modules/login/view/login_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/mongodb_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  Object? startupError;
  try {
    await MonggoDBServices().connectToDatabase();
  } catch (e) {
    startupError = e;
  }

  runApp(MainApp(startupError: startupError));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key, this.startupError});

  final Object? startupError;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: startupError == null
          ? const LoginView()
          : StartupErrorView(error: startupError.toString()),
    );
  }
}

class StartupErrorView extends StatelessWidget {
  const StartupErrorView({super.key, required this.error});

  final String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Koneksi Database Gagal')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Aplikasi belum bisa terhubung ke MongoDB.',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Text(error),
            const SizedBox(height: 12),
            const Text(
              'Periksa nilai MONGODB_URI di file .env lalu jalankan ulang aplikasi.',
            ),
          ],
        ),
      ),
    );
  }
}
