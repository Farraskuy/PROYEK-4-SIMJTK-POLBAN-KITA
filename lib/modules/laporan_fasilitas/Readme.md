# Feature: Detail Laporan Fasilitas

Menampilkan detail satu laporan fasilitas secara dinamis berdasarkan **role** pengguna.

## Role Logic (if/else)

| Role | Konten Tambahan |
|------|----------------|
| `mahasiswa` | Deskripsi + Foto Kondisi Awal + **Timeline** riwayat |
| `staff` | Deskripsi + Foto Kondisi Awal + **Tombol Selesaikan Tugas** (→ `selesaikan_tugas`) |
| `admin` | Deskripsi + Foto Kondisi Awal + Timeline + **Tombol Delegasi** (→ `delegasi_laporan`) |

## Struktur

```
detail_laporan_fasilitas/
├── controller/
│   └── detail_laporan_fasilitas_controller.dart  → fetch & state laporan
├── model/
│   └── laporan_fasilitas_model.dart              → LaporanFasilitasModel, TindakanFasilitas, enum
├── service/
│   └── detail_laporan_fasilitas_service.dart     → getLaporanById, delegasikanLaporan
└── view/
    └── detail_laporan_fasilitas_view.dart        → UI dinamis per role
```

## Cara Pakai

```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => DetailLaporanFasilitasView(
      laporanId: 'id-laporan',
      role: RoleUser.mahasiswa, // atau .staff / .admin
    ),
  ),
);
```

## TODO
- [ ] Ganti dummy data di service dengan API call (Dio)
- [ ] Offline support: query Hive jika tidak ada koneksi
- [ ] Buat `DelegasiLaporanView` untuk aksi admin
