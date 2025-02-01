import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:turf/turf.dart' as turf;

const kInvalidInstruction = -10;
const kInvalidBearing = -10;

class NavigationState {
  // User's real position from GPS coordinates.
  Position? userPosition;

  // User's location (either current or last closest) snapped to route.
  // If null, then user has never been close to the route.
  turf.Position? snappedLocation;

  // The index of the instruction which the user is currently inside (with tolerance).
  // A value of kInvalidInstruction indicates that user is not inside any instructions.
  int? currentInstructionIndex;

  // Computed distance along all instructions starting
  // from the user's current snapped location.
  num? distanceToEndOfRoute;

  // Computed distance to end of current instruction
  // from the user's snapped location.
  num? distanceToInstruction;

  // Represents a turn angle (degrees) which the user
  // would need to complete to join back to the route.
  // A value of kInvalidBearing indicates that user is following the route.
  num? directionToRoute;

  NavigationState({
    this.userPosition,
    this.snappedLocation,
    this.currentInstructionIndex,
    this.distanceToEndOfRoute,
    this.distanceToInstruction,
    this.directionToRoute,
  });

  NavigationState copyWith({
    Position? userPosition,
    turf.Position? snappedLocation,
    int? currentInstructionIndex,
    num? distanceToEndOfRoute,
    num? distanceToInstruction,
    num? directionToRoute,
  }) {
    return NavigationState(
      userPosition: userPosition ?? this.userPosition,
      snappedLocation: snappedLocation ?? this.snappedLocation,
      currentInstructionIndex:
          currentInstructionIndex ?? this.currentInstructionIndex,
      distanceToEndOfRoute: distanceToEndOfRoute ?? this.distanceToEndOfRoute,
      distanceToInstruction:
          distanceToInstruction ?? this.distanceToInstruction,
      directionToRoute: directionToRoute ?? this.directionToRoute,
    );
  }
}

class NavigationStateNotifier extends StateNotifier<NavigationState> {
  NavigationStateNotifier() : super(NavigationState());

  void updatePosition(Position? userLocation, turf.Position? snappedLocation,
      int? currentInstructionIndex) {
    state = state.copyWith(
      userPosition: userLocation,
      snappedLocation: snappedLocation,
      currentInstructionIndex: currentInstructionIndex,
    );
  }

  void updateDistances({
    num? distanceToEndOfRoute,
    num? distanceToInstruction,
    num? directionToRoute,
  }) {
    state = state.copyWith(
      distanceToEndOfRoute: distanceToEndOfRoute,
      distanceToInstruction: distanceToInstruction,
      directionToRoute: directionToRoute,
    );
  }

  void clearState() {
    state = NavigationState();
  }
}

final navigationStateProvider =
    StateNotifierProvider<NavigationStateNotifier, NavigationState>(
  (ref) => NavigationStateNotifier(),
);
