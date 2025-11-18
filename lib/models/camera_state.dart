class CameraState {
  final bool isInitialized;
  final String? error;

  CameraState({this.isInitialized = false, this.error});

  CameraState copyWith({bool? isInitialized, String? error}) {
    return CameraState(
      isInitialized: isInitialized ?? this.isInitialized,
      error: error ?? this.error,
    );
  }
}
