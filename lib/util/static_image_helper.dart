import 'package:mapbox_search/colors/color.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/constants/map_constants.dart';
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
}
