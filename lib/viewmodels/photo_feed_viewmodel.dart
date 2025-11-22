import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo.dart';
import '../models/photo_feed_state.dart';
import '../data/providers.dart';
import 'package:geolocator/geolocator.dart';
import '../data/firebase_data_source.dart';

/// ViewModel for photo feed - manages photo collection state
class PhotoFeedViewModel extends StateNotifier<PhotoFeedState> {
  final FirebaseDataSource _firebaseDataSource;
  bool _isInitialized = false;

  PhotoFeedViewModel(this._firebaseDataSource) : super(PhotoFeedState()) {
    _initialize();
  }

  void _initialize() async {
    final photos = await loadPhotos();
  }

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

  void updateTempPhotoLocation(Position location) {
    if (state.tempPhoto != null) {
      print("Updating temp photo location to: $location");
      final updatedTempPhoto = state.tempPhoto!.copyWith(location: location);
      state = state.copyWith(tempPhoto: updatedTempPhoto);
      print("State with : ${state.tempPhoto!.location}");
    }
  }

  Future<void> loadPhotos() async {
    if (_isInitialized) return;
    _isInitialized = true;

    try {
      final photos = await _firebaseDataSource.fetchPhotos();
      state = state.copyWith(photos: photos);
    } catch (e) {
      state = state.copyWith(error: 'Failed to load photos: $e');
    }
  }

  Future<void> refreshPhotos() async {
    try {
      state = state.copyWith(isLoading: true);
      final photos = await _firebaseDataSource.fetchPhotos();
      state = state.copyWith(photos: photos, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        error: 'Failed to refresh photos: $e',
        isLoading: false,
      );
    }
  }

  Future<void> addTempPhoto() async {
    final tempPhoto = state.tempPhoto;
    if (tempPhoto != null) {
      print('Adding photo: ${tempPhoto.caption}');

      // Upload to Firebase
      try {
        final uploadedPhoto = await _firebaseDataSource.uploadPhoto(tempPhoto);

        // Add to state with Firebase URL and ID
        state = state.copyWith(
          photos: [uploadedPhoto, ...state.photos],
          tempPhoto: null,
        );
      } catch (e) {
        state = state.copyWith(error: 'Failed to upload photo: $e');
        print('Error uploading photo: $e');
      }
    }
  }

  Future<void> updatePhotoCaption(String photoId, String caption) async {
    // Update local state first for immediate UI update
    final updatedPhotos = state.photos.map((photo) {
      if (photo.id == photoId) {
        return photo.copyWith(caption: caption);
      }
      return photo;
    }).toList();

    state = state.copyWith(photos: updatedPhotos);

    // Update in Firebase
    try {
      await _firebaseDataSource.updatePhotoCaption(photoId, caption);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update caption: $e');
      print('Error updating caption: $e');
    }
  }

  Future<void> removePhoto(String photoId) async {
    // Find the photo to delete
    final photoToDelete = state.photos.firstWhere(
      (photo) => photo.id == photoId,
    );

    // Remove from state first for immediate UI update
    state = state.copyWith(
      photos: state.photos.where((photo) => photo.id != photoId).toList(),
    );

    // Delete from Firebase
    try {
      await _firebaseDataSource.deletePhoto(
        photoToDelete.id,
        photoToDelete.url ?? '',
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete photo: $e');
      print('Error deleting photo: $e');
    }
  }
}

// Provider for the photo feed
final photoFeedProvider =
    StateNotifierProvider.autoDispose<PhotoFeedViewModel, PhotoFeedState>((
      ref,
    ) {
      final firebaseDataSource = ref.read(firebaseDataSourceProvider);
      return PhotoFeedViewModel(firebaseDataSource);
    });
