import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo.dart';
import '../models/photo_feed_state.dart';
import '../data/providers.dart';
import '../data/photo_storage_data_source.dart';

/// ViewModel for photo feed - manages photo collection state
class PhotoFeedViewModel extends StateNotifier<PhotoFeedState> {
  final PhotoStorageDataSource _storageDataSource;
  bool _isInitialized = false;

  PhotoFeedViewModel(this._storageDataSource) : super(PhotoFeedState());

  Future<void> loadPhotos() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      final photos = await _storageDataSource.loadPhotos();
      state = state.copyWith(photos: photos);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load photos: $e');
    }
  }

  void addPhoto(Photo photo) {
    state = state.copyWith(photos: [photo, ...state.photos]);
    _persistPhotos();
  }

  void updatePhotoCaption(String photoId, String caption) {
    final updatedPhotos = state.photos.map((photo) {
      if (photo.id == photoId) {
        return photo.copyWith(caption: caption);
      }
      return photo;
    }).toList();

    state = state.copyWith(photos: updatedPhotos);
    _persistPhotos();
  }

  Future<void> removePhoto(String photoId) async {
    // Find the photo to delete
    final photoToDelete = state.photos.firstWhere(
      (photo) => photo.id == photoId,
    );

    // Delete from storage
    try {
      await _storageDataSource.deletePhoto(photoToDelete.path);
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete photo: $e');
      return;
    }

    // Remove from state
    state = state.copyWith(
      photos: state.photos.where((photo) => photo.id != photoId).toList(),
    );
    _persistPhotos();
  }

  void clearPhotos() {
    state = state.copyWith(photos: []);
    _persistPhotos();
  }

  Future<void> _persistPhotos() async {
    await _storageDataSource.savePhotosMetadata(state.photos);
  }
}

// Provider for the photo fee
final photoFeedProvider =
    StateNotifierProvider.autoDispose<PhotoFeedViewModel, PhotoFeedState>((
      ref,
    ) {
      final storageDataSource = ref.watch(photoStorageDataSourceProvider);
      return PhotoFeedViewModel(storageDataSource);
    });
