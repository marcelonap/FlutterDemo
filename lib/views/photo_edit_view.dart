import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera_example/viewmodels/photo_feed_viewmodel.dart';
import 'package:camera_example/models/photo.dart';
import 'dart:io';

class PhotoEditView extends ConsumerWidget {
  const PhotoEditView({super.key, required this.photo});

  final Photo photo;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoFeedState = ref.watch(photoFeedProvider);
    final photoFeedViewModel = ref.read(photoFeedProvider.notifier);
    final caption = "";
    final textController = TextEditingController(text: caption);
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
                  child: Image.file(File(photo.path)),
                ),
              ),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Caption',
                contentPadding: EdgeInsets.all(12.0),
              ),
              controller: textController,
              onChanged: (value) {
                textController.text = value; // Handle caption change if needed
                photoFeedViewModel.updatePhotoCaption(photo.id, caption);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: Builder(
        builder: (context) {
          return FloatingActionButton(
            onPressed: () {
              photoFeedViewModel.addPhoto(photo);
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
