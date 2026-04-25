import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/fasilitas_controller.dart';
import 'delegasi_screen.dart';

class AdminLaporanFasilitasScreen extends StatefulWidget {
  const AdminLaporanFasilitasScreen({super.key});

  @override
  State<AdminLaporanFasilitasScreen> createState() =>
      _AdminLaporanFasilitasScreenState();
}

class _AdminLaporanFasilitasScreenState
    extends State<AdminLaporanFasilitasScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _tabs = [
    {'label': 'Semua', 'key': 'semua'},
    {'label': 'Baru', 'key': 'baru'},
    {'label': 'Ditugaskan', 'key': 'ditugaskan'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminFasilitasController>().loadData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AdminFasilitasController>(
      builder: (context, ctrl, _) {
        final displayed = ctrl.filteredLaporan
            .where(
              (l) =>
                  _searchQuery.isEmpty ||
                  l.judul.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  l.lokasiLabKelas.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ),
            )
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF5F6FA),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            titleSpacing: 16,
            title: Row(
              children: [
                const CircleAvatar(
                  radius: 16,
                  backgroundColor: Color(0xFF1E3A5F),
                  child: Icon(Icons.person, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 10),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Institution Admin',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Kelola Laporan Fasilitas',
                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              Stack(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.black,
                    ),
                    onPressed: () {},
                  ),
                  Positioned(
                    right: 10,
                    top: 10,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: TabBar(
                controller: _tabController,
                onTap: (i) => ctrl.setFilter(_tabs[i]['key']!),
                labelColor: const Color(0xFF1E3A5F),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF1E3A5F),
                indicatorWeight: 3,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
                tabs: _tabs.map((t) => Tab(text: t['label'])).toList(),
              ),
            ),
          ),
          body: Column(
            children: [
              // Search bar
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Cari laporan...',
                    hintStyle: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Colors.grey,
                      size: 20,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? GestureDetector(
                            onTap: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.grey,
                              size: 18,
                            ),
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              // Count chip
              if (!ctrl.isLoading)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: Row(
                    children: [
                      Text(
                        '${displayed.length} laporan ditemukan',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

              // List
              Expanded(
                child: ctrl.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1E3A5F),
                        ),
                      )
                    : displayed.isEmpty
                    ? _buildEmpty()
                    : RefreshIndicator(
                        color: const Color(0xFF1E3A5F),
                        onRefresh: () => ctrl.loadData(),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: displayed.length,
                          itemBuilder: (context, i) {
                            final laporan = displayed[i];
                            return _LaporanCard(
                              laporan: laporan,
                              onDelegasi: laporan.status == 'pending'
                                  ? () => _openDelegasi(laporan)
                                  : null,
                              onDetail: () => _openDetail(laporan),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Tidak ada laporan',
            style: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _openDelegasi(LaporanFasilitas laporan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider.value(
          value: context.read<AdminFasilitasController>(),
          child: AdminDelegasiScreen(laporan: laporan),
        ),
      ),
    );
  }

  void _openDetail(LaporanFasilitas laporan) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Detail: ${laporan.judul}')));
  }

  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: 1,
      selectedItemColor: const Color(0xFF1E3A5F),
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 11,
      ),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard_outlined),
          label: 'Dashboard',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.build_outlined),
          label: 'Facilities',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.lightbulb_outline),
          label: 'Aspirations',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people_outline),
          label: 'Users',
        ),
      ],
      onTap: (i) {},
    );
  }
}

// ── Laporan Card ─────────────────────────────────────────────────────────────

class _LaporanCard extends StatelessWidget {
  final LaporanFasilitas laporan;
  final VoidCallback? onDelegasi;
  final VoidCallback onDetail;

  const _LaporanCard({
    required this.laporan,
    this.onDelegasi,
    required this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    final isPriorHigh = laporan.prioritas == 'high';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isPriorHigh
            ? Border.all(color: Colors.red.withOpacity(0.25), width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: kategori badge + time + priority
            Row(
              children: [
                _KategoriBadge(
                  label: laporan.namaKategori ?? laporan.kategoriId,
                  status: laporan.status,
                ),
                const Spacer(),
                if (isPriorHigh)
                  Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'Urgent',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  _timeAgo(laporan.createdAt),
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Judul
            Text(
              laporan.judul,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1E3A5F),
              ),
            ),
            const SizedBox(height: 5),

            // Lokasi
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 13,
                  color: Colors.grey,
                ),
                const SizedBox(width: 3),
                Expanded(
                  child: Text(
                    laporan.lokasiLabKelas,
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            // Handler info (jika sudah ditugaskan)
            if (laporan.handlerName != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(
                    Icons.engineering_outlined,
                    size: 13,
                    color: Colors.blueGrey,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    'Ditugaskan ke: ${laporan.handlerName}',
                    style: const TextStyle(
                      color: Colors.blueGrey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 14),

            // Action button
            if (onDelegasi != null)
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  onPressed: onDelegasi,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A5F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Delegasikan',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 15, color: Colors.white),
                    ],
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  onPressed: onDetail,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Color(0xFF1E3A5F),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Lihat Detail',
                    style: TextStyle(
                      color: Color(0xFF1E3A5F),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${diff.inDays}h lalu';
  }
}

class _KategoriBadge extends StatelessWidget {
  final String label;
  final String status;

  const _KategoriBadge({required this.label, required this.status});

  Color _color() {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'in_progress':
        return Colors.purple;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: c.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}
