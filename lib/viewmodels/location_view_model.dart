import '../models/geolocation_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/geolocation_data_source.dart';
import '../data/providers.dart';

class LocationViewModel extends StateNotifier<LocationViewModelState> {
  final Ref ref;
  final GeolocationDataSource dataSource;
  LocationViewModel(this.ref, this.dataSource)
    : super(LocationViewModelState.initial) {
    _initialize();
  }

  void _initialize() {
    ref.listen(locationDataSourceProvider, (prev, next) {
      if (next.error != null) {
        state = state.copyWith(message: next.error);
      } else if (next.position != null) {
        state = state.copyWith(
          position: next.position,
          message: "Location acquired",
        );
      }
    });
  }
}

final locationViewModelProvider =
    StateNotifierProvider<LocationViewModel, LocationViewModelState>((ref) {
      final dataSource = ref.watch(locationDataSourceProvider.notifier);
      return LocationViewModel(ref, dataSource);
    });
