import 'package:geolocator/geolocator.dart';

class GeolocationState {
  final Position? position;
  final String? error;

  GeolocationState({this.position, this.error});

  GeolocationState copyWith({Position? position, String? error}) {
    return GeolocationState(position: position, error: error);
  }

  static final initial = GeolocationState();
}

class LocationViewModelState {
  final Position? position;
  final String? message;

  const LocationViewModelState({this.position, this.message});

  LocationViewModelState copyWith({Position? position, String? message}) {
    return LocationViewModelState(
      position: position ?? this.position,
      message: message ?? this.message,
    );
  }

  static const initial = LocationViewModelState(message: "Initializing");
}
