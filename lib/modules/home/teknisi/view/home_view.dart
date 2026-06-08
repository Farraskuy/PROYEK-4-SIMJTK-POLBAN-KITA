import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import '../controller/home_controller.dart';
import '../view/usulan_pemeliharaan_view.dart';
import '../view/penghapusan_view.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/teknisi/view/form_analisa_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/detail_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/teknisi_laporan_fasilitas_card.dart';

// ============================================================
// MODUL MAINTENANCE SECTION
// ============================================================
class ModulMaintenanceSection extends StatelessWidget {
  const ModulMaintenanceSection({super.key});

  static const _menus = [
    {
      'label': 'Usulan\nPemeliharaan',
      'icon': Icons.build_circle_outlined,
      'color': AppColors.success,
      'route': 'pemeliharaan',
    },
    {
      'label': 'Usulan\nPenghapusan',
      'icon': Icons.delete_outline_rounded,
      'color': AppColors.warning,
      'route': 'penghapusan',
    },
  ];

  void _navigate(BuildContext context, String route) {
    switch (route) {
      case 'pemeliharaan':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UsulanPemeliharaanView()),
        );
        break;
      case 'penghapusan':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const UsulanPenghapusanView()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Akses Cepat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.title,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: _menus.map((m) {
            final color = (m['color'] is Color)
                ? m['color'] as Color
                : AppColors.warning;
            final icon = (m['icon'] is IconData)
                ? m['icon'] as IconData
                : Icons.help_outline;
            return GestureDetector(
              onTap: () => _navigate(context, m['route'] as String),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: color, size: 20),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        (m['label'] as String).replaceAll('\n', ' '),
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.title,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ============================================================
// HOME TEKNISI VIEW
// ============================================================
class HomeTeknisiView extends StatelessWidget {
  const HomeTeknisiView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(HomeTeknisiController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primary),
          );
        }
        return RefreshIndicator(
          color: AppColors.primary,
          onRefresh: ctrl.onRefresh,
          child: CustomScrollView(
            slivers: [
              _buildAppBar(ctrl, context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSapaan(ctrl),
                      const SizedBox(height: 20),
                      _buildStatistik(ctrl),
                      const SizedBox(height: 28),
                      const ModulMaintenanceSection(),
                      const SizedBox(height: 28),
                      _buildTugasMendesakHeader(context),
                      const SizedBox(height: 12),
                      _buildTugasMendesakList(ctrl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // ============================================================
  // APP BAR
  // ============================================================
  Widget _buildAppBar(HomeTeknisiController ctrl, BuildContext context) {
    return Obx(
      () => AppHomeAppBar(
        title: 'Halo, ${ctrl.currentTeknisi.value.name.isEmpty ? 'Teknisi' : ctrl.currentTeknisi.value.name}',
        subtitle: ctrl.currentTeknisi.value.role,
        avatarIcon: Icons.engineering_rounded,
        avatarText: ctrl.currentTeknisi.value.name.isEmpty
            ? 'T'
            : ctrl.currentTeknisi.value.name[0].toUpperCase(),
      ),
    );
  }

  // ============================================================
  // SAPAAN
  // ============================================================
  Widget _buildSapaan(HomeTeknisiController ctrl) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(
          () => Text(
            'Hallo, ${ctrl.user?.name ?? 'Teknisi'}',
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.title,
              height: 1.1,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          ctrl.sapaan,
          style: const TextStyle(fontSize: 13, color: AppColors.body),
        ),
      ],
    );
  }

  // ============================================================
  // STATISTIK TUGAS
  // ============================================================
  Widget _buildStatistik(HomeTeknisiController ctrl) {
    return Obx(() {
      final stat = ctrl.statistik.value;
      if (stat == null) return const SizedBox.shrink();

      return Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(
                          Icons.assignment_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'TUGAS AKTIF',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.muted,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Text(
                      '${stat.totalTugas}',
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                        height: 1.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.navy,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SELESAI',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: Colors.white60,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${stat.tugasSelesai}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.0,
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.blueSoft,
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(16),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PENDING',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.body,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${stat.tugasPending}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                                color: AppColors.title,
                                height: 1.0,
                              ),
                            ),
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.access_time_rounded,
                                color: AppColors.primary,
                                size: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  // ============================================================
  // TUGAS MENDESAK HEADER
  // ============================================================
  Widget _buildTugasMendesakHeader(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Tugas Mendesak',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.title,
          ),
        ),
        const SizedBox(width: 6),
        // Label keterangan sort
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.greenSoft,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Row(
            children: const [
              Icon(
                Icons.arrow_upward_rounded,
                size: 11,
                color: AppColors.success,
              ),
              SizedBox(width: 3),
              Text(
                'Top Upvote',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ============================================================
  // TUGAS MENDESAK LIST — dari LaporanFasilitasModel
  // ============================================================
  Widget _buildTugasMendesakList(HomeTeknisiController ctrl) {
    return Obx(() {
      final list = ctrl.tugasMendesak;

      if (list.isEmpty) {
        return _EmptyMendesak();
      }

      // Tampilkan maksimal 5 tugas teratas di home
      final displayList = list.take(5).toList();

      return ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: displayList.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, index) {
          final laporan = displayList[index];
          return TeknisiLaporanFasilitasCard(
            laporan: laporan,
            onTap: () => _openTanggapan(context, ctrl, laporan.id),
            onRespond: () => _openForm(context, ctrl, laporan),
          );
        },
      );
    });
  }

  Future<void> _openTanggapan(
    BuildContext context,
    HomeTeknisiController controller,
    String laporanId,
  ) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            DetailLaporanFasilitasView(laporanId: laporanId, role: 'teknisi'),
      ),
    );
    if (changed == true) {
      await controller.onRefresh();
    }
  }

  Future<void> _openForm(
    BuildContext context,
    HomeTeknisiController controller,
    LaporanFasilitasModel laporan,
  ) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormAnalisaView(laporan: laporan)),
    );
    if (changed == true) {
      await controller.onRefresh();
    }
  }
}

// ============================================================
// WIDGET: Empty State Tugas Mendesak
// ============================================================
class _EmptyMendesak extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 44,
            color: AppColors.success,
          ),
          SizedBox(height: 10),
          Text(
            'Tidak ada laporan mendesak',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.body,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Belum ada laporan fasilitas yang masuk',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
