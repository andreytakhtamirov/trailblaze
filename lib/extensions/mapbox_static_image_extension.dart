import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/constants/request_api_constants.dart';

extension MapBoxStaticImageExtension on StaticImage {
  Uri _buildBaseUri({String? style}) {
    return Uri.parse(
        "https://api.mapbox.com/styles/v1/mapbox/${(style ?? kMapStyleOutdoors)}/static");
  }

  Uri _buildParams(
    Uri uri, {
    int? width,
    int? height,
  }) {
    uri = uri.replace(path: "${uri.path}/auto");
    uri = uri.replace(
        path:
            "${uri.path}/${width ?? kStaticMapWidth}x${height ?? kStaticMapHeight}");
    uri = uri.replace(queryParameters: {"access_token": apiKey});

    return uri;
  }

  Uri getStaticUrlWithPolylineWithoutPoints({
    num? zoomLevel,
    int? width,
    int? height,
    String? style,
    MapBoxPath? path,
  }) {
    Uri uri = _buildBaseUri(style: style);
    uri = uri.replace(path: "${uri.path}/$path");

    uri = _buildParams(
      uri,
      height: height,
      width: width,
    );

    return uri;
  }
}
