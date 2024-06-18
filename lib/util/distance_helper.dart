import 'package:turf/turf.dart';

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

  static Point centerToPoint(List<double> center) {
    return Point(coordinates: Position(center[0], center[1]));
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
}
