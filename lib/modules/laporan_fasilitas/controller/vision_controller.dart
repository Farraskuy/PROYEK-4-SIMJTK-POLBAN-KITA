import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// VisionController manages the camera lifecycle and detection logic
/// for the Smart Patrol System.
class VisionController extends ChangeNotifier with WidgetsBindingObserver {
  CameraController? controller;

  bool isInitialized = false;
  String? errorMessage;

  Future<void>? _cameraLifecycleInFlight;

  bool isFlashlightOn = false;
  bool isOverlayVisible = true;

  VisionController() {
    WidgetsBinding.instance.addObserver(this);
    _cameraLifecycleInFlight = initCamera();
  }

  Future<void> initCamera() async {
    try {
      await controller?.dispose();
      controller = null;
      isInitialized = false;

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        errorMessage = "No camera detected on device.";
        notifyListeners();
        return;
      }

      controller = CameraController(
        cameras[0],
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await controller!.initialize();
      isInitialized = true;
      errorMessage = null;
    } catch (e) {
      errorMessage = "Failed to initialize camera: $e";
      isInitialized = false;
    }

    notifyListeners();
  }

  Future<XFile?> takePhoto() async {
    if (controller == null || !controller!.value.isInitialized) {
      errorMessage = "Camera not ready.";
      notifyListeners();
      return null;
    }

    // Jika sedang take picture, tolak
    if (controller!.value.isTakingPicture) {
      return null;
    }

    try {
      final image = await controller!.takePicture();
      return image;
    } catch (e) {
      errorMessage = "Failed to capture photo: $e";
      notifyListeners();
      return null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive) {
      _cameraLifecycleInFlight = _disposeCameraForLifecycle();
    } else if (state == AppLifecycleState.resumed) {
      _cameraLifecycleInFlight = (_cameraLifecycleInFlight ?? Future.value())
          .catchError((_) {})
          .then((_) => initCamera());
    }
  }

  Future<void> _disposeCameraForLifecycle() async {
    try {
      await controller?.dispose();
    } finally {
      controller = null;
      isInitialized = false;
      notifyListeners();
    }
  }

  Future<void> toggleFlashlight() async {
    if (controller == null || !controller!.value.isInitialized) return;

    isFlashlightOn = !isFlashlightOn;

    try {
      await controller!.setFlashMode(
        isFlashlightOn ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      // Beberapa device tidak support torch mode, silently ignore
      isFlashlightOn = !isFlashlightOn; // revert
    }

    notifyListeners();
  }

  void toggleOverlay() {
    isOverlayVisible = !isOverlayVisible;
    notifyListeners();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }
}

class DetectionResult {
  final Rect box;
  final String label;
  final double score;

  DetectionResult({
    required this.box,
    required this.label,
    required this.score,
  });
}
