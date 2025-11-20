import 'package:permission_handler/permission_handler.dart';

/// DataSource for permission handling - manages runtime permissions
class PermissionDataSource {
  /// Checks if camera permission is granted
  Future<bool> isCameraPermissionGranted() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Requests camera permission from the user
  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      // Request the permission
      status = await Permission.camera.request();
      if (status.isGranted) {
        // Permission granted, proceed with camera access
        print("Camera permission granted.");
      } else if (status.isPermanentlyDenied) {
        // Permission permanently denied, guide user to app settings
        print("Camera permission permanently denied. Open app settings.");
        openAppSettings(); // Opens app settings for the user
      } else {
        // Permission denied
        print("Camera permission denied.");
      }
    } else if (status.isGranted) {
      // Permission already granted, proceed with camera access
      print("Camera permission already granted.");
    } else if (status.isPermanentlyDenied) {
      // Permission permanently denied, guide user to app settings
      print("Camera permission permanently denied. Open app settings.");
      openAppSettings();
    }
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
