import 'dart:math';

import 'package:trailblaze/data/instruction.dart';
import 'package:turf/distance.dart';
import 'package:turf/helpers.dart';

class NavigationUtil {
  static num? calculateDistanceToInstruction(
      Position position, Instruction instruction,
      {required bool includeTolerance}) {
    // If a user has gone off course, we'll guide them back
    // to the last matched point (exactly, without tolerance).
    final double baseToleranceMeters = includeTolerance ? 20 : 10;

    final userPoint = Point(coordinates: Position(position.lng, position.lat));
    final lineCoordinates = instruction.coordinates;

    num calculatePointToLineDistance(Point point, List<Position> line) {
      num minDistance = double.infinity;

      for (int i = 0; i < line.length - 1; i++) {
        final start = Point(coordinates: line[i]);
        final end = Point(coordinates: line[i + 1]);

        // Calculate the distance from the point to the segment
        num segmentDistance = _pointToSegmentDistance(point, start, end);
        if (segmentDistance < minDistance) {
          minDistance = segmentDistance;
        }
      }

      return minDistance;
    }

    final distanceMeters =
        calculatePointToLineDistance(userPoint, lineCoordinates);

    return distanceMeters <= baseToleranceMeters ? distanceMeters : null;
  }

  static Position? snapToRoute(
      Position userPosition, Instruction? instruction) {
    final lineCoordinates = instruction?.coordinates;

    Position? findClosestPointOnLine(
        Position userPosition, List<Position> line) {
      Position? closestPoint;
      num minDistance = double.infinity;

      for (int i = 0; i < line.length - 1; i++) {
        final segmentStart = line[i];
        final segmentEnd = line[i + 1];

        // Compute the closest point along the segment
        final projectedPoint =
            _projectPointOnSegment(userPosition, segmentStart, segmentEnd);

        // Compute the distance to the projected point
        final distanceToProjected = distance(
          Point(coordinates: Position(userPosition.lng, userPosition.lat)),
          Point(coordinates: Position(projectedPoint.lng, projectedPoint.lat)),
          Unit.meters,
        );

        if (distanceToProjected < minDistance) {
          minDistance = distanceToProjected;
          closestPoint = projectedPoint;
        }
      }

      return closestPoint;
    }

    return lineCoordinates != null
        ? findClosestPointOnLine(userPosition, lineCoordinates)
        : null;
  }

  static double calculateCurrentRouteDistance(List<Instruction>? instructions,
      int? currentInstructionIndex, Position? point) {
    if (instructions == null ||
        instructions.isEmpty ||
        currentInstructionIndex == null ||
        point == null) {
      return 0;
    }

    final List<Position> allCoordinates = instructionsToPositions(instructions,
        minIndex: currentInstructionIndex);
    return calculateDistanceFromPointToEnd(point, allCoordinates);
  }

  static double calculateDistanceFromPointToEnd(
      Position point, List<Position> line) {
    double totalDistance = 0;

    if (line.isEmpty) {
      return totalDistance;
    }

    final index = _segmentIndexForPoint(point, line);

    // Calculate distance from the point to the end of its segment
    final segmentStart = line[index];
    final segmentEnd = line[index + 1];
    final projectedPoint =
        _projectPointOnSegment(point, segmentStart, segmentEnd);

    totalDistance +=
        _calculateDistanceBetweenPoints(projectedPoint, segmentEnd);

    // Add distances of all subsequent segments
    for (int i = index + 1; i < line.length - 1; i++) {
      totalDistance += _calculateDistanceBetweenPoints(line[i], line[i + 1]);
    }

    return totalDistance;
  }

  static List<List<num>> getCoordsFromPointToStart(
      Position point, int? instructionIndex, List<Instruction>? instructions) {
    final List<Position> positions = [];

    if (instructions == null ||
        instructions.isEmpty ||
        instructionIndex == null) {
      return [];
    }

    final List<Position> line =
        instructionsToPositions(instructions, maxIndex: instructionIndex + 1);

    final segmentIndex = _segmentIndexForPoint(point, line);
    final segmentStart = line[segmentIndex];
    final segmentEnd = line[segmentIndex + 1];
    final projectedPoint =
        _projectPointOnSegment(point, segmentStart, segmentEnd);
    positions.add(projectedPoint);

    // Add all preceding positions from the segment start back to the start of the route
    for (int i = segmentIndex + 1; i > 0; i--) {
      positions.add(line[i - 1]);
    }

    return positionsToList(positions);
  }

  static num _pointToSegmentDistance(
      Point point, Point segmentStart, Point segmentEnd) {
    final p = point.coordinates;
    final a = segmentStart.coordinates;
    final b = segmentEnd.coordinates;

    final px = p.lng;
    final py = p.lat;
    final ax = a.lng;
    final ay = a.lat;
    final bx = b.lng;
    final by = b.lat;

    // Vector AB
    final abx = bx - ax;
    final aby = by - ay;

    // Vector AP
    final apx = px - ax;
    final apy = py - ay;

    // Projection factor
    final abSquared = abx * abx + aby * aby;
    final t = (apx * abx + apy * aby) / (abSquared != 0 ? abSquared : 1);

    // Closest point on segment
    if (t < 0) {
      // Closest to start of the segment
      return distance(Point(coordinates: Position(ax, ay)), point, Unit.meters);
    } else if (t > 1) {
      // Closest to end of the segment
      return distance(Point(coordinates: Position(bx, by)), point, Unit.meters);
    } else {
      // Closest to the segment
      final projx = ax + t * abx;
      final projy = ay + t * aby;
      return distance(
          Point(coordinates: Position(projx, projy)), point, Unit.meters);
    }
  }

  static Position _projectPointOnSegment(Position p, Position a, Position b) {
    final px = p.lng, py = p.lat;
    final ax = a.lng, ay = a.lat;
    final bx = b.lng, by = b.lat;

    final abx = bx - ax, aby = by - ay;
    final apx = px - ax, apy = py - ay;

    // Projection factor: t determines how far along the segment the projection lies
    final abSquared = abx * abx + aby * aby;
    final t = (apx * abx + apy * aby) / (abSquared != 0 ? abSquared : 1);

    if (t < 0) {
      // Closest to the start of the segment
      return a;
    } else if (t > 1) {
      // Closest to the end of the segment
      return b;
    } else {
      // Projection lies on the segment
      final projLng = ax + t * abx;
      final projLat = ay + t * aby;
      return Position(projLng, projLat);
    }
  }

  static num _calculateDistanceBetweenPoints(Position p1, Position p2) {
    return distance(
      Point(coordinates: Position(p1.lng, p1.lat)),
      Point(coordinates: Position(p2.lng, p2.lat)),
      Unit.meters,
    );
  }

  static int _segmentIndexForPoint(Position point, List<Position> coordinates) {
    num minDistance = double.infinity;
    int minSegment = 0;

    for (int i = 0; i < coordinates.length - 1; i++) {
      final start = Point(coordinates: coordinates[i]);
      final end = Point(coordinates: coordinates[i + 1]);

      // Calculate the distance from the point to the segment
      num segmentDistance =
          _pointToSegmentDistance(Point(coordinates: point), start, end);
      if (segmentDistance < minDistance) {
        minDistance = segmentDistance;
        minSegment = i;
      }
    }

    return minSegment;
  }

  static List<Position> instructionsToPositions(List<Instruction> instructions,
      {int minIndex = 0, int? maxIndex}) {
    final List<Position> allCoordinates = [];

    maxIndex ??= instructions.length;

    for (int i = minIndex; i < maxIndex; i++) {
      allCoordinates.addAll(instructions[i].coordinates);
    }

    return allCoordinates;
  }

  static List<List<num>> positionsToList(List<Position> positions) {
    final coordinates = positions.map((position) {
      return [position.lng, position.lat];
    }).toList();

    return coordinates;
  }

  static double calculateBearing(
      Position currentPosition, Position targetPosition) {
    final lat1 = currentPosition.lat * pi / 180.0;
    final lon1 = currentPosition.lng * pi / 180.0;
    final lat2 = targetPosition.lat * pi / 180.0;
    final lon2 = targetPosition.lng * pi / 180.0;

    final dLon = lon2 - lon1;

    // Calculate the bearing
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    final bearing = atan2(y, x);

    return (bearing * 180.0 / pi + 360.0) % 360.0;
  }

  static double calculateTurnAngle(
      double currentBearing, double targetBearing) {
    final turnAngle = (targetBearing - currentBearing + 360) % 360;
    return turnAngle <= 180 ? turnAngle : turnAngle - 360;
  }
}
