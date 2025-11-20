import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod/riverpod.dart';
import '../models/geolocation_state.dart';

class GeolocationDataSource extends StateNotifier<GeolocationState> {
  GeolocationDataSource() : super(GeolocationState()) {
    subscribeToPositionUpdates();
  }

  Stream<Position>? _positionStream;
  StreamSubscription<Position>? _positionSubscription;

  Future<void> subscribeToPositionUpdates() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();

    print("@subscribeToPositionUpdates serviceEnabled: $serviceEnabled");
    if (!serviceEnabled) {
      state = state.copyWith(error: 'Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    print("@subscribeToPositionUpdates permission: $permission");
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      print(
        "@subscribeToPositionUpdates permission after request: $permission",
      );
      if (permission == LocationPermission.denied) {
        state = state.copyWith(error: 'Location permissions are denied');
        return;
      }
      print(
        "@subscribeToPositionUpdates permission after requests: $permission",
      );
    }
    if (permission == LocationPermission.deniedForever) {
      state = state.copyWith(
        error:
            'Location permissions are permanently denied, we cannot request permissions.',
      );
      return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );

    _positionSubscription = _positionStream!.listen(
      (position) {
        print("@Position update: $position");
        state = state.copyWith(position: position, error: null);
        print("@State updated: $state");
      },
      onError: (error) {
        state = state.copyWith(error: error.toString());
      },
    );
  }

  Future<void> unsubscribeFromPositionUpdates() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _positionStream = null;
  }
}
