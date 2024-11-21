import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:mapbox_search/mapbox_search.dart';
import 'package:turf/turf.dart';
import 'dart:math' as math;

class DistanceHelper {
  static num manhattanDistance(Point coordinate1, Point coordinate2) {
    Point coordinate3 = Point(
        coordinates:
            Position(coordinate1.coordinates.lng, coordinate2.coordinates.lat));
    return distance(coordinate1, coordinate3, Unit.meters) +
        distance(coordinate2, coordinate3, Unit.meters);
  }

  static num euclideanDistance(Point coordinate1, Point coordinate2) {
    return distance(coordinate1, coordinate2, Unit.meters);
  }

  static Point placeToPoint(MapBoxPlace? place) {
    return Point(
        coordinates:
            Position(place?.center?.long ?? 0, place?.center?.lat ?? 0));
  }

  static Position _computeCentroid(List<Position> points) {
    double sumLng = 0;
    double sumLat = 0;

    for (var point in points) {
      sumLng += point.lng;
      sumLat += point.lat;
    }

    return Position(sumLng / points.length, sumLat / points.length);
  }

  static num _angleFromCentroid(Position point, Position centroid) {
    return bearing(Point(coordinates: centroid), Point(coordinates: point));
  }

  static List<Position> _sortPoints(List<Position> points) {
    Position centroid = _computeCentroid(points);
    points.sort((a, b) => _angleFromCentroid(a, centroid)
        .compareTo(_angleFromCentroid(b, centroid)));
    return points;
  }

  static List<Position> buildPolygon(List<Position> points) {
    if (points.isEmpty) {
      return [];
    }
    final polygon = _sortPoints(points);
    polygon.add(polygon.first); // Add first point again to close polygon.
    return polygon;
  }

  static double calculatePixelDistance(
      mbm.ScreenCoordinate pixel1, mbm.ScreenCoordinate pixel2) {
    final dx = pixel1.x - pixel2.x;
    final dy = pixel1.y - pixel2.y;
    return math.sqrt(dx * dx + dy * dy);
  }

  static double truncateCoordinate(double value) {
    // 3 decimal places equals roughly 111m of precision
    return double.parse(value.toStringAsFixed(3));
  }

  static bool isValidCoordinate(double latitude, double longitude) {
    return latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }
}
