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
}
