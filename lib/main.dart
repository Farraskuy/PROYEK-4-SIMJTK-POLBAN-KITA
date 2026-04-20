import 'package:flutter/material.dart';
<<<<<<< HEAD
// import 'package:proyek_4_poki_polban_kita/modules/detail_laporan_fasilitas/view/detail_laporan_fasilitas_view.dart';
// import 'package:proyek_4_poki_polban_kita/modules/detail_laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/selesaikan_tugas/view/selesaikan_tugas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/detail_laporan_fasilitas/model/laporan_fasilitas_model.dart';
=======
import 'package:get/get.dart';
import 'package:provider/provider.dart';

// Import sesuai struktur folder baru
import 'modules/home_screen/view/home_view.dart';
import 'modules/Admin/controller/fasilitas_controller.dart';
import 'modules/Admin/view/laporan_fasilitas_screen.dart';
>>>>>>> 48cb882b01ffb443d95f8c4a2a0bc1b955a043ba

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
<<<<<<< HEAD
    // Dummy laporan untuk test
    final dummyLaporan = LaporanFasilitasModel(
      id: 'test-001',
      judul: 'Test Laporan Fasilitas',
      deskripsi: 'Ini adalah laporan test untuk fitur selesaikan tugas.',
      lokasiLabKelas: 'Lab Komputer 1',
      fotoUrls: [],
      status: StatusLaporan.assigned,
      prioritas: 'Tinggi',
      pelaporNama: 'Mahasiswa Test',
      pelaporId: 'mhs-001',
      handlerNama: 'Staff Test',
      handlerId: 'staff-001',
      estimasiSelesai: DateTime.now().add(const Duration(days: 2)),
      createdAt: DateTime.now(),
      riwayat: [],
    );

    return MaterialApp(home: SelesaikanTugasView(laporan: dummyLaporan));
  }
}

// Kode lama dikomentari:
/*
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DetailLaporanFasilitasView(
        laporanId: 'test-001',
        role: RoleUser.staff, // ganti-ganti di sini untuk test tiap role
=======
    return GetMaterialApp(
      title: 'SIMJTK - Integrated Portal',
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
// ROLE PICKER — Gerbang Utama Aplikasi
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
              _buildLogo(),
              const SizedBox(height: 28),
              const Text(
                'SIMJTK\nManagement',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Pilih akses layanan mahasiswa atau manajemen jurusan.',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.6), fontSize: 14),
              ),
              const Spacer(),

              // ROLE 1: MAHASISWA (GetX)
              _RoleTile(
                icon: Icons.school_outlined,
                role: 'Akses Mahasiswa',
                subtitle: 'Laporan fasilitas & informasi JTK',
                onTap: () => Get.to(() => const HomeView()),
              ),

              const SizedBox(height: 16),

              // ROLE 2: ADMIN (Provider + Refactored View)
              _RoleTile(
                icon: Icons.admin_panel_settings_outlined,
                role: 'Masuk sebagai Admin',
                subtitle: 'Kelola & delegasi laporan teknisi',
                onTap: () {
                  // Injeksi controller saat navigasi ke view yang didefinisikan di subfolder view/
                  Get.to(() => ChangeNotifierProvider(
                        create: (_) => AdminFasilitasController(),
                        child: const AdminLaporanFasilitasScreen(),
                      ));
                },
              ),

              const SizedBox(height: 32),
              Center(
                child: Text(
                  'v1.0.0 · Politeknik Negeri Bandung',
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.3), fontSize: 12),
                ),
              ),
            ],
          ),
        ),
>>>>>>> 48cb882b01ffb443d95f8c4a2a0bc1b955a043ba
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.dashboard_customize_rounded,
          color: Colors.white, size: 28),
    );
  }
}
<<<<<<< HEAD
*/
=======

// ─────────────────────────────────────────────────────────────────────────────
// COMPONENT: RoleTile
// ─────────────────────────────────────────────────────────────────────────────

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
              const Icon(Icons.chevron_right_rounded,
                  color: Colors.white, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
>>>>>>> 48cb882b01ffb443d95f8c4a2a0bc1b955a043ba
