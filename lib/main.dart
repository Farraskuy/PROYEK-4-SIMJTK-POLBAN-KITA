import 'package:flutter/material.dart';
// import 'package:proyek_4_poki_polban_kita/modules/detail_laporan_fasilitas/view/detail_laporan_fasilitas_view.dart';
// import 'package:proyek_4_poki_polban_kita/modules/detail_laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/selesaikan_tugas/view/selesaikan_tugas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/detail_laporan_fasilitas/model/laporan_fasilitas_model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      ),
    );
  }
}
*/
