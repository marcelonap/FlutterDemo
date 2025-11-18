import 'photo.dart';

/// State for the photo feed
class PhotoFeedState {
  final List<Photo> photos;
  final bool isLoading;
  final String? error;

  PhotoFeedState({
    this.photos = const [],
    this.isLoading = false,
    this.error,
  });

  PhotoFeedState copyWith({
    List<Photo>? photos,
    bool? isLoading,
    String? error,
  }) {
    return PhotoFeedState(
      photos: photos ?? this.photos,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}
