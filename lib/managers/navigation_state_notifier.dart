import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:turf/turf.dart' as turf;

class NavigationState {
  Position? userPosition;
  turf.Position? snappedLocation;
  int? currentInstructionIndex;
  num? distanceToEndOfRoute;
  num? distanceToInstruction;

  NavigationState({
    this.userPosition,
    this.snappedLocation,
    this.currentInstructionIndex,
    this.distanceToEndOfRoute,
    this.distanceToInstruction,
  });

  NavigationState copyWith({
    Position? userPosition,
    turf.Position? snappedLocation,
    int? currentInstructionIndex,
    num? distanceToEndOfRoute,
    num? distanceToInstruction,
  }) {
    return NavigationState(
      userPosition: userPosition ?? this.userPosition,
      snappedLocation: snappedLocation ?? this.snappedLocation,
      currentInstructionIndex:
          currentInstructionIndex ?? this.currentInstructionIndex,
      distanceToEndOfRoute: distanceToEndOfRoute ?? this.distanceToEndOfRoute,
      distanceToInstruction:
          distanceToInstruction ?? this.distanceToInstruction,
    );
  }
}

class NavigationStateNotifier extends StateNotifier<NavigationState> {
  NavigationStateNotifier() : super(NavigationState());

  void updatePosition(Position? userLocation, turf.Position? snappedLocation) {
    state = state.copyWith(
      userPosition: userLocation,
      snappedLocation: snappedLocation,
    );
  }

  void updateCurrentInstructionIndex(int? currentInstructionIndex) {
    state = state.copyWith(currentInstructionIndex: currentInstructionIndex);
  }

  void updateDistances({
    num? distanceToEndOfRoute,
    num? distanceToInstruction,
  }) {
    state = state.copyWith(
      distanceToEndOfRoute: distanceToEndOfRoute,
      distanceToInstruction: distanceToInstruction,
    );
  }
}

final navigationStateProvider =
    StateNotifierProvider<NavigationStateNotifier, NavigationState>(
  (ref) => NavigationStateNotifier(),
);
