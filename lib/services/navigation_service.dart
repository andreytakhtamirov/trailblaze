import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:trailblaze/constants/navigation_constants.dart';
import 'package:trailblaze/data/instruction.dart';
import 'package:trailblaze/managers/navigation_state_notifier.dart';
import 'package:trailblaze/util/navigation_util.dart';
import 'package:turf/turf.dart' as turf;

class NavigationService {
  StreamSubscription<Position>? _positionStream;
  int _currentInstructionIndex = 0;

  void initializeLocationStream(
      NavigationStateNotifier notifier, List<Instruction>? instructions) {
    _positionStream = Geolocator.getPositionStream(
            locationSettings: kNavigationLocationSettings)
        .listen((Position? position) {
      if (position != null && instructions != null) {
        _onLocationUpdate(position, notifier, instructions);
      }
    });
  }

  void _onLocationUpdate(Position position, NavigationStateNotifier notifier,
      List<Instruction> instructions) {
    calculateLocation(position, notifier, instructions);
  }

  void calculateLocation(Position position, NavigationStateNotifier notifier,
      List<Instruction> instructions) {
    Instruction? closest;
    int? closestIndex;
    num? minDistance;
    final coordinates = turf.Position(position.longitude, position.latitude);

    for (int i = 0; i < instructions.length; i++) {
      final instruction = instructions[i];
      final distance = NavigationUtil.calculateDistanceToInstruction(
          coordinates, instruction);

      if (distance != null) {
        if (minDistance == null || distance < minDistance) {
          minDistance = distance;
          closest = instruction;
          closestIndex = i;
        }
      }
    }

    if (closestIndex != null) {
      _currentInstructionIndex = closestIndex;
    }

    final currentInstruction = instructions[_currentInstructionIndex];
    final snappedLocation =
        NavigationUtil.snapToRoute(coordinates, currentInstruction);
    notifier.updatePosition(position, snappedLocation);

    if (closest != null && closestIndex != null) {
      notifier.updateCurrentInstructionIndex(closestIndex);
      notifier.updateDistances(
        distanceToInstruction: NavigationUtil.calculateDistanceFromPointToEnd(
          snappedLocation,
          closest.coordinates,
        ),
        distanceToEndOfRoute: NavigationUtil.calculateCurrentRouteDistance(
          instructions,
          _currentInstructionIndex,
          coordinates,
        ),
      );
    }
  }

  void dispose() {
    _positionStream?.cancel();
  }
}
