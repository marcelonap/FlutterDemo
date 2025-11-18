# MVVM Architecture with Riverpod

This Flutter app demonstrates proper MVVM architecture using Riverpod for state management, following best practices as discussed in the Flutter community.

## Architecture Overview

The app is structured in three main layers:

```
┌─────────────────────────────────────────┐
│            UI Layer (Views)             │
│        ConsumerWidget only              │
│  - PhotoFeedView                        │
│  - CameraView                           │
│  - PhotoDetailView                      │
└──────────────┬──────────────────────────┘
               │ ref.watch() / ref.read()
               ↓
┌─────────────────────────────────────────┐
│      ViewModel Layer (Logic + State)    │
│      StateNotifierProvider              │
│  - PhotoFeedViewModel                   │
│  - CameraViewModel                      │
└──────────────┬──────────────────────────┘
               │ uses
               ↓
┌─────────────────────────────────────────┐
│      DataSource Layer (Dependencies)    │
│            Provider                     │
│  - CameraDataSource                     │
│  - PhotoStorageDataSource               │
└─────────────────────────────────────────┘
```

## Key Principles

### 1. **DataSources use `Provider`** (not StateNotifier)
- DataSources are dependencies, not state managers
- They handle external operations (camera, storage, API calls)
- Use `Provider<T>` for dependency injection

**Example:**
```dart
final cameraDataSourceProvider = Provider<CameraDataSource>((ref) {
  return CameraDataSource();
});
```

### 2. **ViewModels use `StateNotifierProvider`**
- ViewModels manage state and business logic
- They expose two things:
  - **State**: accessed via `ref.watch(provider)`
  - **Controller/Logic**: accessed via `ref.read(provider.notifier)`

**Example:**
```dart
final photoFeedProvider = 
    StateNotifierProvider<PhotoFeedViewModel, PhotoFeedState>((ref) {
  final storageDataSource = ref.watch(photoStorageDataSourceProvider);
  return PhotoFeedViewModel(storageDataSource);
});
```

### 3. **Views use `ConsumerWidget`** (no StatefulWidget)
- All UI components are stateless `ConsumerWidget`
- No StatefulWidget boilerplate needed
- State initialization happens in ViewModels

**Why no StatefulWidget?**
- Less boilerplate
- Follows modern Flutter/Compose patterns
- State logic stays in ViewModels where it belongs

### 4. **Immutable State Models**
- All state classes are immutable
- Use `copyWith()` for updates
- State never mutates directly

## File Structure

```
lib/
├── data/
│   ├── camera_data_source.dart         # Camera hardware operations
│   ├── photo_storage_data_source.dart  # File storage operations
│   └── providers.dart                  # DataSource providers
├── models/
│   ├── photo.dart                      # Photo model with caption
│   ├── camera_state.dart               # Camera state
│   └── photo_feed_state.dart           # Feed state
├── viewmodels/
│   ├── camera_viewmodel.dart           # Camera logic + state
│   └── photo_feed_viewmodel.dart       # Feed logic + state
├── views/
│   ├── photo_feed_view.dart            # Main feed UI + FAB
│   ├── camera_view.dart                # Camera UI
│   └── [PhotoDetailView in same file]  # Photo detail + caption editing
└── main.dart                           # App entry point
```

## How State Flows

### Taking a Photo (CameraView → ViewModel → DataSource)

1. **UI calls ViewModel method:**
   ```dart
   ref.read(cameraProvider.notifier).takePicture();
   ```

2. **ViewModel uses DataSource:**
   ```dart
   final image = await _cameraDataSource.takePicture(controller);
   final filePath = await _storageDataSource.savePhoto(image.path);
   ```

3. **ViewModel updates state:**
   ```dart
   final photo = Photo(id: timestamp, path: filePath, timestamp: now);
   ref.read(photoFeedProvider.notifier).addPhoto(photo);
   ```

4. **UI rebuilds automatically:**
   ```dart
   final feedState = ref.watch(photoFeedProvider);
   // UI rebuilds with new state
   ```

## State Access Patterns

### Reading State (causes rebuilds)
```dart
final state = ref.watch(photoFeedProvider);
final photos = state.photos;
```

### Calling Methods (no rebuild)
```dart
ref.read(photoFeedProvider.notifier).addPhoto(photo);
```

### Using Both
```dart
// Watch state for UI
final cameraState = ref.watch(cameraProvider);

// Read notifier for actions
ref.read(cameraProvider.notifier).switchCamera();
```

## Why This Architecture?

### Separation of Concerns
- **DataSources**: "How do I talk to external systems?"
- **ViewModels**: "What is the current state? What actions can be performed?"
- **Views**: "How do I display this data?"

### Testability
- DataSources can be mocked easily
- ViewModels test business logic in isolation
- UI tests can use fake providers

### Similar to Native MVVM
If you're familiar with:
- **Android (Kotlin)**: ViewModel + Repository pattern
- **iOS (Swift)**: ViewModel + Service pattern

This Flutter architecture maps directly:
- DataSource = Repository/Service
- ViewModel = ViewModel
- ConsumerWidget = @Composable/@State in SwiftUI

## Features Demonstrated

✅ Photo capture with camera
✅ Photo feed with captions
✅ Caption editing
✅ Photo deletion (with storage cleanup)
✅ Floating Action Button navigation
✅ No StatefulWidget usage
✅ Proper MVVM separation
✅ Riverpod best practices

## Comparing to StatefulWidget

### ❌ Old way (StatefulWidget + ConsumerStatefulWidget)
```dart
class CameraView extends ConsumerStatefulWidget {
  @override
  ConsumerState<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends ConsumerState<CameraView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(provider.notifier).init());
  }
  // ...
}
```

### ✅ New way (ConsumerWidget)
```dart
class CameraView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialization in ViewModel or on first build
    final state = ref.watch(cameraProvider);
    // ...
  }
}
```

## Teaching This to Students

### Key Takeaways
1. **Provider** = dependencies (no state changes)
2. **StateNotifierProvider** = state + logic (rebuilds UI)
3. **ConsumerWidget** = all UI (no StatefulWidget needed)
4. **ref.watch()** = read state (rebuilds on change)
5. **ref.read().notifier** = call methods (no rebuild)

### From Compose/SwiftUI Perspective
- `ConsumerWidget` ~ `@Composable` or SwiftUI `View`
- `ref.watch()` ~ observing state
- `StateNotifierProvider` ~ `MutableState` or `@StateObject`
- Clean separation like MVVM in native

## Common Patterns

### Adding a new feature
1. Create DataSource if needed (external operations)
2. Create ViewModel (state + business logic)
3. Create View (UI only, uses ConsumerWidget)
4. Wire up with Providers

### When to use StatefulWidget?
**Almost never!** But acceptable for:
- TextEditingController (though you can avoid with providers)
- AnimationController (rare, can use hooks instead)
- Focus management (can often avoid)

**In this app:** Zero StatefulWidget usage ✅

---

**Summary**: This architecture provides clear separation of concerns, follows Flutter best practices, and maps directly to native mobile MVVM patterns you're already familiar with from Android/iOS development.
