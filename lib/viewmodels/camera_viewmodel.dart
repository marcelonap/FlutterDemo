import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/camera_state.dart';
import '../models/photo.dart';
import '../data/providers.dart';
import '../data/camera_data_source.dart';
import '../data/photo_storage_data_source.dart';
import '../data/permission_data_source.dart';
import 'photo_feed_viewmodel.dart';

/// ViewModel for camera - manages camera state and photo capture logic
class CameraViewModel extends StateNotifier<CameraState> {
  final CameraDataSource _cameraDataSource;
  final PhotoStorageDataSource _storageDataSource;
  final PermissionDataSource _permissionDataSource;
  final void Function(Photo) _onPhotoTaken;

  CameraViewModel(
    this._cameraDataSource,
    this._storageDataSource,
    this._permissionDataSource,
    this._onPhotoTaken,
  ) : super(CameraState());

  Future<void> initializeCamera() async {
    try {
      // Check camera permission
      final hasPermission = await _permissionDataSource
          .isCameraPermissionGranted();

      if (!hasPermission) {
        // Request permission
        final granted = await _permissionDataSource.requestCameraPermission();

        if (!granted) {
          final isPermanentlyDenied = await _permissionDataSource
              .isCameraPermissionPermanentlyDenied();
          if (isPermanentlyDenied) {
            state = state.copyWith(
              error: 'Camera permission denied. Please enable it in Settings.',
            );
          } else {
            state = state.copyWith(error: 'Camera permission is required');
          }
          return;
        }
      }

      await _cameraDataSource.initialize();

      state = state.copyWith(isInitialized: true, error: null);
    } catch (e) {
      state = state.copyWith(error: 'Failed to initialize camera: $e');
    }
  }

  Future<Photo?> takePicture({String caption = ''}) async {
    if (!state.isInitialized) {
      return null;
    }

    try {
      // Capture photo using data source
      final image = await _cameraDataSource.takePicture();

      // Save to permanent storage using data source
      final filePath = await _storageDataSource.savePhoto(image.path);
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // Create Photo model and add to feed
      final photo = Photo(
        id: timestamp,
        path: filePath,
        timestamp: DateTime.now(),
        caption: caption,
      );

      _onPhotoTaken(photo);
      return photo;
    } catch (e) {
      state = state.copyWith(error: 'Failed to take picture: $e');
      return null;
    }
  }

  Future<void> switchCamera() async {
    try {
      await _cameraDataSource.switchCamera();

      state = state.copyWith(isInitialized: true, error: null);
    } catch (e) {
      state = state.copyWith(error: 'Failed to switch camera: $e');
    }
  }

  CameraController? get controller => _cameraDataSource.controller;

  @override
  void dispose() {
    _cameraDataSource.dispose();
    super.dispose();
  }
}

// Provider for the camera
final cameraProvider =
    StateNotifierProvider.autoDispose<CameraViewModel, CameraState>((ref) {
      final cameraDataSource = ref.read(cameraDataSourceProvider);
      final storageDataSource = ref.read(photoStorageDataSourceProvider);
      final permissionDataSource = ref.read(permissionDataSourceProvider);

      return CameraViewModel(
        cameraDataSource,
        storageDataSource,
        permissionDataSource,
        (photo) {
          // Delay the cross-provider call to avoid dependency issues
          Future.microtask(() {
            ref.read(photoFeedProvider.notifier).addPhoto(photo);
          });
        },
      );
    });
