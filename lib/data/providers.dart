import 'package:camera_example/models/photo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo_feed_state.dart';
import 'camera_data_source.dart';
import 'photo_storage_data_source.dart';
import 'geolocation_data_source.dart';
import '../models/geolocation_state.dart';
import 'permission_data_source.dart';

/// Provider for camera data source (dependency injection)
final cameraDataSourceProvider = Provider<CameraDataSource>((ref) {
  return CameraDataSource();
});

/// Provider for photo storage data source (dependency injection)
final photoStorageDataSourceProvider = Provider<PhotoStorageDataSource>((ref) {
  return PhotoStorageDataSource();
});

/// Provider for permission data source (dependency injection)
final permissionDataSourceProvider = Provider<PermissionDataSource>((ref) {
  return PermissionDataSource();
});

/// Exposing provider for stateful geolocation data sorce
final locationDataSourceProvider =
    StateNotifierProvider<GeolocationDataSource, GeolocationState>((ref) {
      return GeolocationDataSource();
    });
