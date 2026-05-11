// ============================================================
// FILE: modules/aspirasi/controller/aspirasi_controller.dart
// Kelompok A7 â€“ SIMJTK (Sistem Informasi Mahasiswa JTK)
// ============================================================
//
// Dependency: get: ^4.6.6
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/aspirasi_model.dart';

class AspirasiController  
    extends GetxController
    with GetSingleTickerProviderStateMixin {
  // --------------------------------------------------------
  // TAB CONTROLLER
  // --------------------------------------------------------
  late TabController tabController;

  // --------------------------------------------------------
  // STATE OBSERVABLES â€” LIST
  // --------------------------------------------------------

  /// Semua aspirasi (raw dari server/cache)
  final RxList<AspirasiModel> _allAspirasi = <AspirasiModel>[].obs;

  /// Aspirasi yang ditampilkan sesuai tab aktif
  final RxList<AspirasiModel> displayedAspirasi = <AspirasiModel>[].obs;

  /// Tab yang sedang aktif
  final Rx<TabAspirasi> activeTab = TabAspirasi.terbaru.obs;

  /// Status loading
  final RxBool isLoading = false.obs;

  /// ID user yang sedang login (ambil dari AuthController di implementasi nyata)
  final String currentUserId = 'usr-001';
  final String currentUserName = 'Budi';
  final String currentUserProdi = 'D3 Teknik Informatika';

  // --------------------------------------------------------
  // STATE OBSERVABLES â€” FORM
  // --------------------------------------------------------

  /// Controller teks area aspirasi
  final isiSaranController = TextEditingController();

  /// Toggle anonymous
  final RxBool isAnonymous = false.obs;

  /// Status submitting form
  final RxBool isSubmitting = false.obs;

  /// Error teks deskripsi
  final RxString errorIsiSaran = ''.obs;

  /// Mode â€” true: tampilkan form, false: tampilkan list
  final RxBool showForm = false.obs;

  // --------------------------------------------------------
  // CONSTANTS
  // --------------------------------------------------------
  static const int minIsiSaranLength = 20;
  static const int maxIsiSaranLength = 1000;

  // --------------------------------------------------------
  // LIFECYCLE
  // --------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    tabController = TabController(length: 3, vsync: this);
    tabController.addListener(_onTabChanged);
    _loadAspirasi();

    isiSaranController.addListener(() {
      if (isiSaranController.text.isNotEmpty) errorIsiSaran.value = '';
    });
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    isiSaranController.dispose();
    super.onClose();
  }

  // --------------------------------------------------------
  // PRIVATE METHODS
  // --------------------------------------------------------

  Future<void> _loadAspirasi() async {
    isLoading.value = true;
    await Future.delayed(const Duration(milliseconds: 500));
    _allAspirasi.assignAll(AspirasiModel.dummyList());
    _applyFilter();
    isLoading.value = false;
  }

  void _onTabChanged() {
    if (tabController.indexIsChanging) return;
    switch (tabController.index) {
      case 0:
        activeTab.value = TabAspirasi.terbaru;
        break;
      case 1:
        activeTab.value = TabAspirasi.terpopuler;
        break;
      case 2:
        activeTab.value = TabAspirasi.diproses;
        break;
    }
    _applyFilter();
  }

  void _applyFilter() {
    switch (activeTab.value) {
      case TabAspirasi.terbaru:
        final sorted = List<AspirasiModel>.from(_allAspirasi)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        displayedAspirasi.assignAll(sorted);
        break;

      case TabAspirasi.terpopuler:
        final sorted = List<AspirasiModel>.from(_allAspirasi)
          ..sort((a, b) => b.upvoteCount.compareTo(a.upvoteCount));
        displayedAspirasi.assignAll(sorted);
        break;

      case TabAspirasi.diproses:
        final filtered =
            _allAspirasi
                .where(
                  (a) =>
                      a.status == StatusAspirasi.inReview ||
                      a.status == StatusAspirasi.responded,
                )
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        displayedAspirasi.assignAll(filtered);
        break;
    }
  }

  bool _validateForm() {
    if (isiSaranController.text.trim().length < minIsiSaranLength) {
      errorIsiSaran.value =
          'Aspirasi minimal $minIsiSaranLength karakter. '
          'Saat ini: ${isiSaranController.text.trim().length} karakter.';
      return false;
    }
    errorIsiSaran.value = '';
    return true;
  }

  void _resetForm() {
    isiSaranController.clear();
    isAnonymous.value = false;
    errorIsiSaran.value = '';
  }

  String _generateId() => 'asp-${DateTime.now().millisecondsSinceEpoch}';

  // --------------------------------------------------------
  // PUBLIC METHODS â€” NAVIGASI FORM/LIST
  // --------------------------------------------------------

  /// Buka form tambah aspirasi
  void onTambahAspirasi() {
    showForm.value = true;
  }

  bool get hasDraft => isiSaranController.text.isNotEmpty;

  /// Tutup form dan kembali ke list
  void onTutupFormConfirmed() {
    _resetForm();
    showForm.value = false;
  }

  // --------------------------------------------------------
  // PUBLIC METHODS â€” FORM
  // --------------------------------------------------------

  /// Toggle anonymous mode
  void onToggleAnonymous(bool value) {
    isAnonymous.value = value;
  }

  /// Hapus isi form
  bool canHapusForm() => isiSaranController.text.isNotEmpty;

  void onHapusFormConfirmed() {
    _resetForm();
  }

  /// Submit aspirasi baru
  Future<void> onPostAspirasi() async {
    if (!_validateForm()) return;

    isSubmitting.value = true;
    await Future.delayed(const Duration(milliseconds: 800));

    final newAspirasi = AspirasiModel(
      id: _generateId(),
      topik: _generateTopik(isiSaranController.text.trim()),
      isiSaran: isiSaranController.text.trim(),
      isAnonymous: isAnonymous.value,
      pelaporId: isAnonymous.value ? null : currentUserId,
      pelaporName: isAnonymous.value ? null : currentUserName,
      pelaporProdi: isAnonymous.value ? null : currentUserProdi,
      upvoteCount: 0,
      downvoteCount: 0,
      upvoterIds: const [],
      downvoterIds: const [],
      status: StatusAspirasi.open,
      kategori: KategoriAspirasi.umum,
      createdAt: DateTime.now(),
    );

    _allAspirasi.insert(0, newAspirasi);
    _applyFilter();
    _resetForm();
    showForm.value = false;
    isSubmitting.value = false;

    Get.snackbar(
      'Aspirasi Terkirim!',
      'Aspirasi Anda berhasil diposting dan dapat dilihat oleh sesama mahasiswa.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green.shade100,
      colorText: Colors.green.shade900,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
    );
  }

  /// Generate topik singkat dari isi saran (ambil 7 kata pertama)
  String _generateTopik(String isiSaran) {
    final words = isiSaran.split(' ');
    if (words.length <= 7) return isiSaran;
    return '${words.take(7).join(' ')}...';
  }

  // --------------------------------------------------------
  // PUBLIC METHODS â€” VOTING
  // --------------------------------------------------------

  /// Upvote aspirasi â€” toggle jika sudah upvote
  void onUpvote(String aspirasiId) {
    final idx = _allAspirasi.indexWhere((a) => a.id == aspirasiId);
    if (idx == -1) return;

    final current = _allAspirasi[idx];
    final alreadyUpvoted = current.upvoterIds.contains(currentUserId);
    final alreadyDownvoted = current.downvoterIds.contains(currentUserId);

    final updatedUpvoters = List<String>.from(current.upvoterIds);
    final updatedDownvoters = List<String>.from(current.downvoterIds);
    int newUpvote = current.upvoteCount;
    int newDownvote = current.downvoteCount;

    if (alreadyUpvoted) {
      // Cancel upvote
      updatedUpvoters.remove(currentUserId);
      newUpvote--;
    } else {
      // Tambah upvote
      updatedUpvoters.add(currentUserId);
      newUpvote++;
      // Hapus downvote jika ada
      if (alreadyDownvoted) {
        updatedDownvoters.remove(currentUserId);
        newDownvote--;
      }
    }

    _allAspirasi[idx] = current.copyWith(
      upvoteCount: newUpvote,
      downvoteCount: newDownvote,
      upvoterIds: updatedUpvoters,
      downvoterIds: updatedDownvoters,
    );
    _applyFilter();
  }

  /// Downvote aspirasi â€” toggle jika sudah downvote
  void onDownvote(String aspirasiId) {
    final idx = _allAspirasi.indexWhere((a) => a.id == aspirasiId);
    if (idx == -1) return;

    final current = _allAspirasi[idx];
    final alreadyDownvoted = current.downvoterIds.contains(currentUserId);
    final alreadyUpvoted = current.upvoterIds.contains(currentUserId);

    final updatedUpvoters = List<String>.from(current.upvoterIds);
    final updatedDownvoters = List<String>.from(current.downvoterIds);
    int newUpvote = current.upvoteCount;
    int newDownvote = current.downvoteCount;

    if (alreadyDownvoted) {
      updatedDownvoters.remove(currentUserId);
      newDownvote--;
    } else {
      updatedDownvoters.add(currentUserId);
      newDownvote++;
      if (alreadyUpvoted) {
        updatedUpvoters.remove(currentUserId);
        newUpvote--;
      }
    }

    _allAspirasi[idx] = current.copyWith(
      upvoteCount: newUpvote,
      downvoteCount: newDownvote,
      upvoterIds: updatedUpvoters,
      downvoterIds: updatedDownvoters,
    );
    _applyFilter();
  }

  // ---- GETTERS HELPER ----
  bool isUpvoted(AspirasiModel a) => a.upvoterIds.contains(currentUserId);
  bool isDownvoted(AspirasiModel a) => a.downvoterIds.contains(currentUserId);

  /// Refresh data (pull-to-refresh)
  Future<void> onRefresh() async => await _loadAspirasi();

  /// Counter karakter
  String get isiSaranCounter =>
      '${isiSaranController.text.length}/$maxIsiSaranLength';
}
