import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Pastikan path ini sesuai dengan struktur folder project kamu
import 'modules/Admin/fasilitas_controller.dart';
import 'modules/Admin/laporan_fasilitas_screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SIMJTK - Admin Portal',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A5F),
          primary: const Color(0xFF1E3A5F),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const RolePickerScreen(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROLE PICKER — Fokus pada Akses Admin
// ─────────────────────────────────────────────────────────────────────────────

class RolePickerScreen extends StatelessWidget {
  const RolePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3A5F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Brand Icon
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.dashboard_customize_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(height: 28),

              const Text(
                'Admin\nManagement',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Kelola pelaporan fasilitas dan delegasi tugas teknisi.',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 14),
              ),

              const Spacer(),

              // Admin Entry Tile
              _RoleTile(
                icon: Icons.admin_panel_settings_outlined,
                role: 'Masuk sebagai Admin',
                subtitle: 'Akses penuh kelola fasilitas & aspirasi',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider(
                        create: (_) => AdminFasilitasController(),
                        child: const AdminLaporanFasilitasScreen(),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),
              Center(
                child: Text(
                  'v1.0.0 · SIMJTK Admin Module',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleTile extends StatelessWidget {
  final IconData icon;
  final String role;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleTile({
    required this.icon,
    required this.role,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(0.1),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        splashColor: Colors.white.withOpacity(0.1),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(role,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(subtitle,
                        style: TextStyle(
                            color: Colors.white.withOpacity(0.65),
                            fontSize: 13)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  color: Colors.white.withOpacity(0.5), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}