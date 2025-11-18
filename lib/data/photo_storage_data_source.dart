import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import '../models/photo_feed_state.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../models/photo.dart';

/// DataSource for photo storage operations
class PhotoStorageDataSource {
  static const String _metadataFileName = 'photos_metadata.json';

  PhotoStorageDataSource();

  Future<String> savePhoto(String sourcePath) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final filePath = path.join(directory.path, 'photo_$timestamp.jpg');

    await File(sourcePath).copy(filePath);
    return filePath;
  }

  Future<void> deletePhoto(String filePath) async {
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }

  bool photoExists(String filePath) {
    return File(filePath).existsSync();
  }

  /// Saves all photos metadata (including captions) to persistent storage
  Future<void> savePhotosMetadata(List<Photo> photos) async {
    final directory = await getApplicationDocumentsDirectory();
    final metadataFile = File(path.join(directory.path, _metadataFileName));

    final jsonData = photos
        .map(
          (photo) => {
            'id': photo.id,
            'path': photo.path,
            'timestamp': photo.timestamp.toIso8601String(),
            'caption': photo.caption,
          },
        )
        .toList();

    await metadataFile.writeAsString(json.encode(jsonData));
  }

  /// Loads all photos with their metadata from persistent storage
  Future<List<Photo>> loadPhotos() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final metadataFile = File(path.join(directory.path, _metadataFileName));

      if (!await metadataFile.exists()) {
        return [];
      }

      final jsonString = await metadataFile.readAsString();
      final List<dynamic> jsonData = json.decode(jsonString);

      return jsonData
          .map(
            (item) => Photo(
              id: item['id'] as String,
              path: item['path'] as String,
              timestamp: DateTime.parse(item['timestamp'] as String),
              caption: item['caption'] as String? ?? '',
            ),
          )
          .where((photo) => photoExists(photo.path))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
