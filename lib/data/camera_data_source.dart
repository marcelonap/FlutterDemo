import 'package:camera/camera.dart';

/// DataSource for camera operations - manages complete camera lifecycle
/// Owns the camera controller and provides high-level camera operations
class CameraDataSource {
  List<CameraDescription>? _cameras;
  CameraController? _controller;
  int _currentCameraIndex = 0;

  /// Initializes the camera system and activates the first available camera
  Future<void> initialize() async {
    _cameras = await availableCameras();
    if (_cameras == null || _cameras!.isEmpty) {
      throw Exception('No cameras available');
    }

    await _initializeController(_cameras![_currentCameraIndex]);
  }

  Future<void> switchCamera() async {
    if (_cameras == null || _cameras!.length < 2) {
      throw Exception('Cannot switch camera: insufficient cameras available');
    }

    await _controller?.dispose();
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras!.length;
    await _initializeController(_cameras![_currentCameraIndex]);
  }

  /// Captures a photo and returns the image file
  Future<XFile> takePicture() async {
    if (_controller == null || !_controller!.value.isInitialized) {
      throw Exception('Camera not initialized');
    }
    return await _controller!.takePicture();
  }

  /// Disposes camera resources
  Future<void> dispose() async {
    await _controller?.dispose();
    _controller = null;
  }

  /// Provides access to the camera controller for preview widget
  CameraController? get controller => _controller;

  /// Checks if camera is initialized and ready
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> _initializeController(CameraDescription camera) async {
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    await _controller!.initialize();
  }
}
