import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controller/fasilitas_controller.dart';

class AdminDelegasiScreen extends StatefulWidget {
  final LaporanFasilitas laporan;

  const AdminDelegasiScreen({super.key, required this.laporan});

  @override
  State<AdminDelegasiScreen> createState() => _AdminDelegasiScreenState();
}

class _AdminDelegasiScreenState extends State<AdminDelegasiScreen> {
  String? _selectedTeknisiId;
  String _selectedPrioritas = 'medium';
  DateTime? _selectedDeadline;
  final TextEditingController _catatanController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill priority from laporan
    _selectedPrioritas = widget.laporan.prioritas;
  }

  @override
  void dispose() {
    _catatanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.read<AdminFasilitasController>();
    final teknisiList = ctrl.allTeknisi;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Delegasi Tugas',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Laporan info card ───────────────────────────
            _buildLaporanInfoCard(),
            const SizedBox(height: 20),

            // ── Form penugasan ──────────────────────────────
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 3,
                        height: 16,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E3A5F),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'FORM PENUGASAN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: Color(0xFF1E3A5F),
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Pilih Teknisi ─────────────────────────
                  _fieldLabel('Pilih Teknisi'),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedTeknisiId,
                    hint: const Text(
                      'Pilih Teknisi yang tersedia...',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    isExpanded: true,
                    decoration: _inputDecoration(),
                    items: teknisiList
                        .map(
                          (t) => DropdownMenuItem(
                            value: t.id,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 15,
                                  backgroundColor: const Color(
                                    0xFF1E3A5F,
                                  ).withOpacity(0.12),
                                  child: Text(
                                    t.name[0],
                                    style: const TextStyle(
                                      color: Color(0xFF1E3A5F),
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        t.name,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                      ),
                                      Text(
                                        'ID: ${t.nimNip}',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (val) =>
                        setState(() => _selectedTeknisiId = val),
                  ),
                  const SizedBox(height: 18),

                  // ── Prioritas ─────────────────────────────
                  _fieldLabel('Prioritas'),
                  const SizedBox(height: 8),
                  Row(children: _prioritasOptions()),
                  const SizedBox(height: 18),

                  // ── Deadline ──────────────────────────────
                  _fieldLabel('Deadline'),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDeadline,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 13,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey[300]!, width: 1),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 16,
                            color: _selectedDeadline != null
                                ? const Color(0xFF1E3A5F)
                                : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _selectedDeadline != null
                                ? '${_selectedDeadline!.day}/${_selectedDeadline!.month}/${_selectedDeadline!.year}'
                                : 'mm/dd/yyyy',
                            style: TextStyle(
                              color: _selectedDeadline != null
                                  ? Colors.black87
                                  : Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          if (_selectedDeadline != null)
                            GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedDeadline = null),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Colors.grey,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Catatan ───────────────────────────────
                  _fieldLabel('Catatan (Opsional)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _catatanController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13),
                    decoration: _inputDecoration().copyWith(
                      hintText: 'Tambahkan instruksi khusus untuk teknisi...',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Colors.grey,
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // ── Submit button ───────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitDelegasi,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A5F),
                  disabledBackgroundColor: const Color(
                    0xFF1E3A5F,
                  ).withOpacity(0.6),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_turned_in_outlined,
                            color: Colors.white,
                            size: 18,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Tugaskan Teknisi',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ── Widgets helpers ─────────────────────────────────────────────────────────

  Widget _buildLaporanInfoCard() {
    final l = widget.laporan;
    final isPrioritasHigh = l.prioritas == 'high';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isPrioritasHigh
              ? Colors.red.withOpacity(0.3)
              : Colors.grey.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'LAPORAN MASUK',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                ),
              ),
              const Spacer(),
              if (isPrioritasHigh)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.white,
                        size: 12,
                      ),
                      SizedBox(width: 3),
                      Text(
                        'Urgent',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                _PrioritasPill(prioritas: l.prioritas),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            l.judul,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
              color: Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.deskripsi,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
              height: 1.4,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.access_time_outlined,
                size: 13,
                color: Colors.grey,
              ),
              const SizedBox(width: 5),
              Text(
                _formatTime(l.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(width: 16),
              const Icon(
                Icons.location_on_outlined,
                size: 13,
                color: Colors.grey,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  l.lokasiLabKelas,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _prioritasOptions() {
    const options = [
      {'key': 'low', 'label': 'Low'},
      {'key': 'medium', 'label': 'Medium'},
      {'key': 'high', 'label': 'High'},
    ];

    return options.asMap().entries.map((entry) {
      final p = entry.value;
      final isLast = entry.key == options.length - 1;
      final isSelected = _selectedPrioritas == p['key'];
      final color = p['key'] == 'low'
          ? Colors.green
          : p['key'] == 'medium'
          ? Colors.orange
          : Colors.red;

      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _selectedPrioritas = p['key']!),
          child: Container(
            margin: EdgeInsets.only(right: isLast ? 0 : 8),
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.12) : Colors.grey[100],
              borderRadius: BorderRadius.circular(9),
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 1.8,
              ),
            ),
            child: Center(
              child: Text(
                p['label']!,
                style: TextStyle(
                  color: isSelected ? color : Colors.grey[500],
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  Widget _fieldLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        fontSize: 13,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration() {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF1E3A5F), width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  // ── Actions ─────────────────────────────────────────────────────────────────

  Future<void> _pickDeadline() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF1E3A5F)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDeadline = picked);
  }

  Future<void> _submitDelegasi() async {
    if (_selectedTeknisiId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih teknisi terlebih dahulu'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final ctrl = context.read<AdminFasilitasController>();
    final teknisi = ctrl.allTeknisi.firstWhere(
      (t) => t.id == _selectedTeknisiId,
    );

    final success = await ctrl.delegasikanLaporan(
      laporanId: widget.laporan.id,
      teknisiId: _selectedTeknisiId!,
      prioritas: _selectedPrioritas,
      deadline: _selectedDeadline,
      catatan: _catatanController.text.isEmpty ? null : _catatanController.text,
      adminId: 'admin-default',
      adminName: 'Admin',
      teknisiName: teknisi.name,
    );

    setState(() => _isSubmitting = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Laporan berhasil didelegasikan!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(ctrl.errorMessage), backgroundColor: Colors.red),
      );
    }
  }
}

// ── Prioritas pill widget ────────────────────────────────────────────────────

class _PrioritasPill extends StatelessWidget {
  final String prioritas;
  const _PrioritasPill({required this.prioritas});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (prioritas) {
      case 'high':
        color = Colors.red;
        label = 'High';
        break;
      case 'medium':
        color = Colors.orange;
        label = 'Medium';
        break;
      default:
        color = Colors.green;
        label = 'Low';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
