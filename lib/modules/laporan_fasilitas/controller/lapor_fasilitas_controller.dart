import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/lapor_fasilitas_model.dart';

class LaporFasilitasController extends GetxController {
  // --------------------------------------------------------
  // FORM KEY & TEXT CONTROLLERS
  // --------------------------------------------------------
  final formKey = GlobalKey<FormState>();
  final lokasiController = TextEditingController();
  final nomorMejaController = TextEditingController();
  final deskripsiController = TextEditingController();

  // --------------------------------------------------------
  // STATE OBSERVABLES
  // --------------------------------------------------------

  /// List kategori yang tersedia (dari server/local cache)
  final RxList<KategoriFasilitasModel> kategoriList =
      <KategoriFasilitasModel>[].obs;

  /// Kategori yang sedang dipilih user
  final Rx<KategoriFasilitasModel?> selectedKategori =
      Rx<KategoriFasilitasModel?>(null);

  /// List path foto yang sudah dipilih (maks. 3 foto)
  final RxList<String> selectedFotoPaths = <String>[].obs;

  /// Status loading saat submit
  final RxBool isSubmitting = false.obs;

  /// Status loading data kategori
  final RxBool isLoadingKategori = false.obs;

  /// Apakah form dalam mode edit (ada laporan existing)
  final RxBool isEditMode = false.obs;

  /// Laporan yang sedang di-edit (null jika mode tambah)
  final Rx<LaporanFasilitasModel?> existingLaporan = Rx<LaporanFasilitasModel?>(
    null,
  );

  /// Pesan error per field
  final RxString errorKategori = ''.obs;
  final RxString errorLokasi = ''.obs;
  final RxString errorDeskripsi = ''.obs;

  // --------------------------------------------------------
  // CONSTANTS
  // --------------------------------------------------------
  static const int maxFoto = 3;
  static const int maxDeskripsiLength = 500;

  // --------------------------------------------------------
  // LIFECYCLE
  // --------------------------------------------------------

  @override
  void onInit() {
    super.onInit();
    _loadKategori();

    // Cek apakah ada argument edit mode dari navigasi
    final args = Get.arguments;
    if (args != null && args is LaporanFasilitasModel) {
      _populateEditMode(args);
    }

    // Listener realtime untuk clear error saat user mulai mengetik
    lokasiController.addListener(() {
      if (lokasiController.text.isNotEmpty) errorLokasi.value = '';
    });
    deskripsiController.addListener(() {
      if (deskripsiController.text.isNotEmpty) errorDeskripsi.value = '';
    });
  }

  @override
  void onClose() {
    lokasiController.dispose();
    nomorMejaController.dispose();
    deskripsiController.dispose();
    super.onClose();
  }

  // --------------------------------------------------------
  // PRIVATE METHODS
  // --------------------------------------------------------

  Future<void> _loadKategori() async {
    isLoadingKategori.value = true;
    // Simulasi network delay — ganti dengan service call nyata
    await Future.delayed(const Duration(milliseconds: 400));
    kategoriList.assignAll(KategoriFasilitasModel.dummyList());
    isLoadingKategori.value = false;
  }

  void _populateEditMode(LaporanFasilitasModel laporan) {
    isEditMode.value = true;
    existingLaporan.value = laporan;

    // Isi field dengan data yang sudah ada
    lokasiController.text = laporan.lokasiLabKelas;
    nomorMejaController.text = laporan.nomorMejaPc ?? '';
    deskripsiController.text = laporan.deskripsi;
    selectedFotoPaths.assignAll(laporan.fotoUrls);

    // Set kategori yang sudah dipilih
    final kat = kategoriList.firstWhereOrNull(
      (k) => k.id == laporan.kategoriId,
    );
    if (kat != null) selectedKategori.value = kat;
  }

  bool _validateForm() {
    bool valid = true;

    if (selectedKategori.value == null) {
      errorKategori.value = 'Kategori laporan wajib dipilih';
      valid = false;
    } else {
      errorKategori.value = '';
    }

    if (lokasiController.text.trim().isEmpty) {
      errorLokasi.value = 'Lokasi / ruangan wajib diisi';
      valid = false;
    } else {
      errorLokasi.value = '';
    }

    if (deskripsiController.text.trim().isEmpty) {
      errorDeskripsi.value = 'Deskripsi masalah wajib diisi';
      valid = false;
    } else if (deskripsiController.text.trim().length < 10) {
      errorDeskripsi.value = 'Deskripsi minimal 10 karakter';
      valid = false;
    } else {
      errorDeskripsi.value = '';
    }

    return valid;
  }

  String _generateId() {
    // Contoh UUID sederhana — gunakan package uuid di implementasi nyata
    return 'lap-${DateTime.now().millisecondsSinceEpoch}';
  }

  // --------------------------------------------------------
  // PUBLIC METHODS — INTERAKSI FORM
  // --------------------------------------------------------

  /// Dipanggil saat user memilih kategori dari dropdown
  void onKategoriSelected(KategoriFasilitasModel? kategori) {
    selectedKategori.value = kategori;
    if (kategori != null) errorKategori.value = '';
  }

  /// Dipanggil saat user menekan area unggah foto
  Future<void> onPickFoto() async {
    if (selectedFotoPaths.length >= maxFoto) {
      Get.snackbar(
        'Batas Foto',
        'Maksimal $maxFoto foto yang dapat diunggah',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange.shade100,
        colorText: Colors.orange.shade900,
        margin: const EdgeInsets.all(16),
      );
      return;
    }

    // TODO: Implementasi image_picker nyata
    // final picker = ImagePicker();
    // final XFile? file = await picker.pickImage(source: ImageSource.gallery);
    // if (file != null) selectedFotoPaths.add(file.path);

    // Simulasi untuk prototype
    selectedFotoPaths.add('foto_simulasi_${selectedFotoPaths.length + 1}.jpg');
    Get.snackbar(
      'Foto Ditambahkan',
      'Foto ${selectedFotoPaths.length} berhasil ditambahkan',
      snackPosition: SnackPosition.BOTTOM,
      margin: const EdgeInsets.all(16),
    );
  }

  /// Dipanggil saat user mengambil foto lewat kamera
  Future<void> onTakeFoto() async {
    if (selectedFotoPaths.length >= maxFoto) {
      Get.snackbar(
        'Batas Foto',
        'Maksimal $maxFoto foto yang dapat diunggah',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // TODO: Implementasi image_picker camera
    // final picker = ImagePicker();
    // final XFile? file = await picker.pickImage(source: ImageSource.camera);
    // if (file != null) selectedFotoPaths.add(file.path);

    selectedFotoPaths.add('foto_kamera_${selectedFotoPaths.length + 1}.jpg');
  }

  /// Hapus foto dari list berdasarkan index
  void onRemoveFoto(int index) {
    if (index >= 0 && index < selectedFotoPaths.length) {
      selectedFotoPaths.removeAt(index);
    }
  }

  /// Dipanggil saat user menekan tombol "Kirim Laporan"
  Future<void> onSubmitLaporan() async {
    if (!_validateForm()) return;

    isSubmitting.value = true;

    try {
      // Simulasi cek koneksi internet
      final isOnline = await _checkConnectivity();

      final now = DateTime.now();
      final laporan = LaporanFasilitasModel(
        id: existingLaporan.value?.id ?? _generateId(),
        judul:
            '${selectedKategori.value!.namaKategori} - ${lokasiController.text.trim()}',
        deskripsi: deskripsiController.text.trim(),
        kategoriId: selectedKategori.value!.id,
        lokasiLabKelas: lokasiController.text.trim(),
        nomorMejaPc: nomorMejaController.text.trim().isEmpty
            ? null
            : nomorMejaController.text.trim(),
        fotoUrls: List.from(selectedFotoPaths),
        status: StatusLaporan.pending,
        pelaporId: 'usr-001', // TODO: ambil dari AuthController
        syncStatus: isOnline ? SyncStatus.synced : SyncStatus.local,
        createdAt: existingLaporan.value?.createdAt ?? now,
        updatedAt: now,
      );

      // Simulasi delay pengiriman
      await Future.delayed(const Duration(seconds: 1));

      if (isOnline) {
        _onSubmitSuccess(laporan, isOffline: false);
      } else {
        // Offline-first: simpan ke SyncQueue lokal
        _onSubmitSuccess(laporan, isOffline: true);
      }
    } catch (e) {
      _onSubmitFailed(e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }

  /// Simulasi pengecekan koneksi — ganti dengan connectivity_plus di implementasi nyata
  Future<bool> _checkConnectivity() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true; // Asumsikan online untuk prototype
  }

  void _onSubmitSuccess(
    LaporanFasilitasModel laporan, {
    required bool isOffline,
  }) {
    final message = isOffline
        ? 'Laporan disimpan secara offline. Akan dikirim otomatis saat ada koneksi.'
        : isEditMode.value
        ? 'Laporan berhasil diperbarui!'
        : 'Laporan berhasil dikirim! Kami akan segera menindaklanjuti.';

    Get.back(result: laporan); // Kirim data balik ke halaman sebelumnya

    Get.snackbar(
      isOffline ? 'Tersimpan Offline' : 'Berhasil!',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isOffline
          ? Colors.orange.shade100
          : Colors.green.shade100,
      colorText: isOffline ? Colors.orange.shade900 : Colors.green.shade900,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(16),
    );
  }

  void _onSubmitFailed(String error) {
    Get.snackbar(
      'Gagal Mengirim',
      'Terjadi kesalahan: $error',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade900,
      margin: const EdgeInsets.all(16),
    );
  }

  /// Dipanggil saat user menekan "Batal & Kembali"
  void onBatalKembali() {
    if (_hasUnsavedChanges()) {
      Get.dialog(
        AlertDialog(
          title: const Text('Batalkan Laporan?'),
          content: const Text(
            'Data yang sudah Anda isi akan hilang. Yakin ingin kembali?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(), // Tutup dialog
              child: const Text('Tidak'),
            ),
            TextButton(
              onPressed: () {
                Get.back(); // Tutup dialog
                Get.back(); // Kembali ke halaman sebelumnya
              },
              child: const Text(
                'Ya, Batalkan',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      );
    } else {
      Get.back();
    }
  }

  /// Cek apakah ada perubahan yang belum disimpan
  bool _hasUnsavedChanges() {
    return selectedKategori.value != null ||
        lokasiController.text.isNotEmpty ||
        nomorMejaController.text.isNotEmpty ||
        deskripsiController.text.isNotEmpty ||
        selectedFotoPaths.isNotEmpty;
  }

  // --------------------------------------------------------
  // GETTERS REAKTIF
  // --------------------------------------------------------

  /// Teks jumlah karakter deskripsi
  String get deskripsiCounterText =>
      '${deskripsiController.text.length}/$maxDeskripsiLength';

  /// Apakah tombol submit bisa diklik
  bool get canSubmit => !isSubmitting.value;

  /// Label tombol submit berdasarkan mode
  String get submitButtonLabel =>
      isEditMode.value ? 'Perbarui Laporan' : 'Kirim Laporan';

  /// Judul halaman berdasarkan mode
  String get pageTitle => isEditMode.value
      ? 'Edit Laporan Fasilitas'
      : 'Tambah/Edit Laporan\nFasilitas';
}
