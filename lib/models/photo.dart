class Photo {
  final String id;
  final String path;
  final DateTime timestamp;
  final String caption;

  Photo({
    required this.id,
    required this.path,
    required this.timestamp,
    this.caption = '',
  });

  set caption(String newCaption) {
    this.caption = newCaption;
  }

  Photo copyWith({
    String? id,
    String? path,
    DateTime? timestamp,
    String? caption,
  }) {
    return Photo(
      id: id ?? this.id,
      path: path ?? this.path,
      timestamp: timestamp ?? this.timestamp,
      caption: caption ?? this.caption,
    );
  }
}
