// // lib/petugas/petugas_daftar_tugas_screen.dart
// // Versi lo-fi: tanpa Hive, tanpa Provider — data dummy, setState biasa

// import 'package:flutter/material.dart';
// import 'laporan_fasilitas_dummy.dart';

// // ── Entry Screen ─────────────────────────────────────────────────────────────

// class PetugasDaftarTugasScreen extends StatefulWidget {
//   final String petugasId;
//   final String petugasName;

//   const PetugasDaftarTugasScreen({
//     super.key,
//     required this.petugasId,
//     required this.petugasName,
//   });

//   @override
//   State<PetugasDaftarTugasScreen> createState() =>
//       _PetugasDaftarTugasScreenState();
// }

// class _PetugasDaftarTugasScreenState extends State<PetugasDaftarTugasScreen>
//     with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   bool _isLoading = false;

//   // Data lokal — salinan dari dummy agar bisa diubah dengan setState
//   late List<LaporanFasilitas> _tasks;

//   final List<Map<String, String>> _tabs = [
//     {'label': 'Semua', 'key': 'semua'},
//     {'label': 'Menunggu', 'key': 'menunggu'},
//     {'label': 'Diproses', 'key': 'diproses'},
//     {'label': 'Selesai', 'key': 'selesai'},
//   ];

//   String _filterStatus = 'semua';

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: _tabs.length, vsync: this);
//     // Salin list dummy agar mutasi tidak memengaruhi sumber asli
//     _tasks = List.from(dummyTasks);
//   }

//   @override
//   void dispose() {
//     _tabController.dispose();
//     super.dispose();
//   }

//   // ── Getters ───────────────────────────────────────────────────────────────

//   List<LaporanFasilitas> get _filtered {
//     if (_filterStatus == 'semua') return _tasks;
//     if (_filterStatus == 'menunggu') {
//       return _tasks.where((t) => t.status == 'assigned').toList();
//     }
//     if (_filterStatus == 'diproses') {
//       return _tasks.where((t) => t.status == 'in_progress').toList();
//     }
//     if (_filterStatus == 'selesai') {
//       return _tasks.where((t) => t.status == 'resolved').toList();
//     }
//     return _tasks;
//   }

//   List<LaporanFasilitas> get _urgent => _tasks
//       .where((t) =>
//           t.prioritas == 'high' &&
//           (t.status == 'assigned' || t.status == 'in_progress'))
//       .toList();

//   int get _pending => _tasks.where((t) => t.status == 'assigned').length;
//   int get _inProgress => _tasks.where((t) => t.status == 'in_progress').length;
//   int get _completed => _tasks.where((t) => t.status == 'resolved').length;

//   // ── Actions ───────────────────────────────────────────────────────────────

//   Future<void> _refresh() async {
//     setState(() => _isLoading = true);
//     await Future.delayed(const Duration(milliseconds: 800));
//     setState(() {
//       _tasks = List.from(dummyTasks);
//       _isLoading = false;
//     });
//   }

//   void _mulaiKerjakan(LaporanFasilitas tugas) {
//     setState(() {
//       tugas.status = 'in_progress';
//       tugas.updatedAt = DateTime.now();
//     });
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Tugas mulai dikerjakan'),
//         backgroundColor: Color(0xFF1565C0),
//         duration: Duration(seconds: 2),
//       ),
//     );
//   }

//   void _openSelesaikan(LaporanFasilitas tugas) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => _SelesaikanScreen(
//           tugas: tugas,
//           petugasName: widget.petugasName,
//           onSelesai: (catatan, durasi) {
//             setState(() {
//               tugas.status = 'resolved';
//               tugas.updatedAt = DateTime.now();
//             });
//           },
//         ),
//       ),
//     );
//   }

//   // ── Build ─────────────────────────────────────────────────────────────────

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F4F8),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.menu, color: Color(0xFF1E3A5F)),
//           onPressed: () {},
//         ),
//         title: const Text(
//           'Technician Portal',
//           style: TextStyle(
//             color: Color(0xFF1E3A5F),
//             fontWeight: FontWeight.bold,
//             fontSize: 16,
//           ),
//         ),
//         actions: [
//           Padding(
//             padding: const EdgeInsets.only(right: 14),
//             child: CircleAvatar(
//               radius: 17,
//               backgroundColor: const Color(0xFF1E3A5F),
//               child: Text(
//                 widget.petugasName.isNotEmpty
//                     ? widget.petugasName[0].toUpperCase()
//                     : 'P',
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                     fontSize: 14),
//               ),
//             ),
//           ),
//         ],
//         bottom: PreferredSize(
//           preferredSize: const Size.fromHeight(48),
//           child: TabBar(
//             controller: _tabController,
//             onTap: (i) => setState(() => _filterStatus = _tabs[i]['key']!),
//             isScrollable: true,
//             labelColor: const Color(0xFF1E3A5F),
//             unselectedLabelColor: Colors.grey,
//             indicatorColor: const Color(0xFF1E3A5F),
//             indicatorWeight: 3,
//             labelStyle: const TextStyle(
//                 fontWeight: FontWeight.w700, fontSize: 13),
//             unselectedLabelStyle: const TextStyle(
//                 fontWeight: FontWeight.w500, fontSize: 13),
//             tabs: _tabs.map((t) => Tab(text: t['label'])).toList(),
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? const Center(
//               child: CircularProgressIndicator(color: Color(0xFF1E3A5F)))
//           : RefreshIndicator(
//               color: const Color(0xFF1E3A5F),
//               onRefresh: _refresh,
//               child: CustomScrollView(
//                 slivers: [
//                   // ── Header ─────────────────────────────────────────────
//                   SliverToBoxAdapter(
//                     child: Padding(
//                       padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             'Daftar Tugas',
//                             style: TextStyle(
//                               fontWeight: FontWeight.bold,
//                               fontSize: 26,
//                               color: Color(0xFF1E3A5F),
//                             ),
//                           ),
//                           const SizedBox(height: 4),
//                           Text(
//                             'Tugas yang diberikan kepada anda',
//                             style: TextStyle(
//                                 color: Colors.grey[500], fontSize: 13),
//                           ),
//                           const SizedBox(height: 16),
//                           _buildStatsRow(),
//                           const SizedBox(height: 12),
//                           if (_urgent.isNotEmpty)
//                             _buildUrgentBanner(_urgent.length),
//                         ],
//                       ),
//                     ),
//                   ),

//                   // ── List tugas ─────────────────────────────────────────
//                   _filtered.isEmpty
//                       ? SliverFillRemaining(child: _buildEmpty())
//                       : SliverPadding(
//                           padding:
//                               const EdgeInsets.fromLTRB(16, 8, 16, 32),
//                           sliver: SliverList(
//                             delegate: SliverChildBuilderDelegate(
//                               (ctx, i) {
//                                 final tugas = _filtered[i];
//                                 return _TugasCard(
//                                   tugas: tugas,
//                                   onMulai: () => _mulaiKerjakan(tugas),
//                                   onSelesaikan: () =>
//                                       _openSelesaikan(tugas),
//                                 );
//                               },
//                               childCount: _filtered.length,
//                             ),
//                           ),
//                         ),
//                 ],
//               ),
//             ),
//       bottomNavigationBar: _buildBottomNav(),
//     );
//   }

//   // ── Widgets ───────────────────────────────────────────────────────────────

//   Widget _buildStatsRow() {
//     return Row(
//       children: [
//         _StatChip(
//             label: 'Menunggu',
//             count: _pending,
//             color: Colors.orange,
//             icon: Icons.schedule_outlined),
//         const SizedBox(width: 10),
//         _StatChip(
//             label: 'Diproses',
//             count: _inProgress,
//             color: const Color(0xFF1565C0),
//             icon: Icons.autorenew_outlined),
//         const SizedBox(width: 10),
//         _StatChip(
//             label: 'Selesai',
//             count: _completed,
//             color: Colors.green,
//             icon: Icons.check_circle_outline),
//       ],
//     );
//   }

//   Widget _buildUrgentBanner(int count) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 4),
//       padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
//       decoration: BoxDecoration(
//         color: Colors.red.withOpacity(0.07),
//         borderRadius: BorderRadius.circular(10),
//         border: Border.all(color: Colors.red.withOpacity(0.25)),
//       ),
//       child: Row(
//         children: [
//           const Icon(Icons.warning_amber_rounded,
//               color: Colors.red, size: 18),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               '$count tugas mendesak perlu segera ditangani',
//               style: const TextStyle(
//                   color: Colors.red,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEmpty() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.assignment_outlined,
//               size: 64, color: Colors.grey[300]),
//           const SizedBox(height: 12),
//           Text('Tidak ada tugas',
//               style: TextStyle(color: Colors.grey[400], fontSize: 14)),
//         ],
//       ),
//     );
//   }

//   Widget _buildBottomNav() {
//     return BottomNavigationBar(
//       currentIndex: 1,
//       selectedItemColor: const Color(0xFF1E3A5F),
//       unselectedItemColor: Colors.grey,
//       type: BottomNavigationBarType.fixed,
//       selectedLabelStyle:
//           const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
//       items: const [
//         BottomNavigationBarItem(
//             icon: Icon(Icons.home_outlined), label: 'Beranda'),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.assignment_outlined), label: 'Tugas'),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.history_outlined), label: 'Riwayat'),
//         BottomNavigationBarItem(
//             icon: Icon(Icons.person_outline), label: 'Profil'),
//       ],
//       onTap: (_) {},
//     );
//   }
// }

// // ── Stat Chip ─────────────────────────────────────────────────────────────────

// class _StatChip extends StatelessWidget {
//   final String label;
//   final int count;
//   final Color color;
//   final IconData icon;

//   const _StatChip({
//     required this.label,
//     required this.count,
//     required this.color,
//     required this.icon,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: Container(
//         padding:
//             const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.04),
//               blurRadius: 6,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Row(
//           children: [
//             Icon(icon, size: 16, color: color),
//             const SizedBox(width: 6),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   '$count',
//                   style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: color),
//                 ),
//                 Text(label,
//                     style: const TextStyle(
//                         color: Colors.grey, fontSize: 10)),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // ── Tugas Card ────────────────────────────────────────────────────────────────

// class _TugasCard extends StatelessWidget {
//   final LaporanFasilitas tugas;
//   final VoidCallback onMulai;
//   final VoidCallback onSelesaikan;

//   const _TugasCard({
//     required this.tugas,
//     required this.onMulai,
//     required this.onSelesaikan,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final statusColor = _statusColor(tugas.status);
//     final statusLabel = _statusLabel(tugas.status);
//     final isPriorHigh = tugas.prioritas == 'high';

//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         border: isPriorHigh && tugas.status != 'resolved'
//             ? Border.all(color: Colors.red.withOpacity(0.2), width: 1.5)
//             : null,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 10,
//             offset: const Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Top row: ID + badges
//             Row(
//               children: [
//                 Text(
//                   '#REP-${tugas.id.substring(0, 7).toUpperCase()}',
//                   style: const TextStyle(
//                       color: Colors.grey,
//                       fontSize: 11,
//                       fontWeight: FontWeight.w500),
//                 ),
//                 const Spacer(),
//                 if (isPriorHigh && tugas.status != 'resolved') ...[
//                   Container(
//                     margin: const EdgeInsets.only(right: 6),
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 7, vertical: 3),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(5),
//                     ),
//                     child: const Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(Icons.warning_amber_rounded,
//                             color: Colors.white, size: 10),
//                         SizedBox(width: 2),
//                         Text('High',
//                             style: TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold)),
//                       ],
//                     ),
//                   ),
//                 ],
//                 // Status badge
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                       horizontal: 9, vertical: 4),
//                   decoration: BoxDecoration(
//                     color: statusColor.withOpacity(0.12),
//                     borderRadius: BorderRadius.circular(6),
//                   ),
//                   child: Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(Icons.circle, size: 6, color: statusColor),
//                       const SizedBox(width: 4),
//                       Text(
//                         statusLabel,
//                         style: TextStyle(
//                             color: statusColor,
//                             fontSize: 10,
//                             fontWeight: FontWeight.w700),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 10),

//             // Judul
//             Text(
//               tugas.judul,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold,
//                   fontSize: 15,
//                   color: Color(0xFF1E3A5F)),
//             ),
//             const SizedBox(height: 6),

//             // Deskripsi
//             Text(
//               tugas.deskripsi,
//               style: TextStyle(
//                   color: Colors.grey[500], fontSize: 12, height: 1.4),
//               maxLines: 2,
//               overflow: TextOverflow.ellipsis,
//             ),
//             const SizedBox(height: 8),

//             // Lokasi
//             Row(
//               children: [
//                 const Icon(Icons.location_on_outlined,
//                     size: 13, color: Colors.grey),
//                 const SizedBox(width: 3),
//                 Expanded(
//                   child: Text(
//                     tugas.lokasiLabKelas,
//                     style: const TextStyle(
//                         color: Colors.grey, fontSize: 12),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ),
//               ],
//             ),

//             // Deadline
//             if (tugas.estimasiSelesai != null) ...[
//               const SizedBox(height: 4),
//               Row(
//                 children: [
//                   const Icon(Icons.access_time_outlined,
//                       size: 13, color: Colors.grey),
//                   const SizedBox(width: 3),
//                   Text(
//                     'Batas: ${_formatDeadline(tugas.estimasiSelesai!)}',
//                     style: TextStyle(
//                       color: _isDeadlineNear(tugas.estimasiSelesai!)
//                           ? Colors.orange
//                           : Colors.grey,
//                       fontSize: 12,
//                       fontWeight:
//                           _isDeadlineNear(tugas.estimasiSelesai!)
//                               ? FontWeight.w600
//                               : FontWeight.normal,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//             const SizedBox(height: 14),

//             // Action button
//             if (tugas.status == 'assigned')
//               _ActionButton(
//                 label: 'Mulai Kerjakan',
//                 color: const Color(0xFF1E3A5F),
//                 icon: Icons.play_arrow_rounded,
//                 onTap: onMulai,
//               )
//             else if (tugas.status == 'in_progress')
//               _ActionButton(
//                 label: 'Selesaikan',
//                 color: Colors.green.shade600,
//                 icon: Icons.check_circle_outline,
//                 onTap: onSelesaikan,
//               )
//             else if (tugas.status == 'resolved')
//               Container(
//                 width: double.infinity,
//                 height: 42,
//                 decoration: BoxDecoration(
//                   color: Colors.green.withOpacity(0.08),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 child: const Center(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.check_circle,
//                           color: Colors.green, size: 16),
//                       SizedBox(width: 6),
//                       Text('Selesai',
//                           style: TextStyle(
//                               color: Colors.green,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 13)),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _statusColor(String status) {
//     switch (status) {
//       case 'assigned':
//         return Colors.orange;
//       case 'in_progress':
//         return const Color(0xFF1565C0);
//       case 'resolved':
//         return Colors.green;
//       default:
//         return Colors.grey;
//     }
//   }

//   String _statusLabel(String status) {
//     switch (status) {
//       case 'assigned':
//         return 'MENUNGGU';
//       case 'in_progress':
//         return 'DIPROSES';
//       case 'resolved':
//         return 'SELESAI';
//       default:
//         return status.toUpperCase();
//     }
//   }

//   String _formatDeadline(DateTime dt) {
//     const days = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];
//     final h = dt.hour.toString().padLeft(2, '0');
//     final m = dt.minute.toString().padLeft(2, '0');
//     return '${days[dt.weekday - 1]}, ${dt.day}/${dt.month} · $h:$m WIB';
//   }

//   bool _isDeadlineNear(DateTime deadline) {
//     return deadline.difference(DateTime.now()).inHours < 6;
//   }
// }

// // ── Action Button ─────────────────────────────────────────────────────────────

// class _ActionButton extends StatelessWidget {
//   final String label;
//   final Color color;
//   final IconData icon;
//   final VoidCallback onTap;

//   const _ActionButton({
//     required this.label,
//     required this.color,
//     required this.icon,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       height: 42,
//       child: ElevatedButton.icon(
//         onPressed: onTap,
//         icon: Icon(icon, color: Colors.white, size: 16),
//         label: Text(
//           label,
//           style: const TextStyle(
//               color: Colors.white,
//               fontWeight: FontWeight.w600,
//               fontSize: 13),
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: color,
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(10)),
//           elevation: 0,
//         ),
//       ),
//     );
//   }
// }

// // ── Selesaikan Screen ─────────────────────────────────────────────────────────

// class _SelesaikanScreen extends StatefulWidget {
//   final LaporanFasilitas tugas;
//   final String petugasName;
//   final void Function(String catatan, int? durasi) onSelesai;

//   const _SelesaikanScreen({
//     required this.tugas,
//     required this.petugasName,
//     required this.onSelesai,
//   });

//   @override
//   State<_SelesaikanScreen> createState() => _SelesaikanScreenState();
// }

// class _SelesaikanScreenState extends State<_SelesaikanScreen> {
//   final _catatanCtrl = TextEditingController();
//   final _durasiCtrl = TextEditingController();
//   bool _isSubmitting = false;
//   // Simulasi foto yang dipilih (dummy)
//   bool _fotoSelected = false;

//   @override
//   void dispose() {
//     _catatanCtrl.dispose();
//     _durasiCtrl.dispose();
//     super.dispose();
//   }

//   Future<void> _submit() async {
//     if (_catatanCtrl.text.trim().isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Isi catatan penyelesaian terlebih dahulu'),
//           backgroundColor: Colors.orange,
//         ),
//       );
//       return;
//     }
//     setState(() => _isSubmitting = true);
//     // Simulasi delay network
//     await Future.delayed(const Duration(seconds: 1));

//     widget.onSelesai(
//       _catatanCtrl.text,
//       int.tryParse(_durasiCtrl.text),
//     );

//     if (mounted) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Tugas berhasil diselesaikan!'),
//           backgroundColor: Colors.green,
//         ),
//       );
//       Navigator.pop(context);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final t = widget.tugas;

//     return Scaffold(
//       backgroundColor: const Color(0xFFF0F4F8),
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Color(0xFF1E3A5F)),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Detail Tugas',
//           style: TextStyle(
//               color: Color(0xFF1E3A5F),
//               fontWeight: FontWeight.bold,
//               fontSize: 16),
//         ),
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Status + ID row
//             Row(
//               children: [
//                 _StatusBadge(status: t.status),
//                 const Spacer(),
//                 Text(
//                   'TGS-${t.id.substring(0, 7).toUpperCase()}',
//                   style: const TextStyle(
//                       color: Colors.grey, fontSize: 11),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 14),

//             // Judul & lokasi
//             Text(t.judul,
//                 style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 20,
//                     color: Color(0xFF1E3A5F))),
//             const SizedBox(height: 6),
//             Row(
//               children: [
//                 const Icon(Icons.location_on_outlined,
//                     size: 14, color: Colors.grey),
//                 const SizedBox(width: 4),
//                 Expanded(
//                   child: Text(t.lokasiLabKelas,
//                       style: const TextStyle(
//                           color: Colors.grey, fontSize: 13)),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 20),

//             // Info card
//             _InfoCard(tugas: t),
//             const SizedBox(height: 16),

//             // Foto kondisi awal (placeholder)
//             _SectionCard(
//               title: 'Foto Kondisi Awal',
//               child: Row(
//                 children: [
//                   _PhotoBox(hasImage: false),
//                   const SizedBox(width: 8),
//                   _PhotoBox(hasImage: false),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 16),

//             // Form laporan penyelesaian
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(14),
//                 border: Border.all(
//                     color: const Color(0xFF1E3A5F).withOpacity(0.2),
//                     width: 1.5),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.04),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Laporan Penyelesaian',
//                     style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 15,
//                         color: Color(0xFF1E3A5F)),
//                   ),
//                   const SizedBox(height: 16),

//                   // Upload foto bukti
//                   const _FieldLabel('Foto Bukti Perbaikan'),
//                   const SizedBox(height: 8),
//                   GestureDetector(
//                     onTap: () => setState(() => _fotoSelected = true),
//                     child: Container(
//                       width: double.infinity,
//                       height: 100,
//                       decoration: BoxDecoration(
//                         color: _fotoSelected
//                             ? Colors.green.withOpacity(0.05)
//                             : Colors.grey[50],
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(
//                           color: _fotoSelected
//                               ? Colors.green.withOpacity(0.4)
//                               : Colors.grey[300]!,
//                         ),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(
//                             _fotoSelected
//                                 ? Icons.check_circle_outline
//                                 : Icons.camera_alt_outlined,
//                             color: _fotoSelected
//                                 ? Colors.green
//                                 : Colors.grey[400],
//                             size: 30,
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             _fotoSelected
//                                 ? '1 foto dipilih (simulasi)'
//                                 : 'Ketuk untuk unggah foto',
//                             style: TextStyle(
//                                 color: _fotoSelected
//                                     ? Colors.green
//                                     : Colors.grey[400],
//                                 fontSize: 13),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 16),

//                   // Catatan
//                   const _FieldLabel('Tindakan & Catatan'),
//                   const SizedBox(height: 8),
//                   _buildTextField(
//                     controller: _catatanCtrl,
//                     hint: 'Tuliskan detail perbaikan yang dilakukan...',
//                     maxLines: 3,
//                   ),
//                   const SizedBox(height: 16),

//                   // Durasi
//                   const _FieldLabel('Durasi Pengerjaan (Menit)'),
//                   const SizedBox(height: 8),
//                   _buildTextField(
//                     controller: _durasiCtrl,
//                     hint: 'Cth. 45',
//                     keyboardType: TextInputType.number,
//                     prefixIcon: Icons.timer_outlined,
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 100),
//           ],
//         ),
//       ),
//       bottomNavigationBar: Container(
//         color: Colors.white,
//         padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
//         child: SizedBox(
//           width: double.infinity,
//           height: 52,
//           child: ElevatedButton(
//             onPressed: _isSubmitting ? null : _submit,
//             style: ElevatedButton.styleFrom(
//               backgroundColor: const Color(0xFF1E3A5F),
//               disabledBackgroundColor:
//                   const Color(0xFF1E3A5F).withOpacity(0.5),
//               shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12)),
//               elevation: 0,
//             ),
//             child: _isSubmitting
//                 ? const SizedBox(
//                     height: 22,
//                     width: 22,
//                     child: CircularProgressIndicator(
//                         color: Colors.white, strokeWidth: 2.5))
//                 : const Row(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.check_circle_outline,
//                           color: Colors.white, size: 18),
//                       SizedBox(width: 8),
//                       Text(
//                         'Selesaikan Tugas',
//                         style: TextStyle(
//                             color: Colors.white,
//                             fontWeight: FontWeight.bold,
//                             fontSize: 15),
//                       ),
//                     ],
//                   ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     int maxLines = 1,
//     TextInputType? keyboardType,
//     IconData? prefixIcon,
//   }) {
//     return TextField(
//       controller: controller,
//       maxLines: maxLines,
//       keyboardType: keyboardType,
//       style: const TextStyle(fontSize: 13),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(fontSize: 13, color: Colors.grey[400]),
//         prefixIcon: prefixIcon != null
//             ? Icon(prefixIcon, size: 18, color: Colors.grey)
//             : null,
//         filled: true,
//         fillColor: Colors.grey[50],
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: BorderSide(color: Colors.grey[300]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(10),
//           borderSide: const BorderSide(
//               color: Color(0xFF1E3A5F), width: 1.5),
//         ),
//         contentPadding: const EdgeInsets.all(14),
//       ),
//     );
//   }
// }

// // ── Reusable sub-widgets ──────────────────────────────────────────────────────

// class _StatusBadge extends StatelessWidget {
//   final String status;
//   const _StatusBadge({required this.status});

//   @override
//   Widget build(BuildContext context) {
//     Color color;
//     IconData icon;
//     String label;

//     switch (status) {
//       case 'in_progress':
//         color = const Color(0xFF1565C0);
//         icon = Icons.autorenew_outlined;
//         label = 'SEDANG DIKERJAKAN';
//         break;
//       case 'assigned':
//         color = Colors.orange;
//         icon = Icons.schedule_outlined;
//         label = 'MENUNGGU';
//         break;
//       default:
//         color = Colors.green;
//         icon = Icons.check_circle_outline;
//         label = 'SELESAI';
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//       decoration: BoxDecoration(
//         color: color.withOpacity(0.1),
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 13, color: color),
//           const SizedBox(width: 4),
//           Text(label,
//               style: TextStyle(
//                   color: color,
//                   fontSize: 11,
//                   fontWeight: FontWeight.bold)),
//         ],
//       ),
//     );
//   }
// }

// class _InfoCard extends StatelessWidget {
//   final LaporanFasilitas tugas;
//   const _InfoCard({required this.tugas});

//   @override
//   Widget build(BuildContext context) {
//     final h = tugas.createdAt.hour.toString().padLeft(2, '0');
//     final m = tugas.createdAt.minute.toString().padLeft(2, '0');

//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           _infoRow(Icons.person_outline, 'PELAPOR', tugas.pelaporName),
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 10),
//             child: Divider(height: 1),
//           ),
//           _infoRow(Icons.access_time_outlined, 'WAKTU LAPORAN',
//               'Hari ini, $h:$m WIB'),
//           const Padding(
//             padding: EdgeInsets.symmetric(vertical: 10),
//             child: Divider(height: 1),
//           ),
//           _infoRow(Icons.description_outlined, 'DESKRIPSI MASALAH',
//               tugas.deskripsi),
//         ],
//       ),
//     );
//   }

//   Widget _infoRow(IconData icon, String label, String value) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 16, color: Colors.grey[400]),
//         const SizedBox(width: 10),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(label,
//                   style: const TextStyle(
//                       fontSize: 10,
//                       color: Colors.grey,
//                       letterSpacing: 0.5,
//                       fontWeight: FontWeight.w500)),
//               const SizedBox(height: 3),
//               Text(value,
//                   style: const TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                       color: Colors.black87)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _SectionCard extends StatelessWidget {
//   final String title;
//   final Widget child;
//   const _SectionCard({required this.title, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(14),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(title,
//               style: const TextStyle(
//                   fontWeight: FontWeight.bold, fontSize: 14)),
//           const SizedBox(height: 12),
//           child,
//         ],
//       ),
//     );
//   }
// }

// class _PhotoBox extends StatelessWidget {
//   final bool hasImage;
//   const _PhotoBox({required this.hasImage});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: 80,
//       height: 80,
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(8),
//         border: Border.all(color: Colors.grey[200]!),
//       ),
//       child: Icon(
//         hasImage ? Icons.image : Icons.image_outlined,
//         color: Colors.grey[300],
//         size: 32,
//       ),
//     );
//   }
// }

// class _FieldLabel extends StatelessWidget {
//   final String text;
//   const _FieldLabel(this.text);

//   @override
//   Widget build(BuildContext context) {
//     return Text(
//       text,
//       style:
//           const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
//     );
//   }
// }