import 'photo.dart';

/// State for the photo feed
class PhotoFeedState {
  final List<Photo> photos;
  final bool isLoading;
  final String? error;
  final Photo? tempPhoto;

  PhotoFeedState({
    this.photos = const [],
    this.isLoading = false,
    this.tempPhoto,
    this.error,
  });

  PhotoFeedState copyWith({
    List<Photo>? photos,
    bool? isLoading,
    Photo? tempPhoto,
    String? error,
  }) {
    return PhotoFeedState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      tempPhoto: tempPhoto ?? this.tempPhoto,
      error: error,
    );
  }
}
