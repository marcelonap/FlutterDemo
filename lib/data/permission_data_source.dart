import 'package:permission_handler/permission_handler.dart';

/// DataSource for permission handling - manages runtime permissions
class PermissionDataSource {
  /// Checks if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Requests camera permission from the user
  /// Returns true if granted, false otherwise
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Checks if permission was permanently denied
  /// Used to direct users to app settings
  Future<bool> isCameraPermissionPermanentlyDenied() async {
    final status = await Permission.camera.status;
    return status.isPermanentlyDenied;
  }

  /// Opens app settings for manual permission grant
  Future<bool> openAppSettings() async {
    return await openAppSettings();
  }
}
