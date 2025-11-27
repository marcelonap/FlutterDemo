import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/photo.dart';
import '../models/photo_feed_state.dart';
import '../data/providers.dart';
import 'package:geolocator/geolocator.dart';
import '../data/firebase_data_source.dart';

/// ViewModel for photo feed - manages photo collection state
class PhotoFeedViewModel extends StateNotifier<PhotoFeedState> {
  final FirebaseDataSource _firebaseDataSource;

  PhotoFeedViewModel(this._firebaseDataSource) : super(PhotoFeedState()) {
    // Automatically load photos when view model is created
    loadPhotos();
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
    try {
      print('Loading photos from Firebase...');
      final photos = await _firebaseDataSource.fetchPhotos();
      state = state.copyWith(photos: photos);
      print('Photos loaded successfully. Count: ${photos.length}');
    } catch (e) {
      print('Error loading photos: $e');
      state = state.copyWith(error: 'Failed to load photos: $e');
    }
  }

  Future<void> refreshPhotos() async {
    try {
      print('Refreshing photos from Firebase...');
      final photos = await _firebaseDataSource.fetchPhotos();
      state = state.copyWith(photos: photos);
      print('Photos refreshed successfully. Count: ${photos.length}');
    } catch (e) {
      print('Error refreshing photos: $e');
      state = state.copyWith(error: 'Failed to refresh photos: $e');
    }
  }

  void addPhoto(Photo photo) {
    print('Adding photo: ${photo.caption}');
    state = state.copyWith(photos: [photo, ...state.photos]);
  }

  Future<void> addTempPhoto() async {
    final tempPhoto = state.tempPhoto;
    if (tempPhoto != null) {
      print('Uploading photo to Firebase: ${tempPhoto.caption}');
      try {
        final uploadedPhoto = await _firebaseDataSource.uploadPhoto(tempPhoto);
        print('Photo uploaded successfully with ID: ${uploadedPhoto.id}');
        state = state.copyWith(
          photos: [uploadedPhoto, ...state.photos],
          tempPhoto: null,
        );
      } catch (e) {
        print('Error uploading photo: $e');
        state = state.copyWith(error: 'Failed to upload photo: $e');
      }
    }
  }

  Future<void> updatePhotoCaption(String photoId, String caption) async {
    try {
      await _firebaseDataSource.updatePhotoCaption(photoId, caption);
      final updatedPhotos = state.photos.map((photo) {
        if (photo.id == photoId) {
          return photo.copyWith(caption: caption);
        }
        return photo;
      }).toList();
      state = state.copyWith(photos: updatedPhotos);
    } catch (e) {
      state = state.copyWith(error: 'Failed to update caption: $e');
    }
  }

  Future<void> removePhoto(String photoId) async {
    try {
      final photo = state.photos.firstWhere((p) => p.id == photoId);
      if (photo.url != null) {
        await _firebaseDataSource.deletePhoto(photoId, photo.url!);
      }
      state = state.copyWith(
        photos: state.photos.where((photo) => photo.id != photoId).toList(),
      );
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete photo: $e');
    }
  }

  void clearPhotos() {
    state = state.copyWith(photos: []);
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
