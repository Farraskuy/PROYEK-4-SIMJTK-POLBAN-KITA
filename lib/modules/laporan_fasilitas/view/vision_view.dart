import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:proyek_4_poki_polban_kita/shared/theme/app_colors.dart';

import '../controller/vision_controller.dart';

class VisionView extends StatefulWidget {
  final VisionController? controller;
  const VisionView({super.key, this.controller});

  @override
  State<VisionView> createState() => _VisionViewState();
}

class _VisionViewState extends State<VisionView>
    with TickerProviderStateMixin {
  late VisionController _visionController;
  bool _ownsController = false;
  bool _isCapturing = false;

  // Animation for shutter effect
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
      _ownsController = true;
    }

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

  Future<void> _capturePhoto() async {
    if (_isCapturing) return;
    if (!_visionController.isInitialized) return;

    setState(() => _isCapturing = true);

    try {
      setState(() => _showShutter = true);
      await _shutterController.forward(from: 0);
      if (mounted) setState(() => _showShutter = false);

      final image = await _visionController.takePhoto();

      if (image == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.danger,
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
              backgroundColor: AppColors.danger,
              content: Text('File foto tidak ditemukan.'),
            ),
          );
        }
        return;
      }

      if (mounted) {
        Navigator.pop(context, image.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.danger,
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
      body: ListenableBuilder(
        listenable: _visionController,
        builder: (context, child) {
          if (!_visionController.isInitialized) {
            return _buildLoadingState();
          }
          return _buildVisionStack();
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.navyDark, Colors.black],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.primaryLight),
            const SizedBox(height: 24),
            const Text(
              "MENGHUBUNGKAN KE KAMERA...",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
                letterSpacing: 1.5,
              ),
            ),
            if (_visionController.errorMessage != null) ...[
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _visionController.errorMessage!,
                  style: const TextStyle(color: AppColors.danger),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => openAppSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text("Open Settings"),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildVisionStack() {
    return LayoutBuilder(
      builder: (context, constraints) {
        double cameraRatio = _visionController.controller!.value.aspectRatio;
        final isPortrait = constraints.maxHeight > constraints.maxWidth;
        final displayRatio = isPortrait ? (1 / cameraRatio) : cameraRatio;

        return Stack(
          fit: StackFit.expand,
          children: [
            // 1. Camera Preview
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

            // 2. HUD / Focus Grid Lines
            _buildFocusHUD(),

            // 4. Shutter Effect
            if (_showShutter)
              Positioned.fill(
                child: FadeTransition(
                  opacity: Tween<double>(begin: 1.0, end: 0.0).animate(_shutterAnimation),
                  child: Container(color: Colors.white),
                ),
              ),

            // 6. Custom Modern App Bar (Floating style)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: _buildCustomAppBar(),
            ),

            // 7. Bottom Action Controls & Shutter
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 20,
              left: 24,
              right: 24,
              child: _buildBottomControls(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFocusHUD() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
          ),
          child: Stack(
            children: [
              // Focus Target Corners
              Center(
                child: Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white12, width: 0.5),
                  ),
                  child: Stack(
                    children: [
                      // Top Left
                      Positioned(
                        top: 0,
                        left: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white60, width: 1.5),
                              left: BorderSide(color: Colors.white60, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      // Top Right
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.white60, width: 1.5),
                              right: BorderSide(color: Colors.white60, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      // Bottom Left
                      Positioned(
                        bottom: 0,
                        left: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white60, width: 1.5),
                              left: BorderSide(color: Colors.white60, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      // Bottom Right
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Colors.white60, width: 1.5),
                              right: BorderSide(color: Colors.white60, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAmbientGradients() {
    return const IgnorePointer(
      child: Stack(
        children: [
          // Top vignette
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              height: 160,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          // Bottom vignette
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 220,
              width: double.infinity,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.navyDark.withOpacity(0.4),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white10, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.07),
            ),
            onPressed: () => Navigator.pop(context),
          ), 

          // Utility toggles
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Flashlight toggle
              IconButton(
                icon: Icon(
                  _visionController.isFlashlightOn ? Icons.flash_on : Icons.flash_off,
                  color: _visionController.isFlashlightOn ? AppColors.warning : Colors.white,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: _visionController.isFlashlightOn
                      ? AppColors.warning.withOpacity(0.2)
                      : Colors.transparent,
                ),
                onPressed: _visionController.toggleFlashlight,
                tooltip: 'Toggle Flashlight',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Shutter & Utility layout
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: (!_isCapturing && _visionController.isInitialized) ? _capturePhoto : null,
              child: Container(
                width: 80,
                height: 80,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isCapturing ? Colors.white30 : Colors.white,
                  ),
                  child: _isCapturing
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(
                            color: AppColors.navy,
                            strokeWidth: 3,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
