import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../controller/vision_controller.dart';

class VisionView extends StatefulWidget {
  final VisionController? controller;
  const VisionView({super.key, this.controller});

  @override
  State<VisionView> createState() => _VisionViewState();
}

class _VisionViewState extends State<VisionView>
    with SingleTickerProviderStateMixin {
  late VisionController _visionController;
  bool _ownsController = false;

  // Guard: mencegah double-tap saat proses foto berjalan
  bool _isCapturing = false;

  // Animation untuk shutter effect saat foto
  late AnimationController _shutterController;
  late Animation<double> _shutterAnimation;
  bool _showShutter = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _visionController = widget.controller!;
      _ownsController = false;
    } else {
      _visionController = VisionController();
      _visionController.startMockDetection();
      _ownsController = true;
    }

    // Shutter flash animation
    _shutterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shutterAnimation = CurvedAnimation(
      parent: _shutterController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    if (_ownsController) {
      _visionController.dispose();
    }
    _shutterController.dispose();
    super.dispose();
  }

  /// Ambil foto dengan shutter effect, lalu tampilkan pesan sukses.
  Future<void> _capturePhoto() async {
    if (_isCapturing) return;
    if (!_visionController.isInitialized) return;

    setState(() => _isCapturing = true);

    try {
      // Shutter effect
      setState(() => _showShutter = true);
      await _shutterController.forward(from: 0);
      if (mounted) setState(() => _showShutter = false);

      final image = await _visionController.takePhoto();

      if (image == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('Gagal mengambil foto. Coba lagi.'),
            ),
          );
        }
        return;
      }

      final file = File(image.path);

      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: Colors.red,
              content: Text('File foto tidak ditemukan.'),
            ),
          );
        }
        return;
      }

      if (!mounted) return;

      // ✅ INI YANG PALING PENTING
      Navigator.pop(context, image.path);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red[900],
            content: Text('Error: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0D1421),
        foregroundColor: Colors.white,
        title: const Text(
          "Smart-Patrol Vision",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          // Flashlight toggle
          IconButton(
            icon: Icon(
              _visionController.isFlashlightOn
                  ? Icons.flash_on
                  : Icons.flash_off,
              color: _visionController.isFlashlightOn
                  ? const Color(0xFF4CFFB3)
                  : Colors.white,
            ),
            onPressed: _visionController.toggleFlashlight,
            tooltip: 'Toggle Flashlight',
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: _visionController,
        builder: (context, child) {
          if (!_visionController.isInitialized) {
            return _buildLoadingState();
          }
          return _buildVisionStack();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildCaptureButton(),
    );
  }

  /// Tombol capture dengan efek visual yang lebih menonjol
  Widget _buildCaptureButton() {
    return ListenableBuilder(
      listenable: _visionController,
      builder: (context, _) {
        final canCapture = _visionController.isInitialized && !_isCapturing;
        return GestureDetector(
          onTap: canCapture ? _capturePhoto : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: canCapture ? Colors.white : Colors.white30,
              border: Border.all(
                color: canCapture
                    ? const Color(0xFF4CFFB3)
                    : Colors.transparent,
                width: 3,
              ),
              boxShadow: canCapture
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4CFFB3).withOpacity(0.4),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: _isCapturing
                ? const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Color(0xFF4CFFB3),
                    ),
                  )
                : Icon(
                    Icons.camera_alt,
                    color: canCapture ? Colors.black87 : Colors.black26,
                    size: 32,
                  ),
          ),
        );
      },
    );
  }

  /// Build loading state dengan pesan informatif
  Widget _buildLoadingState() {
    return Container(
      color: const Color(0xFF0A0F1A),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Color(0xFF4CFFB3)),
            const SizedBox(height: 16),
            const Text(
              "Menghubungkan ke Sensor Visual...",
              style: TextStyle(fontSize: 16, color: Colors.white70),
            ),
            if (_visionController.errorMessage != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _visionController.errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => openAppSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CFFB3),
                  foregroundColor: Colors.black,
                ),
                child: const Text("Open Settings"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build layered stack: kamera + overlay + shutter flash
  Widget _buildVisionStack() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cameraRatio = _visionController.controller!.value.aspectRatio;

        // Di portrait mode, kamera mengembalikan aspectRatio landscape (misal 1.33).
        // Balik rasio agar preview tidak cembung/stretch.
        final isPortrait = constraints.maxHeight > constraints.maxWidth;
        final displayRatio = isPortrait ? (1 / cameraRatio) : cameraRatio;

        return Stack(
          fit: StackFit.expand,
          children: [
            // LAYER 1: Hardware Camera Preview
            ClipRect(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxWidth / displayRatio,
                  child: CameraPreview(_visionController.controller!),
                ),
              ),
            ),

            // LAYER 2: Shutter Flash Effect
            if (_showShutter)
              Positioned.fill(
                child: FadeTransition(
                  opacity: Tween<double>(
                    begin: 1,
                    end: 0,
                  ).animate(_shutterAnimation),
                  child: Container(color: Colors.white),
                ),
              ),

            // LAYER 4: Hint text di bagian bawah
            Positioned(
              bottom: 100,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black45,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Ambil foto langsung tanpa filter',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
