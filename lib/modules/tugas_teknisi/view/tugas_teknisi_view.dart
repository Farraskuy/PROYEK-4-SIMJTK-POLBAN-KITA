// // ============================================================
// // FILE: modules/home/teknisi/tugas/view/daftar_tugas_view.dart
// // Kelompok A7 â€“ SIMJTK (Sistem Informasi Mahasiswa JTK)
// // ============================================================

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controller/daftar_tugas_controller.dart'; // FIXED: Sesuai file controller Anda
// import '../model/tugas_teknisi_model.dart';

// // ============================================================
// // DESIGN TOKENS
// // ============================================================
// class _C {
//   static const primary = Color(0xFF1A3A6B);
//   static const primaryLight = Color(0xFF2B5BAE);
//   static const surface = Color(0xFFF0F4FA);
//   static const white = Colors.white;
//   static const cardBg = Color(0xFFFFFFFF);
//   static const textPrimary = Color(0xFF1A1A2E);
//   static const textSecondary = Color(0xFF6B7280);
//   static const textLight = Color(0xFFB0B8CC);
//   static const divider = Color(0xFFE5E9F2);

//   // Filter chip colors
//   static const chipActive = Color(0xFF1A3A6B);
//   static const chipActiveFg = Colors.white;
//   static const chipInactiveBg = Color(0xFFFFFFFF);
//   static const chipInactiveFg = Color(0xFF6B7280);
//   static const chipInactiveBorder = Color(0xFFDDE3EF);

//   // Status badge
//   static const menungguBg = Color(0xFFEDF2FF);
//   static const menungguFg = Color(0xFF2B5BAE);
//   static const diprosesBg = Color(0xFFE3F2FD);
//   static const diprosesFg = Color(0xFF1565C0);
//   static const selesaiBg = Color(0xFF1A3A6B);
//   static const selesaiFg = Colors.white;
//   static const ditolakBg = Color(0xFFFFEBEE);
//   static const ditolakFg = Color(0xFFD32F2F);

//   // Prioritas bar kiri
//   static const barHigh = Color(0xFFE53935);
//   static const barMedium = Color(0xFF1A3A6B);
//   static const barLow = Color(0xFFB0B8CC);

//   // Nav
//   static const navActive = Color(0xFF1A3A6B);
//   static const navInactive = Color(0xFF9CA3AF);

//   // Offline badge
//   static const offlineBg = Color(0xFFFFF3E0);
//   static const offlineFg = Color(0xFFE65100);
// }

// // ============================================================
// // DAFTAR TUGAS VIEW
// // ============================================================
// class DaftarTugasView extends StatelessWidget {
//   const DaftarTugasView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // Memastikan controller diinisialisasi[cite: 23]
//     final ctrl = Get.put(DaftarTugasController());

//     return Scaffold(
//       backgroundColor: _C.surface,
//       body: Column(
//         children: [
//           // ---- HEADER FIXED ----
//           _buildHeader(ctrl),

//           // ---- FILTER CHIPS FIXED ----
//           _buildFilterChips(ctrl),

//           // ---- LIST TUGAS SCROLLABLE ----
//           Expanded(
//             child: Obx(() {
//               if (ctrl.isLoading.value) {
//                 return const Center(
//                   child: CircularProgressIndicator(color: _C.primary),
//                 );
//               }

//               if (ctrl.tugasTampil.isEmpty) {
//                 return _EmptyState(filter: ctrl.activeFilter.value);
//               }

//               return RefreshIndicator(
//                 color: _C.primary,
//                 onRefresh: ctrl.onRefresh,
//                 child: ListView.separated(
//                   padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
//                   itemCount: ctrl.tugasTampil.length,
//                   separatorBuilder: (_, __) => const SizedBox(height: 10),
//                   itemBuilder: (context, index) {
//                     final item = ctrl.tugasTampil[index];
//                     return _TugasListItem(
//                       item: item,
//                       onTap: () => ctrl.onItemTapped(item),
//                       // Tambahkan aksi teknisi sesuai UC-07[cite: 22]
//                       onMulai: () => ctrl.onMulaiKerjakan(item),
//                       onSelesai: () => ctrl.onSelesaikan(item),
//                     );
//                   },
//                 ),
//               );
//             }),
//           ),
//         ],
//       ),
//       bottomNavigationBar: _buildBottomNavBar(ctrl),
//     );
//   }

//   Widget _buildHeader(DaftarTugasController ctrl) {
//     return Container(
//       color: _C.white,
//       child: SafeArea(
//         bottom: false,
//         child: Padding(
//           padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   IconButton(
//                     onPressed: () => AppNavigator.pop(),
//                     icon: const Icon(Icons.menu_rounded, color: _C.textPrimary, size: 24),
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//                   const SizedBox(width: 8),
//                   const Text(
//                     'Technician Portal',
//                     style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: _C.primary),
//                   ),
//                   const Spacer(),
//                   const CircleAvatar(
//                     radius: 18,
//                     backgroundColor: _C.primary,
//                     child: Icon(Icons.person, color: Colors.white, size: 18),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 'Daftar Tugas',
//                 style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: _C.textPrimary),
//               ),
//               const SizedBox(height: 4),
//               const Text('Tugas yang diberikan kepada anda', style: TextStyle(fontSize: 13, color: _C.textSecondary)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildFilterChips(DaftarTugasController ctrl) {
//     return Container(
//       color: _C.white,
//       child: Column(
//         children: [
//           const Divider(height: 1, color: _C.divider),
//           SizedBox(
//             height: 52,
//             child: Obx(
//               () => ListView(
//                 scrollDirection: Axis.horizontal,
//                 padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//                 children: FilterTugas.values.map((filter) {
//                   final isActive = ctrl.activeFilter.value == filter;
//                   int count;
//                   switch (filter) {
//                     case FilterTugas.semua: count = ctrl.countSemua; break;
//                     case FilterTugas.menunggu: count = ctrl.countMenunggu; break;
//                     case FilterTugas.diproses: count = ctrl.countDiproses; break;
//                     case FilterTugas.selesai: count = ctrl.countSelesai; break;
//                   }
//                   return Padding(
//                     padding: const EdgeInsets.only(right: 8),
//                     child: _FilterChip(
//                       label: filter.label,
//                       count: count,
//                       isActive: isActive,
//                       onTap: () => ctrl.onFilterChanged(filter),
//                     ),
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomNavBar(DaftarTugasController ctrl) {
//     const navItems = [
//       {'label': 'Home', 'icon': Icons.dashboard_rounded},
//       {'label': 'Tugas', 'icon': Icons.assignment_rounded},
//       {'label': 'Riwayat', 'icon': Icons.history_rounded},
//       {'label': 'Profil', 'icon': Icons.person_rounded},
//     ];

//     return Obx(
//       () => Container(
//         decoration: BoxDecoration(
//           color: _C.white,
//           boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -2))],
//         ),
//         child: SafeArea(
//           child: SizedBox(
//             height: 62,
//             child: Row(
//               children: List.generate(navItems.length, (i) {
//                 final active = ctrl.selectedNavIndex.value == i;
//                 final icon = navItems[i]['icon'] as IconData;
//                 final label = navItems[i]['label'] as String;

//                 return Expanded(
//                   child: GestureDetector(
//                     onTap: () => ctrl.onNavTapped(i),
//                     behavior: HitTestBehavior.opaque,
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(icon, size: active ? 24 : 22, color: active ? _C.navActive : _C.navInactive),
//                         const SizedBox(height: 3),
//                         Text(
//                           label,
//                           style: TextStyle(
//                             fontSize: 9,
//                             fontWeight: active ? FontWeight.w700 : FontWeight.w400,
//                             color: active ? _C.navActive : _C.navInactive,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ============================================================
// // WIDGET: Item Tugas di List
// // ============================================================
// class _TugasListItem extends StatelessWidget {
//   final ItemTugasModel item;
//   final VoidCallback onTap;
//   final VoidCallback onMulai;
//   final VoidCallback onSelesai;

//   const _TugasListItem({
//     required this.item,
//     required this.onTap,
//     required this.onMulai,
//     required this.onSelesai,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         decoration: BoxDecoration(
//           color: _C.cardBg,
//           borderRadius: BorderRadius.circular(14),
//           border: Border.all(color: _C.divider, width: 1),
//         ),
//         child: IntrinsicHeight(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Container(
//                 width: 4,
//                 decoration: BoxDecoration(
//                   color: _getBarColor(item.prioritas),
//                   borderRadius: const BorderRadius.only(topLeft: Radius.circular(14), bottomLeft: Radius.circular(14)),
//                 ),
//               ),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(14),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(item.nomorRef, style: const TextStyle(fontSize: 11, color: _C.textLight)),
//                           _StatusBadge(status: item.status),
//                         ],
//                       ),
//                       const SizedBox(height: 8),
//                       Text(item.judul, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
//                       const SizedBox(height: 6),
//                       Text(item.lokasi, style: const TextStyle(fontSize: 12, color: _C.textSecondary)),

//                       // Tombol Aksi sesuai Status[cite: 22]
//                       if (item.status == StatusLaporanTeknisi.assigned) ...[
//                         const SizedBox(height: 12),
//                         const Divider(height: 1),
//                         const SizedBox(height: 10),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: _AksiButton(
//                             label: 'Mulai Kerja',
//                             icon: Icons.play_arrow_rounded,
//                             color: Colors.green,
//                             onTap: onMulai,
//                           ),
//                         ),
//                       ] else if (item.status == StatusLaporanTeknisi.inProgress) ...[
//                         const SizedBox(height: 12),
//                         const Divider(height: 1),
//                         const SizedBox(height: 10),
//                         Align(
//                           alignment: Alignment.centerRight,
//                           child: _AksiButton(
//                             label: 'Selesaikan',
//                             icon: Icons.check_rounded,
//                             color: _C.primary,
//                             onTap: onSelesai,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Color _getBarColor(PrioritasLaporan p) {
//     switch (p) {
//       case PrioritasLaporan.high: return _C.barHigh;
//       case PrioritasLaporan.medium: return _C.barMedium;
//       case PrioritasLaporan.low: return _C.barLow;
//     }
//   }
// }

// // ============================================================
// // WIDGET HELPERS (Badge, Button, EmptyState)
// // ============================================================
// class _StatusBadge extends StatelessWidget {
//   final StatusLaporanTeknisi status;
//   const _StatusBadge({required this.status});

//   @override
//   Widget build(BuildContext context) {
//     Color bg = _C.menungguBg, fg = _C.menungguFg;
//     if (status == StatusLaporanTeknisi.inProgress) { bg = _C.diprosesBg; fg = _C.diprosesFg; }
//     else if (status == StatusLaporanTeknisi.resolved) { bg = _C.selesaiBg; fg = _C.selesaiFg; }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
//       child: Text(status.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fg)),
//     );
//   }
// }

// class _AksiButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final VoidCallback onTap;
//   const _AksiButton({required this.label, required this.icon, required this.color, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return ElevatedButton.icon(
//       onPressed: onTap,
//       icon: Icon(icon, size: 16),
//       label: Text(label, style: const TextStyle(fontSize: 12)),
//       style: ElevatedButton.styleFrom(
//         backgroundColor: color,
//         foregroundColor: Colors.white,
//         padding: const EdgeInsets.symmetric(horizontal: 16),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//       ),
//     );
//   }
// }

// class _FilterChip extends StatelessWidget {
//   final String label;
//   final int count;
//   final bool isActive;
//   final VoidCallback onTap;
//   const _FilterChip({required this.label, required this.count, required this.isActive, required this.onTap});

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         decoration: BoxDecoration(
//           color: isActive ? _C.chipActive : Colors.transparent,
//           borderRadius: BorderRadius.circular(20),
//           border: Border.all(color: isActive ? _C.chipActive : _C.divider),
//         ),
//         child: Row(
//           children: [
//             Text(label, style: TextStyle(color: isActive ? Colors.white : _C.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
//             if (count > 0) ...[
//               const SizedBox(width: 4),
//               Text('($count)', style: TextStyle(color: isActive ? Colors.white70 : _C.textLight, fontSize: 10)),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

// class _EmptyState extends StatelessWidget {
//   final FilterTugas filter;
//   const _EmptyState({required this.filter});
//   @override
//   Widget build(BuildContext context) => const Center(child: Text('Tidak ada tugas ditemukan'));
// }
