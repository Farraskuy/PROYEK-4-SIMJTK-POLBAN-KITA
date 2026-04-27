import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/view/aspirasi_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/detail_laporan_fasilitas_view.dart';
import '../controller/lapor_fasilitas_controller.dart';
import '../model/laporan_fasilitas_model.dart';
import 'lapor_fasilitas_view.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
class _C {
  static const primary = Color(0xFF1A3A6B);
  static const surface = Color(0xFFF5F7FA);
  static const card = Colors.white;
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF6B7280);
  static const textLight = Color(0xFFB0B8CC);
  static const navActive = Color(0xFF1A3A6B);
  static const navInactive = Color(0xFF9CA3AF);
}

// ─── Controller ───────────────────────────────────────────────────────────────
class MahasiswaLaporanController extends GetxController {
  static const String _currentUserId = 'usr-001';

  final RxList<LaporanFasilitasModel> myLaporan = <LaporanFasilitasModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString filterStatus = 'semua'.obs;

  @override
  void onInit() {
    super.onInit();
    loadLaporan();
  }

  Future<void> loadLaporan() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    myLaporan.assignAll(_dummyLaporan());
    isLoading.value = false;
    update(); // rebuild GetBuilder widgets
  }

  List<LaporanFasilitasModel> get filtered {
    if (filterStatus.value == 'semua') return myLaporan;
    return myLaporan
        .where((l) => l.status.value == filterStatus.value)
        .toList();
  }

  void setFilter(String s) {
    filterStatus.value = s;
    update(); // rebuild GetBuilder widgets
  }

  List<LaporanFasilitasModel> _dummyLaporan() {
    final now = DateTime.now();
    return [
      LaporanFasilitasModel(
        id: 'lap-mhs-001',
        judul: 'Mouse Meledak',
        deskripsi:
            'Mouse di meja 4 tiba-tiba mengeluarkan asap saat digunakan.',
        kategoriId: 'kat-002',
        namaKategori: 'Perangkat PC',
        lokasiLabKelas: 'Student Lounge North',
        fotoUrls: [],
        status: StatusLaporan.resolved,
        prioritas: PrioritasLaporan.medium,
        pelaporId: _currentUserId,
        pelaporNama: 'Budi Santoso',
        handlerId: 'staff-001',
        handlerNama: 'Ahmad Supri',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        tindakan: [
          TindakanFasilitas(
            id: 'act-1',
            laporanId: 'lap-mhs-001',
            aktorId: 'system',
            aktivitas: 'Laporan Dibuat',
            catatanPengerjaan: 'Laporan berhasil diterima oleh sistem.',
            timestamp: now.subtract(const Duration(hours: 2)),
            aktorNama: 'Sistem',
          ),
          TindakanFasilitas(
            id: 'act-2',
            laporanId: 'lap-mhs-001',
            aktorId: 'admin-001',
            aktivitas: 'Ditugaskan ke Teknisi',
            catatanPengerjaan:
                'Teknisi Ahmad Supri telah ditugaskan untuk menangani laporan ini.',
            timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
            aktorNama: 'Admin',
          ),
          TindakanFasilitas(
            id: 'act-3',
            laporanId: 'lap-mhs-001',
            aktorId: 'staff-001',
            aktivitas: 'Sedang Diperbaiki',
            catatanPengerjaan:
                'Teknisi sedang melakukan pengecekan dan penggantian komponen di lokasi.',
            timestamp: now.subtract(const Duration(hours: 1)),
            aktorNama: 'Ahmad Supri',
          ),
        ],
      ),
      LaporanFasilitasModel(
        id: 'lap-mhs-002',
        judul: 'AC Lab Komputer 2 Tidak Dingin',
        deskripsi: 'AC sudah 3 hari tidak berfungsi normal.',
        kategoriId: 'kat-003',
        namaKategori: 'AC / Pendingin',
        lokasiLabKelas: 'Lab Komputer 2, Gd. A',
        fotoUrls: [],
        status: StatusLaporan.inProgress,
        prioritas: PrioritasLaporan.high,
        pelaporId: _currentUserId,
        pelaporNama: 'Budi Santoso',
        handlerId: 'staff-002',
        handlerNama: 'Dedi Hermawan',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(hours: 12)),
      ),
      LaporanFasilitasModel(
        id: 'lap-mhs-003',
        judul: 'Kursi Meja 12 Patah',
        deskripsi: 'Kaki kursi depan kanan patah.',
        kategoriId: 'kat-005',
        namaKategori: 'Furnitur',
        lokasiLabKelas: 'Lab Komputer Dasar',
        fotoUrls: [],
        status: StatusLaporan.pending,
        prioritas: PrioritasLaporan.low,
        pelaporId: _currentUserId,
        pelaporNama: 'Budi Santoso',
        createdAt: now.subtract(const Duration(days: 2)),
        updatedAt: now.subtract(const Duration(days: 2)),
      ),
    ];
  }
}

// ─── MAIN VIEW (StatefulWidget — tidak pakai Obx di luar GetBuilder) ──────────
class LaporanFasilitasMahasiswaView extends StatefulWidget {
  const LaporanFasilitasMahasiswaView({super.key});

  @override
  State<LaporanFasilitasMahasiswaView> createState() =>
      _LaporanFasilitasMahasiswaViewState();
}

class _LaporanFasilitasMahasiswaViewState
    extends State<LaporanFasilitasMahasiswaView> {
  late final MahasiswaLaporanController ctrl;

  @override
  void initState() {
    super.initState();
    ctrl = Get.put(MahasiswaLaporanController());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _C.surface,
      appBar: _buildAppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildFilterChips(),
          const SizedBox(height: 4),
          Expanded(child: _buildList()),
        ],
      ),
      floatingActionButton: _buildFAB(),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── AppBar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: _C.textPrimary,
          size: 22,
        ),
        onPressed: () => Get.back(),
      ),
      title: Row(
        children: [
          const CircleAvatar(
            radius: 15,
            backgroundColor: _C.primary,
            child: Icon(Icons.person, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, Budi',
                style: TextStyle(
                  color: _C.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Mahasiswa JTK',
                style: TextStyle(color: _C.textSecondary, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined, color: _C.textPrimary),
          onPressed: () {},
        ),
      ],
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Laporan Fasilitas',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: _C.textPrimary,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Laporkan kerusakan fasilitas yang ada di\nlingkungan Jurusan Teknik Komputer dan Informatika',
            style: TextStyle(
              fontSize: 12,
              color: _C.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter chips — pakai GetBuilder, bukan Obx di-wrap widget besar ────────

  Widget _buildFilterChips() {
    const filters = [
      {'key': 'semua', 'label': 'Semua'},
      {'key': 'pending', 'label': 'Menunggu'},
      {'key': 'in_progress', 'label': 'Diproses'},
      {'key': 'resolved', 'label': 'Selesai'},
    ];

    return GetBuilder<MahasiswaLaporanController>(
      builder: (c) => SizedBox(
        height: 44,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final f = filters[i];
            final isActive = c.filterStatus.value == f['key'];
            return GestureDetector(
              onTap: () {
                c.setFilter(f['key']!);
                // GetBuilder tidak auto-rebuild saat Rx berubah —
                // update() dipanggil dari setFilter melalui GetxController
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isActive ? _C.primary : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isActive ? _C.primary : Colors.grey.shade300,
                  ),
                ),
                child: Text(
                  f['label']!,
                  style: TextStyle(
                    color: isActive ? Colors.white : _C.textSecondary,
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ── List ───────────────────────────────────────────────────────────────────

  Widget _buildList() {
    return GetBuilder<MahasiswaLaporanController>(
      builder: (c) {
        if (c.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: _C.primary),
          );
        }
        final items = c.filtered;
        if (items.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 12),
                Text(
                  'Belum ada laporan',
                  style: TextStyle(color: Colors.grey[400], fontSize: 14),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _goToTambah,
                  child: const Text(
                    'Buat laporan pertama Anda',
                    style: TextStyle(color: _C.primary),
                  ),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          color: _C.primary,
          onRefresh: () => c.loadLaporan(),
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            itemCount: items.length,
            itemBuilder: (_, i) => _LaporanCard(
              laporan: items[i],
              onEdit: () => _goToEdit(items[i]),
            ),
          ),
        );
      },
    );
  }

  // ── FAB ────────────────────────────────────────────────────────────────────

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _goToTambah,
      backgroundColor: _C.primary,
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'Buat Laporan',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }

  // ── Bottom nav ─────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    const navItems = [
      {'label': 'Home', 'icon': Icons.home_rounded},
      {'label': 'Layanan', 'icon': Icons.grid_view_rounded},
      {'label': 'Aspirasi', 'icon': Icons.campaign_rounded},
      {'label': 'Profil', 'icon': Icons.person_rounded},
    ];
    const activeIdx = 1;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(navItems.length, (i) {
              final active = i == activeIdx;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (i == 0) {
                      Get.back();
                    } else if (i == 2) {
                      Get.to(() => const AspirasiView());
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        navItems[i]['icon'] as IconData,
                        size: 24,
                        color: active ? _C.navActive : _C.navInactive,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        navItems[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: active ? _C.navActive : _C.navInactive,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ── Navigation helpers ─────────────────────────────────────────────────────

  Future<void> _goToTambah() async {
    await Get.to(() => const LaporFasilitasView());
    ctrl.loadLaporan();
  }

  Future<void> _goToEdit(LaporanFasilitasModel laporan) async {
    await Get.to(() => const LaporFasilitasView(), arguments: laporan);
    ctrl.loadLaporan();
  }
}

// ─── LAPORAN CARD ─────────────────────────────────────────────────────────────

class _LaporanCard extends StatelessWidget {
  final LaporanFasilitasModel laporan;
  final VoidCallback onEdit;

  const _LaporanCard({required this.laporan, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    final cfg = _statusConfig(laporan.status);
    final canEdit = laporan.status == StatusLaporan.pending;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Get.to(
            () => DetailLaporanFasilitasView(
              laporanId: laporan.id,
              role: RoleUser.mahasiswa,
            ),
          );
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: _C.card,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Card header ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _UpvoteColumn(),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Avatar + name row
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 13,
                                backgroundColor: _C.primary.withOpacity(0.15),
                                child: Text(
                                  laporan.pelaporDisplayName.isNotEmpty
                                      ? laporan.pelaporDisplayName[0]
                                            .toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    color: _C.primary,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 7),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      laporan.pelaporDisplayName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                        color: _C.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      'D4 Teknik Informatika · ${_timeAgo(laporan.createdAt)}',
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: _C.textLight,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Status badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 9,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: cfg.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  laporan.status.label,
                                  style: TextStyle(
                                    color: cfg.color,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Judul
                          Text(
                            laporan.judul,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: _C.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Lokasi
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: _C.textLight,
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  laporan.lokasiLabKelas,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _C.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          // Kategori
                          if (laporan.namaKategori != null) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.label_outline,
                                  size: 12,
                                  color: _C.textLight,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  laporan.namaKategori!,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _C.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          // Handler
                          if (laporan.handlerName != null) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                const Icon(
                                  Icons.engineering_outlined,
                                  size: 12,
                                  color: _C.textLight,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  'Ditangani: ${laporan.handlerName}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: _C.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Foto placeholder ─────────────────────────────
              if (laporan.fotoUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(0),
                  ),
                  child: Image.network(
                    laporan.fotoUrls.first,
                    width: double.infinity,
                    height: 160,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 140,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      size: 40,
                      color: Colors.grey,
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              // ── Action row ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.arrow_upward_rounded, size: 15),
                        label: const Text('Up vote'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _C.textSecondary,
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          textStyle: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: canEdit
                          ? ElevatedButton.icon(
                              onPressed: onEdit,
                              icon: const Icon(Icons.edit_outlined, size: 15),
                              label: const Text('Edit'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _C.primary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                textStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            )
                          : OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.arrow_downward_rounded,
                                size: 15,
                              ),
                              label: const Text('Down Vote'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: _C.textSecondary,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                                textStyle: const TextStyle(fontSize: 12),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }

  _StatusConfig _statusConfig(StatusLaporan s) {
    switch (s) {
      case StatusLaporan.pending:
        return const _StatusConfig(Colors.orange);
      case StatusLaporan.assigned:
        return const _StatusConfig(Colors.blue);
      case StatusLaporan.inProgress:
        return const _StatusConfig(Colors.purple);
      case StatusLaporan.resolved:
        return const _StatusConfig(Colors.green);
      case StatusLaporan.rejected:
        return const _StatusConfig(Colors.red);
    }
  }
}

class _StatusConfig {
  final Color color;
  const _StatusConfig(this.color);
}

class _UpvoteColumn extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Icon(Icons.arrow_upward_rounded, size: 16, color: _C.textLight),
        Text(
          '128',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: _C.textPrimary,
          ),
        ),
        Icon(Icons.arrow_downward_rounded, size: 16, color: _C.textLight),
      ],
    );
  }
}
