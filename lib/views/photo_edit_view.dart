import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera_example/viewmodels/photo_feed_viewmodel.dart';
import 'package:camera_example/models/photo.dart';
import '../viewmodels/location_view_model.dart';
import 'dart:io';

class PhotoEditView extends ConsumerWidget {
  const PhotoEditView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoFeedState = ref.watch(photoFeedProvider);
    final photoFeedViewModel = ref.read(photoFeedProvider.notifier);
    final locationState = ref.watch(locationViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Photo')),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: Image.file(File(photoFeedState.tempPhoto!.path)),
                ),
              ),
            ),
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Caption',
                contentPadding: EdgeInsets.all(12.0),
              ),
              initialValue: photoFeedState.tempPhoto?.caption ?? '',
              onChanged: (value) {
                photoFeedViewModel.updateTempPhotoCaption(value);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              if (locationState.position != null) {
                photoFeedViewModel.updateTempPhotoLocation(
                  locationState.position!,
                );
              }
              if (photoFeedState.tempPhoto != null) {
                photoFeedViewModel.addTempPhoto();
              }
              print("From Sceren Location: ${locationState.position}");

              Navigator.pop(context);
              Navigator.pop(context);
            },
            tooltip: 'Save Photo',
            backgroundColor: Colors.green,
            child: const Icon(Icons.save),
          );
        },
      ),
    );
  }
}
