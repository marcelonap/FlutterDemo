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

  void setTempPhoto(Photo? photo) {
    //make sure to not add 2 copies of the same photo to the state
    if (photo != null && state.tempPhoto?.id == photo.id) {
      return;
    }
    state = state.copyWith(tempPhoto: photo);
  }

  void updateTempPhotoCaption(String caption) {
    if (state.tempPhoto != null) {
      final updatedTempPhoto = state.tempPhoto!.copyWith(caption: caption);
      state = state.copyWith(tempPhoto: updatedTempPhoto);
    }
  }

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
    print('Adding photo: ${photo.caption}');
    state = state.copyWith(photos: [photo, ...state.photos]);
    _persistPhotos();
  }

  void addTempPhoto() {
    final tempPhoto = state.tempPhoto;
    if (tempPhoto != null) {
      print('Adding photo: ${tempPhoto.caption}');
      state = state.copyWith(
        photos: [tempPhoto, ...state.photos],
        tempPhoto: null,
      );
      _persistPhotos();
    }
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
    state = state.copyWith(
      photos: state.photos.where((photo) => photo.id != photoId).toList(),
    );

    // Delete from storage
    try {
      await _storageDataSource.deletePhoto(photoToDelete.path);
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete photo: $e');
      return;
    }

    // Remove from state
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
      final storageDataSource = ref.read(photoStorageDataSourceProvider);
      return PhotoFeedViewModel(storageDataSource);
    });
