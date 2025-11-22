import 'package:geolocator/geolocator.dart';

class Photo {
  final String id;
  final String path;
  final DateTime timestamp;
  final String caption;
  final Position? location;
  final String? url;

  Photo({
    required this.id,
    required this.path,
    required this.timestamp,
    this.caption = '',
    this.location,
    this.url,
  });

  set caption(String newCaption) {
    caption = newCaption;
  }

  set location(Position pos) {
    location = pos;
  }

  Photo copyWith({
    String? id,
    String? path,
    DateTime? timestamp,
    String? caption,
    Position? location,
    String? url,
  }) {
    return Photo(
      id: id ?? this.id,
      path: path ?? this.path,
      timestamp: timestamp ?? this.timestamp,
      caption: caption ?? this.caption,
      location: location ?? this.location,
      url: url ?? this.url,
    );
  }
}
