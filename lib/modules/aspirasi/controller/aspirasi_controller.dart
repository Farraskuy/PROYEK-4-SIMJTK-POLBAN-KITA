import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/user/model/user_model.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/log_service.dart';
import '../model/aspirasi_model.dart';
import '../service/aspirasi_service.dart';

class AspirasiController extends GetxController
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

  /// Data user yang sedang login
  UserModel? get user => AuthService().currentUser;

  final RxString currentUserId = ''.obs;
  final RxString currentUserName = 'Mahasiswa'.obs;
  final RxString currentUserProdi = '-'.obs;

  final AspirasiService _service = AspirasiService();

  // --------------------------------------------------------
  // STATE OBSERVABLES â€” FORM
  // --------------------------------------------------------

  /// Controller teks area aspirasi
  final judulController = TextEditingController();
  final isiSaranController = TextEditingController();
  final adminSearchController = TextEditingController();
  final RxString adminSearchQuery = ''.obs;

  /// Status submitting form
  final RxBool isSubmitting = false.obs;

  /// Error teks deskripsi
  final RxString errorJudul = ''.obs;
  final RxString errorIsiSaran = ''.obs;

  /// Aspirasi yang sedang diedit
  final Rxn<AspirasiModel> _editingAspirasi = Rxn<AspirasiModel>();

  AspirasiModel? get editingAspirasi => _editingAspirasi.value;

  /// Mode â€” true: tampilkan form, false: tampilkan list
  final RxBool showForm = false.obs;

  // --------------------------------------------------------
  // CONSTANTS
  // --------------------------------------------------------
  static const int minIsiSaranLength = 20;
  static const int maxIsiSaranLength = 1000;
  static const int minJudulLength = 5;
  static const int maxJudulLength = 80;

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

    judulController.addListener(() {
      if (judulController.text.isNotEmpty) errorJudul.value = '';
    });
    isiSaranController.addListener(() {
      if (isiSaranController.text.isNotEmpty) errorIsiSaran.value = '';
    });
    adminSearchController.addListener(() {
      adminSearchQuery.value = adminSearchController.text;
      _applyFilter();
    });
  }

  Future<void> _initCurrentUser() async {
    final user = await AuthService().loadSavedSession();
    if (user != null) {
      // Simpan ID user untuk kebutuhan cek validasi vote
      currentUserId.value = user.id.isNotEmpty
          ? user.id
          : (user.nomorInduk.isNotEmpty ? user.nomorInduk : 'anonymous');
      currentUserName.value = user.name.isNotEmpty ? user.name : 'Mahasiswa';
      currentUserProdi.value = user.programStudy.isNotEmpty
          ? user.programStudy
          : '-';
    }
  }

  @override
  void onClose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    judulController.dispose();
    isiSaranController.dispose();
    adminSearchController.dispose();
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
        activeTab.value = TabAspirasi.selesai;
        break;
    }
    _applyFilter();
  }

  void _applyFilter() {
    List<AspirasiModel> result;
    switch (activeTab.value) {
      case TabAspirasi.terbaru:
        result = List<AspirasiModel>.from(_allAspirasi)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case TabAspirasi.terpopuler:
        result = List<AspirasiModel>.from(_allAspirasi)
          ..sort((a, b) => b.upvoteCount.compareTo(a.upvoteCount));
        break;

      case TabAspirasi.selesai:
        result =
            _allAspirasi
                .where(
                  (a) =>
                      a.status == StatusAspirasi.responded ||
                      a.status == StatusAspirasi.inReview,
                )
                .toList()
              ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    final query = adminSearchQuery.value.trim().toLowerCase();
    if (query.isNotEmpty) {
      result = result.where((aspirasi) {
        return aspirasi.topik.toLowerCase().contains(query) ||
            aspirasi.isiSaran.toLowerCase().contains(query) ||
            (aspirasi.pelaporName ?? '').toLowerCase().contains(query);
      }).toList();
    }
    displayedAspirasi.assignAll(result);
  }

  void clearAdminSearch() => adminSearchController.clear();

  bool _validateForm() {
    if (judulController.text.trim().length < minJudulLength) {
      errorJudul.value =
          'Judul minimal $minJudulLength karakter. '
          'Saat ini: ${judulController.text.trim().length} karakter.';
      return false;
    }
    errorJudul.value = '';
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
    judulController.clear();
    isiSaranController.clear();
    errorJudul.value = '';
    errorIsiSaran.value = '';
  }

  String _generateId() => 'asp-${DateTime.now().millisecondsSinceEpoch}';

  // --------------------------------------------------------
  // PUBLIC METHODS â€” NAVIGASI FORM/LIST
  // --------------------------------------------------------

  /// Buka form tambah aspirasi
  void onTambahAspirasi() {
    prepareCreateForm();
    showForm.value = true;
  }

  void prepareCreateForm() {
    _editingAspirasi.value = null;
    _resetForm();
  }

  void prepareEditForm(AspirasiModel aspirasi) {
    _editingAspirasi.value = aspirasi;
    judulController.text = aspirasi.topik;
    isiSaranController.text = aspirasi.isiSaran;
    errorJudul.value = '';
    errorIsiSaran.value = '';
  }

  bool get hasDraft =>
      judulController.text.isNotEmpty || isiSaranController.text.isNotEmpty;

  /// Tutup form dan kembali ke list
  void onTutupFormConfirmed() {
    _resetForm();
    showForm.value = false;
    _editingAspirasi.value = null;
  }

  // --------------------------------------------------------
  // PUBLIC METHODS â€” FORM
  // --------------------------------------------------------

  /// Hapus isi form
  bool canHapusForm() =>
      judulController.text.isNotEmpty || isiSaranController.text.isNotEmpty;

  void onHapusFormConfirmed() {
    _resetForm();
  }

  /// Submit aspirasi baru
  Future<void> onPostAspirasi() async {
    await submitAspirasi();
  }

  Future<void> submitAspirasi() async {
    if (!_validateForm()) return;

    isSubmitting.value = true;

    try {
      // Ambil data user dari Session yang tersimpan
      final currentUser = await AuthService().loadSavedSession();
      final pelaporId =
          currentUser?.id ?? currentUser?.nomorInduk ?? 'anonymous';
      final pelaporName = currentUser?.name ?? 'Mahasiswa Anonim';
      final pelaporProdi = currentUser?.programStudy ?? '-';

      final current = _editingAspirasi.value;
      if (current == null) {
        final newAspirasi = AspirasiModel(
          id: _generateId(),
          topik: judulController.text.trim(),
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

        await _service.createAspirasi(newAspirasi);
        _allAspirasi.insert(0, newAspirasi);
      } else {
        final idx = _allAspirasi.indexWhere((item) => item.id == current.id);
        if (idx != -1) {
          final updatedAspirasi = current.copyWith(
            topik: judulController.text.trim(),
            isiSaran: isiSaranController.text.trim(),
          );
          await _service.updateAspirasi(updatedAspirasi);
          _allAspirasi[idx] = updatedAspirasi;
        }
      }

      Get.snackbar(
        current == null ? 'Aspirasi Terkirim!' : 'Aspirasi Diperbarui!',
        current == null
            ? 'Aspirasi Anda berhasil diposting dan dapat dilihat oleh sesama mahasiswa.'
            : 'Perubahan aspirasi berhasil disimpan.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 3),
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      LogService.writeLog(
        "Gagal submit aspirasi: $e",
        source: "AspirasiController",
        level: 1, // ERROR
      );
    }

    _applyFilter();
    _resetForm();
    _editingAspirasi.value = null;
    showForm.value = false;
    isSubmitting.value = false;
  }

  Future<void> deleteAspirasi(String aspirasiId) async {
    try {
      await _service.deleteAspirasi(aspirasiId);
      _allAspirasi.removeWhere((item) => item.id == aspirasiId);
      _applyFilter();
      if (_editingAspirasi.value?.id == aspirasiId) {
        _editingAspirasi.value = null;
        _resetForm();
      }
      Get.snackbar('Sukses', 'Aspirasi berhasil dihapus');
    } catch (e) {
      Get.snackbar('Gagal', 'Gagal menghapus aspirasi: $e');
    }
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
      final dispIdx = displayedAspirasi.indexWhere((a) => a.id == aspirasiId);
      if (dispIdx != -1) {
        displayedAspirasi[dispIdx] = updatedAspirasi;
      }
      displayedAspirasi.refresh();
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
      final dispIdx = displayedAspirasi.indexWhere((a) => a.id == aspirasiId);
      if (dispIdx != -1) {
        displayedAspirasi[dispIdx] = updatedAspirasi;
      }
      displayedAspirasi.refresh();
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
  Future<void> submitTanggapan(String aspirasiId, String tanggapan) async {
    final idx = _allAspirasi.indexWhere((a) => a.id == aspirasiId);
    if (idx == -1) return;

    final current = _allAspirasi[idx];
    final updatedAspirasi = current.copyWith(
      tanggapanJurusan: tanggapan,
      status: StatusAspirasi.responded,
    );

    try {
      await _service.updateAspirasi(updatedAspirasi);
      _allAspirasi[idx] = updatedAspirasi;
      _applyFilter();
      Get.snackbar(
        'Sukses',
        'Tanggapan berhasil disimpan.',
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
      );
    } catch (e) {
      Get.snackbar(
        'Gagal',
        'Gagal menyimpan tanggapan: $e',
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    }
  }

  bool isUpvoted(AspirasiModel a) => a.upvoterIds.contains(currentUserId.value);
  bool isDownvoted(AspirasiModel a) =>
      a.downvoterIds.contains(currentUserId.value);

  /// Refresh data (pull-to-refresh)
  Future<void> onRefresh() async => await _loadAspirasi();

  /// Counter karakter
  String get judulCounter => '${judulController.text.length}/$maxJudulLength';

  String get isiSaranCounter =>
      '${isiSaranController.text.length}/$maxIsiSaranLength';
}
