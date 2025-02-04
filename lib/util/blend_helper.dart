import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/constants/engine_constants.dart';
import 'package:trailblaze/engine/blend_engine.dart';
import 'package:trailblaze/util/distance_helper.dart';

class BlendHelper {
  final BlendEngine _engine = BlendEngine();

  Future<List<int>> getMinMaxInfluences(
      MapBoxPlace? startingLocation, MapBoxPlace? endingLocation) async {
    final manhattanDistance = DistanceHelper.manhattanDistance(
        DistanceHelper.placeToPoint(startingLocation),
        DistanceHelper.placeToPoint(endingLocation));
    final minDistance = manhattanDistance.toDouble();
    final maxDistance =
        manhattanDistance.toDouble() * kBlendMaxInfluenceDistanceFactor;

    final minInfluence = await _getInfluenceForDistance(
        startingLocation, endingLocation, minDistance);
    final maxInfluence = await _getInfluenceForDistance(
        startingLocation, endingLocation, maxDistance);

    return _verifyInfluenceBounds(minInfluence, maxInfluence);
  }

  Future<int> _getInfluenceForDistance(MapBoxPlace? startingLocation,
      MapBoxPlace? endingLocation, num target) async {
    final euclideanDistance = DistanceHelper.euclideanDistance(
        DistanceHelper.placeToPoint(startingLocation),
        DistanceHelper.placeToPoint(endingLocation));
    final manhattanDistance = DistanceHelper.manhattanDistance(
        DistanceHelper.placeToPoint(startingLocation),
        DistanceHelper.placeToPoint(endingLocation));

    final blendResult =
        _engine.predictForData(euclideanDistance, manhattanDistance, target);

    return blendResult;
  }

  void release() {
    _engine.release();
  }

  List<int> _verifyInfluenceBounds(int minInfluence, int maxInfluence) {
    /*
        The larger the influence, the more direct the path is. A smaller
          influence gives a more "improved" route (includes more detours).

        The maximum has to have a smaller value than the minimum or else there
          is no room to make improvements. This is a work-in-progress model so
           we'll have to double check that the outputs are consistent and don't
           ruin the rest of the routing engine logic.
     */
    if (minInfluence > maxInfluence &&
        minInfluence / 1e3.toInt() < maxInfluence) {
      // Make sure there is room to "speed up" the route,
      // making sure that the new min stays in bounds
      // (not larger than the limit, since bounds are opposite).
      int newMin = maxInfluence * 1e3.toInt();
      if (newMin > kBlendMinInfluence) {
        newMin = kBlendMinInfluence;
      }
      return [newMin, maxInfluence];
    } else if (minInfluence > maxInfluence) {
      return [minInfluence, maxInfluence];
    } else if (minInfluence == maxInfluence) {
      return [minInfluence, maxInfluence ~/ 100];
    }

    return kBlendFallbackInfluences;
  }
}
