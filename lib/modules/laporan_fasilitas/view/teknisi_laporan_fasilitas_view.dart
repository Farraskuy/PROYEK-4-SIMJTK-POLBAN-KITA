import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/teknisi/view/form_analisa_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/view/detail_laporan_fasilitas_view.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/laporan_fasilitas_empty_state.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/controller/teknisi_laporan_fasilitas_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/widgets/teknisi_laporan_fasilitas_card.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_home_app_bar.dart';

class TeknisiLaporanFasilitasView extends StatelessWidget {
  const TeknisiLaporanFasilitasView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(TeknisiLaporanFasilitasController());

    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: controller.fetchTugas,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(controller, context),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Tugas Petugas',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.title,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Tanggapi dan tindak lanjuti laporan fasilitas yang masuk.',
                      style: TextStyle(fontSize: 13, color: AppColors.body),
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(child: _SearchBar(controller: controller)),
            SliverToBoxAdapter(child: _FilterBar(controller: controller)),
            Obx(() {
              if (controller.isLoading.value) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                );
              }

              if (controller.tugasTampil.isEmpty) {
                return const SliverFillRemaining(
                  hasScrollBody: false,
                  child: LaporanFasilitasEmptyState(
                    icon: Icons.assignment_turned_in_outlined,
                    title: 'Tidak ada tugas petugas',
                    description:
                        'Laporan fasilitas yang perlu ditangani akan muncul di sini.',
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                sliver: SliverList.separated(
                  itemCount: controller.tugasTampil.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final laporan = controller.tugasTampil[index];
                    return TeknisiLaporanFasilitasCard(
                      laporan: laporan,
                      onTap: () => _openTanggapan(
                        context,
                        controller,
                        laporan,
                        detailFirst: true,
                      ),
                      onRespond: () => _openTanggapan(
                        context,
                        controller,
                        laporan,
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(
    TeknisiLaporanFasilitasController ctrl,
    BuildContext context,
  ) {
    return Obx(() {
      final name = ctrl.user?.name ?? 'Teknisi';
      return AppHomeAppBar(
        title: 'Halo, $name',
        subtitle: 'Teknisi JTK',
        avatarIcon: Icons.engineering_rounded,
        avatarText: name.isEmpty ? 'T' : name[0].toUpperCase(),
      );
    });
  }

  Future<void> _openTanggapan(
    BuildContext context,
    TeknisiLaporanFasilitasController controller,
    LaporanFasilitasModel laporan, {
    bool detailFirst = false,
  }) async {
    final changed = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => detailFirst
            ? DetailLaporanFasilitasView(
                laporanId: laporan.id,
                role: 'teknisi',
              )
            : FormAnalisaView(laporan: laporan),
      ),
    );

    if (changed == true) {
      await controller.fetchTugas();
    }
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TeknisiLaporanFasilitasController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Obx(
        () => TextField(
          controller: controller.searchController,
          decoration: InputDecoration(
            hintText: 'Cari tugas berdasarkan judul, lokasi, atau ID...',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: controller.isSearchActive
                ? IconButton(
                    onPressed: controller.clearSearch,
                    icon: const Icon(Icons.close_rounded),
                  )
                : null,
            filled: true,
            fillColor: AppColors.surface,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.primary,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({required this.controller});

  final TeknisiLaporanFasilitasController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.surface,
      child: Column(
        children: [
          const Divider(height: 1, color: AppColors.border),
          SizedBox(
            height: 56,
            child: Obx(
              () {
                final activeSort = controller.activeSort.value;

                return ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  itemCount: TeknisiLaporanSort.values.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final sort = TeknisiLaporanSort.values[index];
                    return _FilterChip(
                      sort: sort,
                      selected: activeSort == sort,
                      onTap: () => controller.changeSort(sort),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.sort,
    required this.selected,
    required this.onTap,
  });

  final TeknisiLaporanSort sort;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              sort.icon,
              size: 15,
              color: selected ? Colors.white : AppColors.body,
            ),
            const SizedBox(width: 6),
            Text(
              sort.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : AppColors.title,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
