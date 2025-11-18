import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodels/camera_viewmodel.dart';
import 'photo_edit_view.dart';
import 'photo_feed_view.dart';

class CameraView extends ConsumerWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize camera on first build
    final cameraViewModel = ref.read(cameraProvider.notifier);
    final cameraState = ref.watch(cameraProvider);
    final initialized = cameraState.isInitialized;

    if (!initialized && cameraState.error == null) {
      Future.microtask(() => cameraViewModel.initializeCamera());
    }

    final controller = cameraViewModel.controller;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: cameraState.error != null
            ? Center(
                child: Text(
                  cameraState.error!,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            : !cameraState.isInitialized || controller == null
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // Camera preview
                  SizedBox.expand(child: CameraPreview(controller)),
                  // Top bar with switch camera and view feed buttons
                  Positioned(
                    top: 16,
                    left: 16,
                    right: 16,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () {
                            cameraViewModel.switchCamera();
                          },
                          icon: const Icon(
                            Icons.flip_camera_ios,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PhotoFeedView(),
                              ),
                            );
                          },
                          icon: const Icon(
                            Icons.photo_library,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Bottom capture button
                  Positioned(
                    bottom: 32,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: GestureDetector(
                        onTap: () async {
                          // Take picture
                          final photo = await cameraViewModel.takePicture();
                          if (photo != null && context.mounted) {
                            // Navigate to photo_edit_view
                            // Note: photo is already set as tempPhoto via callback
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PhotoEditView(),
                              ),
                            );
                          }
                        },
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
