import 'dart:async';
import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:trailblaze/constants/navigation_constants.dart';
import 'package:trailblaze/data/instruction.dart';
import 'package:trailblaze/managers/navigation_state_notifier.dart';
import 'package:trailblaze/util/distance_helper.dart';
import 'package:trailblaze/util/navigation_util.dart';
import 'package:turf/turf.dart' as turf;

class NavigationService {
  StreamSubscription<Position>? _positionStream;
  turf.Position? _lastSnappedLocation;
  Position? _lastPosition;
  int? _lastInstructionIndex;

  void initializeLocationStream(
    NavigationStateNotifier notifier,
    List<Instruction>? instructions,
  ) {
    _positionStream = Geolocator.getPositionStream(
            locationSettings: kNavigationLocationSettings)
        .listen((Position? position) {
      if (position != null && instructions != null) {
        Position? pos = position;
        if (Platform.isAndroid && _lastPosition != null) {
          // FollowPuckViewportStateBearingCourse doesn't support Android.
          // We can calculate a heading by comparing the current position to
          // the one before.
          final bearing = Geolocator.bearingBetween(_lastPosition!.latitude,
              _lastPosition!.longitude, position.latitude, position.longitude);
          pos = Position(
            accuracy: position.accuracy,
            longitude: position.longitude,
            latitude: position.latitude,
            timestamp: position.timestamp,
            altitude: position.altitude,
            altitudeAccuracy: position.altitudeAccuracy,
            heading: bearing,
            headingAccuracy: position.headingAccuracy,
            speed: position.speed,
            speedAccuracy: position.speedAccuracy,
            floor: position.floor,
            isMocked: position.isMocked,
          );
        }

        _calculateLocation(pos, notifier, instructions);
      }
    });
  }

  void _calculateLocation(
    Position position,
    NavigationStateNotifier notifier,
    List<Instruction> instructions,
  ) {
    Instruction? closest;
    int? closestIndex;
    num? minDistance;
    final coordinates = turf.Position(position.longitude, position.latitude);
    final bool userCurrentlyOnRoute = _lastInstructionIndex != kInvalidInstruction;

    if (Platform.isAndroid) {
      _lastPosition = position;
    }

    for (int i = 0; i < instructions.length; i++) {
      final instruction = instructions[i];
      final distance = NavigationUtil.calculateDistanceToInstruction(
        coordinates,
        instruction,
        includeTolerance: userCurrentlyOnRoute,
      );

      if (distance != null) {
        if (minDistance == null || distance < minDistance) {
          minDistance = distance;
          closest = instruction;
          closestIndex = i;
        }
      }
    }

    final currentInstruction =
        closestIndex != null ? instructions[closestIndex] : null;

    // Attempt to match the user's location to a point along the current instruction.
    // If no match is found, the snapped location will be null, and will not override
    // the last matched snappedLocation.
    final snappedLocation =
        NavigationUtil.snapToRoute(coordinates, currentInstruction);

    notifier.updatePosition(
      position,
      snappedLocation,
      closestIndex ?? kInvalidInstruction,
    );

    _lastInstructionIndex = closestIndex ?? kInvalidInstruction;

    if (snappedLocation != null && closest != null && closestIndex != null) {
      _lastSnappedLocation = snappedLocation;

      notifier.updateDistances(
        distanceToInstruction: NavigationUtil.calculateDistanceFromPointToEnd(
          snappedLocation,
          closest.coordinates,
        ),
        distanceToEndOfRoute: NavigationUtil.calculateCurrentRouteDistance(
          instructions,
          closestIndex,
          snappedLocation,
        ),
        directionToRoute: kInvalidBearing,
      );
    } else {
      if (_lastSnappedLocation == null) {
        // User has never travelled along the route.
        // We should guide them to the first point on the first instruction.
        final point = instructions.firstOrNull?.coordinates.firstOrNull;
        if (point == null) {
          // Route doesn't have any instructions or instruction has no points.
          return;
        }

        final turfPos = turf.Position(position.longitude, position.latitude);
        final bearing = NavigationUtil.calculateBearing(turfPos, point);
        final turnAngle =
            NavigationUtil.calculateTurnAngle(position.heading, bearing);
        final distance = DistanceHelper.euclideanDistance(
            turf.Point(coordinates: turfPos),
            turf.Point(
              coordinates: turf.Position(point.lng, point.lat),
            ));

        notifier.updateDistances(
          distanceToInstruction: distance,
          distanceToEndOfRoute: NavigationUtil.calculateCurrentRouteDistance(
                instructions,
                closestIndex,
                point,
              ) +
              distance,
          directionToRoute: turnAngle,
        );

        return;
      }

      final turfPos = turf.Position(position.longitude, position.latitude);
      final bearing =
          NavigationUtil.calculateBearing(turfPos, _lastSnappedLocation!);
      final turnAngle =
          NavigationUtil.calculateTurnAngle(position.heading, bearing);
      final distance = DistanceHelper.euclideanDistance(
          turf.Point(coordinates: turfPos),
          turf.Point(
            coordinates: turf.Position(
                _lastSnappedLocation!.lng, _lastSnappedLocation!.lat),
          ));

      notifier.updateDistances(
        distanceToInstruction: distance,
        distanceToEndOfRoute: NavigationUtil.calculateCurrentRouteDistance(
              instructions,
              closestIndex,
              _lastSnappedLocation,
            ) +
            distance,
        directionToRoute: turnAngle,
      );
    }
  }

  void dispose() {
    _positionStream?.cancel();
  }
}
