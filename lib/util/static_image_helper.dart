import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/extensions/iterable_extension.dart';
import 'package:trailblaze/extensions/mapbox_static_image_extension.dart';

class StaticImageHelper {
  static Uri staticImageFromPolyline(
    String mbApiKey,
    double lat1,
    double lng1,
    double lat2,
    double lng2,
    String polyline,
  ) {
    StaticImage staticImage = StaticImage(
      apiKey: mbApiKey,
    );

    MapBoxPath path = MapBoxPath(
      pathColor: const RgbColor(255, 0, 0),
      pathWidth: 5,
      pathPolyline: Uri.encodeComponent(polyline),
      pathOpacity: 1.0,
    );

    return staticImage.getStaticUrlWithPolylineWithoutPoints(
      path: path,
      style: kMapStyleOutdoors,
    );
  }

  static List<List<num>> sampleCoordinates(List<List<dynamic>> coordinates) {
    int x = (coordinates.length / 500).ceil();
    final List<List<num>> sampledCoordinates = coordinates
        .whereIndexed((index, c) => index % x == 0)
        .map((c) => [c[1] as num, c[0] as num])
        .toList();

    return sampledCoordinates;
  }
}
