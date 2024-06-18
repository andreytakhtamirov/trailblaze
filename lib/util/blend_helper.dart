import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/constants/engine_constants.dart';
import 'package:trailblaze/engine/blend_engine.dart';
import 'package:trailblaze/util/distance_helper.dart';

class BlendHelper {
  final BlendEngine _engine = BlendEngine();

  Future<List<int>> getMinMaxInfluences(
      MapBoxPlace? startingLocation, MapBoxPlace? endingLocation) async {
    final manhattanDistance = DistanceHelper.manhattanDistance(
        DistanceHelper.centerToPoint(
            startingLocation?.center?.cast<double>() ?? [0, 0]),
        DistanceHelper.centerToPoint(
            endingLocation?.center?.cast<double>() ?? [0, 0]));
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
        DistanceHelper.centerToPoint(
            startingLocation?.center?.cast<double>() ?? [0, 0]),
        DistanceHelper.centerToPoint(
            endingLocation?.center?.cast<double>() ?? [0, 0]));
    final manhattanDistance = DistanceHelper.manhattanDistance(
        DistanceHelper.centerToPoint(
            startingLocation?.center?.cast<double>() ?? [0, 0]),
        DistanceHelper.centerToPoint(
            endingLocation?.center?.cast<double>() ?? [0, 0]));

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
    if (minInfluence > maxInfluence) {
      return [minInfluence, maxInfluence];
    } else if (minInfluence == maxInfluence) {
      return [minInfluence, maxInfluence ~/ 100];
    }

    return kBlendFallbackInfluences;
  }
}
