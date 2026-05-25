// ============================================================
// FILE: modules/aspirasi/controller/aspirasi_controller.dart
// Kelompok A7 â€“ SIMJTK (Sistem Informasi Mahasiswa JTK)
// ============================================================
//
// Dependency: get: ^4.6.6
// ============================================================

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import '../model/aspirasi_model.dart';
import '../service/aspirasi_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';

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

  final RxString currentUserId = ''.obs;
  final RxString currentUserName = 'Mahasiswa'.obs;
  final RxString currentUserProdi = '-'.obs;


  final AspirasiService _service = AspirasiService();

  // --------------------------------------------------------
  // STATE OBSERVABLES â€” FORM
  // --------------------------------------------------------

  /// Controller teks area aspirasi
  final isiSaranController = TextEditingController();

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
    _initCurrentUser();
    _loadAspirasi();

    isiSaranController.addListener(() {
      if (isiSaranController.text.isNotEmpty) errorIsiSaran.value = '';
    });
  }

  Future<void> _initCurrentUser() async {
      final user = await AuthService().loadSavedSession();
      if (user != null) {
        // Simpan ID user untuk kebutuhan cek validasi vote
        currentUserId.value = user.id ?? user.nomorInduk ?? 'anonymous';
        currentUserName.value = user.name ?? 'Mahasiswa';
        currentUserProdi.value = user.programStudy ?? '-';
      }
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
      try {
        final data = await _service.fetchAllAspirasi();
        _allAspirasi.assignAll(data);
        _applyFilter();
      } catch (e) {
        Get.snackbar('Error', 'Gagal mengambil data aspirasi dari server.');
        debugPrint('Error fetch aspirasi: $e');
      } finally {
        isLoading.value = false;
      }
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

  /// Hapus isi form
  bool canHapusForm() => isiSaranController.text.isNotEmpty;

  void onHapusFormConfirmed() {
    _resetForm();
  }

  /// Submit aspirasi baru
  Future<void> onPostAspirasi() async {
      if (!_validateForm()) return;

      isSubmitting.value = true;

      try {
        // Ambil data user dari Session yang tersimpan
        final currentUser = await AuthService().loadSavedSession();
        final pelaporId = currentUser?.id ?? currentUser?.nomorInduk ?? 'anonymous';
        final pelaporName = currentUser?.name ?? 'Mahasiswa Anonim';
        final pelaporProdi = currentUser?.programStudy ?? '-';

        final newAspirasi = AspirasiModel(
          id: _generateId(),
          topik: _generateTopik(isiSaranController.text.trim()),
          isiSaran: isiSaranController.text.trim(),
          pelaporId: pelaporId,
          pelaporName: pelaporName,
          pelaporProdi: pelaporProdi,
          upvoteCount: 0,
          downvoteCount: 0,
          upvoterIds: const [],
          downvoterIds: const [],
          status: StatusAspirasi.open,
          kategori: KategoriAspirasi.umum,
          createdAt: DateTime.now(),
        );

        // Simpan ke Database
        await _service.createAspirasi(newAspirasi);

        // Perbarui UI jika berhasil
        _allAspirasi.insert(0, newAspirasi);
        _applyFilter();
        _resetForm();
        showForm.value = false;

        Get.snackbar(
          'Aspirasi Terkirim!',
          'Aspirasi Anda berhasil diposting.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
          duration: const Duration(seconds: 3),
          margin: const EdgeInsets.all(16),
        );
      } catch (e) {
        Get.snackbar(
          'Gagal',
          'Terjadi kesalahan saat mengirim aspirasi: $e',
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      } finally {
        isSubmitting.value = false;
      }
    }

  /// Generate topik singkat dari isi saran (ambil 7 kata pertama)
  String _generateTopik(String isiSaran) {
    final words = isiSaran.split(' ');
    if (words.length <= 7) return isiSaran;
    return '${words.take(7).join(' ')}...';
  }

  // --------------------------------------------------------
  // SISTEM VOTE (UPVOTE & DOWNVOTE)
  // --------------------------------------------------------
  
  Future<void> onUpvote(String aspirasiId) async {
    final idx = _allAspirasi.indexWhere((a) => a.id == aspirasiId);
    if (idx == -1) return;

    // Ambil user ID yang sedang aktif
    final currentUser = await AuthService().loadSavedSession();
    final userId = currentUser?.id ?? currentUser?.nomorInduk ?? 'anonymous';

    final current = _allAspirasi[idx];
    final alreadyUpvoted = current.upvoterIds.contains(userId);
    final alreadyDownvoted = current.downvoterIds.contains(userId);

    final updatedUpvoters = List<String>.from(current.upvoterIds);
    final updatedDownvoters = List<String>.from(current.downvoterIds);
    int newUpvote = current.upvoteCount;
    int newDownvote = current.downvoteCount;

    // Logika perhitungan vote
    if (alreadyUpvoted) {
      updatedUpvoters.remove(userId);
      newUpvote--;
    } else {
      updatedUpvoters.add(userId);
      newUpvote++;
      if (alreadyDownvoted) {
        updatedDownvoters.remove(userId);
        newDownvote--;
      }
    }

    // Buat objek AspirasiModel baru yang sudah di-update
    final updatedAspirasi = current.copyWith(
      upvoteCount: newUpvote,
      downvoteCount: newDownvote,
      upvoterIds: updatedUpvoters,
      downvoterIds: updatedDownvoters,
    );

    try {
      // 1. Simpan perubahan ke MongoDB
      await _service.updateAspirasi(updatedAspirasi);

      // 2. Jika berhasil, perbarui state lokal UI
      _allAspirasi[idx] = updatedAspirasi;
      _applyFilter();
    } catch (e) {
      Get.snackbar(
        'Gagal', 
        'Gagal memperbarui vote: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  Future<void> onDownvote(String aspirasiId) async {
    final idx = _allAspirasi.indexWhere((a) => a.id == aspirasiId);
    if (idx == -1) return;

    // Ambil user ID yang sedang aktif
    final currentUser = await AuthService().loadSavedSession();
    final userId = currentUser?.id ?? currentUser?.nomorInduk ?? 'anonymous';

    final current = _allAspirasi[idx];
    final alreadyDownvoted = current.downvoterIds.contains(userId);
    final alreadyUpvoted = current.upvoterIds.contains(userId);

    final updatedUpvoters = List<String>.from(current.upvoterIds);
    final updatedDownvoters = List<String>.from(current.downvoterIds);
    int newUpvote = current.upvoteCount;
    int newDownvote = current.downvoteCount;

    // Logika perhitungan vote
    if (alreadyDownvoted) {
      updatedDownvoters.remove(userId);
      newDownvote--;
    } else {
      updatedDownvoters.add(userId);
      newDownvote++;
      if (alreadyUpvoted) {
        updatedUpvoters.remove(userId);
        newUpvote--;
      }
    }

    // Buat objek AspirasiModel baru yang sudah di-update
    final updatedAspirasi = current.copyWith(
      upvoteCount: newUpvote,
      downvoteCount: newDownvote,
      upvoterIds: updatedUpvoters,
      downvoterIds: updatedDownvoters,
    );

    try {
      // 1. Simpan perubahan ke MongoDB
      await _service.updateAspirasi(updatedAspirasi);

      // 2. Jika berhasil, perbarui state lokal UI
      _allAspirasi[idx] = updatedAspirasi;
      _applyFilter();
    } catch (e) {
      Get.snackbar(
        'Gagal', 
        'Gagal memperbarui vote: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  // ---- GETTERS HELPER ----
  bool isUpvoted(AspirasiModel a) => a.upvoterIds.contains(currentUserId);
  bool isDownvoted(AspirasiModel a) => a.downvoterIds.contains(currentUserId);

  /// Refresh data (pull-to-refresh)
  Future<void> onRefresh() async => await _loadAspirasi();

  /// Counter karakter
  String get isiSaranCounter => '${isiSaranController.text.length}/$maxIsiSaranLength';
}
