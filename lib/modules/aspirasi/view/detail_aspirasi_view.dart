import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/controller/aspirasi_controller.dart';
import 'package:proyek_4_poki_polban_kita/modules/aspirasi/model/aspirasi_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';
import 'package:proyek_4_poki_polban_kita/shared/widgets/app_button.dart';

class DetailAspirasiView extends StatefulWidget {
  final AspirasiModel aspirasi;
  final String role;

  const DetailAspirasiView({
    super.key,
    required this.aspirasi,
    required this.role,
  });

  @override
  State<DetailAspirasiView> createState() => _DetailAspirasiViewState();
}

class _DetailAspirasiViewState extends State<DetailAspirasiView> {
  final _tanggapanController = TextEditingController();
  final _aspirasiController = Get.find<AspirasiController>();
  late AspirasiModel _currentAspirasi;
  bool _isSaving = false;

  bool get _isAdminOrTu => widget.role == 'tu' || widget.role == 'admin';

  @override
  void initState() {
    super.initState();
    _currentAspirasi = widget.aspirasi;
    _tanggapanController.text = _currentAspirasi.tanggapanJurusan ?? '';
  }

  @override
  void dispose() {
    _tanggapanController.dispose();
    super.dispose();
  }

  Future<void> _saveTanggapan() async {
    final text = _tanggapanController.text.trim();
    if (text.isEmpty) {
      Get.snackbar(
        'Peringatan',
        'Tanggapan tidak boleh kosong',
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
      );
      return;
    }

    setState(() => _isSaving = true);
    await _aspirasiController.submitTanggapan(_currentAspirasi.id, text);
    
    // Update local state
    final updated = _aspirasiController.displayedAspirasi.firstWhere(
      (a) => a.id == _currentAspirasi.id,
      orElse: () => _currentAspirasi,
    );
    
    setState(() {
      _currentAspirasi = updated;
      _isSaving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final overallVote = _currentAspirasi.upvoteCount - _currentAspirasi.downvoteCount;
    final isUpvoted = _aspirasiController.isUpvoted(_currentAspirasi);
    final isDownvoted = _aspirasiController.isDownvoted(_currentAspirasi);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: AppColors.title),
        title: const Text(
          'Detail Aspirasi',
          style: TextStyle(
            color: AppColors.title,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Konten Aspirasi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Profil Pelapor & Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.primary,
                        child: Text(
                          _currentAspirasi.initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentAspirasi.pelaporName ?? 'Mahasiswa JTK',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: AppColors.title,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${_currentAspirasi.pelaporProdi ?? ''} • ${_currentAspirasi.waktuRelatif}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.body,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      ),
                      _buildStatusBadge(_currentAspirasi.status),
                    ],
                  ),
                  const Divider(height: 32, color: AppColors.border),

                  // Detail Topik & Isi
                  Text(
                    _currentAspirasi.topik,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.title,
                      fontFamily: 'Poppins',
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _currentAspirasi.isiSaran,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.body,
                      fontFamily: 'Poppins',
                      height: 1.6,
                    ),
                  ),

                  // Vote Column/Section
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.keyboard_arrow_up_rounded,
                              color: isUpvoted ? AppColors.primary : Colors.grey,
                              size: 28,
                            ),
                            onPressed: _isAdminOrTu ? null : () async {
                              await _aspirasiController.onUpvote(_currentAspirasi.id);
                              setState(() {
                                _currentAspirasi = _aspirasiController.displayedAspirasi.firstWhere(
                                  (a) => a.id == _currentAspirasi.id,
                                );
                              });
                            },
                          ),
                          Text(
                            '$overallVote',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.title,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: isDownvoted ? AppColors.danger : Colors.grey,
                              size: 28,
                            ),
                            onPressed: _isAdminOrTu ? null : () async {
                              await _aspirasiController.onDownvote(_currentAspirasi.id);
                              setState(() {
                                _currentAspirasi = _aspirasiController.displayedAspirasi.firstWhere(
                                  (a) => a.id == _currentAspirasi.id,
                                );
                              });
                            },
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        'Upvote: ${_currentAspirasi.upvoteCount} • Downvote: ${_currentAspirasi.downvoteCount}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Tanggapan Jurusan (Jika Ada / Jika User adalah TU/Admin)
            const SizedBox(height: 20),
            if (_currentAspirasi.tanggapanJurusan != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.blueSoft,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.verified_rounded, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text(
                          'TANGGAPAN JURUSAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 0.8,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentAspirasi.tanggapanJurusan!,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.body,
                        fontFamily: 'Poppins',
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Input Form Tanggapan untuk TU / Admin
            if (_isAdminOrTu) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tulis Tanggapan Jurusan',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.title,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _tanggapanController,
                      maxLines: 4,
                      style: const TextStyle(fontFamily: 'Poppins', fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Masukkan tanggapan atau solusi untuk aspirasi ini...',
                        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13),
                        filled: true,
                        fillColor: AppColors.background,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: _isSaving ? 'Menyimpan...' : 'Kirim Tanggapan',
                        onPressed: _isSaving ? () {} : _saveTanggapan,
                        variant: AppButtonVariant.navy,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(StatusAspirasi status) {
    Color bg;
    Color fg;
    String label;
    IconData icon;

    switch (status) {
      case StatusAspirasi.open:
        bg = AppColors.blueSoft;
        fg = AppColors.primary;
        label = 'Terbuka';
        icon = Icons.info_outline_rounded;
        break;
      case StatusAspirasi.inReview:
        bg = AppColors.orangeSoft;
        fg = AppColors.warning;
        label = 'Diproses';
        icon = Icons.hourglass_top_rounded;
        break;
      case StatusAspirasi.responded:
        bg = AppColors.greenSoft;
        fg = AppColors.success;
        label = 'Selesai';
        icon = Icons.check_circle_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: fg,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}
