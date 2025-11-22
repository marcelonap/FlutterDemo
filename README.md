# Camera Example App

A Flutter camera application showcasing Riverpod state management with MVVM architecture.

## Running on your device

I have not tried it myself but to run this on your own device you will need to configure the app for your own firebase project. Either via CLI or manually. I recommend asking AI for help if you get stuck with this process

## Features

- 📸 Take photos using device camera
- 🖼️ View photos in a grid feed
- 🔍 Zoom and pan photos
- 🗑️ Delete individual photos or clear all
- 🔄 Switch between front and back cameras

## Architecture

This app follows an MVVM (Model-View-ViewModel) architecture pattern using Riverpod for state management:

### Project Structure

```
lib/
├── models/
│   ├── photo.dart           # Photo data model
│   └── camera_state.dart    # Camera state model
├── viewmodels/
│   ├── camera_viewmodel.dart      # Camera logic & state management
│   └── photo_feed_viewmodel.dart  # Photo feed logic & state management
├── views/
│   ├── camera_view.dart     # Camera UI screen
│   └── photo_feed_view.dart # Photo feed & detail UI screens
└── main.dart                # App entry point with ProviderScope
```

### MVVM Components

**Models**: Immutable data classes representing the app's data
- `Photo`: Represents a captured photo with id, path, and timestamp
- `CameraState`: Holds camera controller state and initialization status

**ViewModels**: Business logic and state management using Riverpod's `StateNotifier`
- `CameraViewModel`: Manages camera initialization, photo capture, and camera switching
- `PhotoFeedViewModel`: Manages the list of captured photos (add, remove, clear)

**Views**: UI components using `ConsumerWidget` or `ConsumerStatefulWidget`
- `CameraView`: Displays camera preview with capture and navigation controls
- `PhotoFeedView`: Shows grid of captured photos
- `PhotoDetailView`: Full-screen photo viewer with zoom capability

### State Management

The app uses **Riverpod** providers:
- `cameraProvider`: Provides `CameraState` and camera-related actions
- `photoFeedProvider`: Provides the list of `Photo` objects and feed actions

Views watch these providers to rebuild when state changes, similar to LiveData/StateFlow in Android.

## Getting Started

### Prerequisites

- Flutter SDK (3.9.2 or higher)
- iOS Simulator/Device or Android Emulator/Device

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
flutter run
```

### Permissions

The app requires camera permissions, which are already configured:

**iOS** (`ios/Runner/Info.plist`):
- NSCameraUsageDescription
- NSPhotoLibraryUsageDescription

**Android** (`android/app/src/main/AndroidManifest.xml`):
- CAMERA permission
- READ/WRITE_EXTERNAL_STORAGE permissions (for API < 33)

## Dependencies

- `flutter_riverpod`: State management
- `camera`: Camera functionality
- `path_provider`: File system paths
- `path`: Path manipulation utilities

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
