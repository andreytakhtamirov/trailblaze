import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

final mapStateProvider =
    StateNotifierProvider<MapStateNotifier, MapState?>((ref) {
  return MapStateNotifier();
});

class MapStateNotifier extends StateNotifier<MapState?> {
  final MapState _mapState = MapState();

  MapStateNotifier() : super(null);

  CoordinateBounds? getCameraBounds() {
    return _mapState.bounds;
  }

  void setCameraBounds(CoordinateBounds? bounds) {
    _mapState.bounds = bounds;
  }
}

class MapState {
  CoordinateBounds? bounds;

  MapState({this.bounds});
}
