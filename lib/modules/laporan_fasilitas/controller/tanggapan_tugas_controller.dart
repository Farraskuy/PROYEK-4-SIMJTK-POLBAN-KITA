import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:proyek_4_poki_polban_kita/modules/home/teknisi/model/analisa_kerusakan_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/model/laporan_fasilitas_model.dart';
import 'package:proyek_4_poki_polban_kita/modules/laporan_fasilitas/service/tanggapan_tugas_service.dart';
import 'package:proyek_4_poki_polban_kita/shared/services/auth_service.dart';

class TanggapanTugasController extends GetxController {
  TanggapanTugasController(this.laporan);

  final LaporanFasilitasModel laporan;
  final TanggapanTugasService _service = TanggapanTugasService();

  final kodeAlatController = TextEditingController();
  final noInventarisController = TextEditingController();
  final tanggapanController = TextEditingController();
  final perbaikanController = TextEditingController();
  final fotoPaths = <String>[].obs;
  final tingkatKerusakan = TingkatKerusakan.sedang.obs;
  final isLoading = true.obs;
  final isSaving = false.obs;
  final syncLabel = 'Tersimpan lokal'.obs;

  Timer? _syncTimer;
  bool _hydrating = true;
  String _teknisiId = 'petugas';
  String _teknisiUserId = '';
  String _teknisiName = 'Petugas';

  @override
  void onInit() {
    super.onInit();
    _loadDraft();
    for (final controller in [
      kodeAlatController,
      noInventarisController,
      tanggapanController,
      perbaikanController,
    ]) {
      controller.addListener(_scheduleAutosave);
    }
    ever<TingkatKerusakan>(tingkatKerusakan, (_) => _scheduleAutosave());
  }

  Future<void> _loadDraft() async {
    final user =
        AuthService().currentUser ?? await AuthService().loadSavedSession();
    _teknisiId = user?.nomorInduk.isNotEmpty == true
        ? user!.nomorInduk
        : user?.id ?? 'petugas';
    _teknisiUserId = user?.id ?? '';
    _teknisiName = user?.name ?? 'Petugas';

    final draft = await _service.getDraft(laporan.id);
    if (draft != null) {
      kodeAlatController.text = draft['kode_alat']?.toString() ?? '';
      noInventarisController.text =
          draft['no_inventaris']?.toString() ?? '';
      tanggapanController.text =
          draft['analisa_masalah']?.toString() ?? '';
      perbaikanController.text =
          draft['rekomendasi_perbaikan']?.toString() ?? '';
      fotoPaths.assignAll(
        (draft['foto_analisa_urls'] as List?)
                ?.map((item) => item.toString())
                .toList() ??
            const <String>[],
      );
      tingkatKerusakan.value = TingkatKerusakan.values.firstWhere(
        (item) => item.value == draft['tingkat_kerusakan'],
        orElse: () => TingkatKerusakan.sedang,
      );
      syncLabel.value = draft['pending_sync'] == true
          ? 'Menunggu sinkronisasi'
          : 'Tersinkron';
    }
    _hydrating = false;
    isLoading.value = false;
    if (draft?['pending_sync'] == true) {
      unawaited(
        _syncDraft(
          draft!,
          completed: draft['form_status'] == 'selesai',
        ),
      );
    }
  }

  Map<String, dynamic> _data({required bool completed}) {
    return {
      'teknisi_id': _teknisiId,
      'teknisi_user_id': _teknisiUserId,
      'teknisi_username': _teknisiId,
      'teknisi_name': _teknisiName,
      'judul_laporan': laporan.judul,
      'lokasi': laporan.lokasi,
      'kode_alat': kodeAlatController.text.trim(),
      'no_inventaris': noInventarisController.text.trim(),
      'analisa_masalah': tanggapanController.text.trim(),
      'rekomendasi_perbaikan': perbaikanController.text.trim(),
      'tingkat_kerusakan': tingkatKerusakan.value.value,
      'foto_analisa_urls': fotoPaths.toList(),
      'form_status': completed ? 'selesai' : 'draft',
    };
  }

  void addPhoto(String path) {
    if (path.isEmpty || fotoPaths.contains(path)) return;
    fotoPaths.add(path);
    _scheduleAutosave();
  }

  void removePhoto(String path) {
    fotoPaths.remove(path);
    _scheduleAutosave();
  }

  void _scheduleAutosave() {
    if (_hydrating) return;
    _syncTimer?.cancel();
    _syncTimer = Timer(const Duration(milliseconds: 700), () {
      unawaited(_saveAndSync(completed: false, showMessage: false));
    });
  }

  Future<void> _syncDraft(
    Map<String, dynamic> data, {
    required bool completed,
  }) async {
    try {
      await _service.sync(
        laporan.id,
        data,
        status:
            completed ? StatusLaporan.resolved : StatusLaporan.in_progress,
      );
      syncLabel.value = 'Tersinkron';
    } catch (_) {
      syncLabel.value = 'Menunggu sinkronisasi';
    }
  }

  Future<bool> saveDraft() =>
      _saveAndSync(completed: false, showMessage: true);

  Future<bool> complete() async {
    if (tanggapanController.text.trim().isEmpty ||
        perbaikanController.text.trim().isEmpty) {
      Get.snackbar(
        'Form belum lengkap',
        'Tanggapan tugas dan tindakan perbaikan wajib diisi.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }
    return _saveAndSync(completed: true, showMessage: true);
  }

  Future<bool> _saveAndSync({
    required bool completed,
    required bool showMessage,
  }) async {
    if (isSaving.value) return false;
    _syncTimer?.cancel();
    isSaving.value = true;
    final data = _data(completed: completed);
    await _service.saveLocal(laporan.id, data, pendingSync: true);
    syncLabel.value = 'Menyinkronkan...';

    try {
      await _service.sync(
        laporan.id,
        data,
        status:
            completed ? StatusLaporan.resolved : StatusLaporan.in_progress,
      );
      syncLabel.value = 'Tersinkron';
      if (showMessage) {
        Get.snackbar(
          completed ? 'Tugas selesai' : 'Draft tersimpan',
          completed
              ? 'Laporan telah ditandai selesai.'
              : 'Draft tersimpan di perangkat dan MongoDB.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return true;
    } catch (_) {
      syncLabel.value = 'Menunggu sinkronisasi';
      if (showMessage) {
        Get.snackbar(
          'Tersimpan lokal',
          'Koneksi MongoDB belum tersedia. Draft akan disinkronkan kembali.',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
      return true;
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    _syncTimer?.cancel();
    kodeAlatController.dispose();
    noInventarisController.dispose();
    tanggapanController.dispose();
    perbaikanController.dispose();
    super.onClose();
  }
}
