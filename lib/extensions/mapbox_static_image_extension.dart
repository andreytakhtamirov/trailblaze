import 'package:mapbox_search/mapbox_search.dart';
import 'package:mapbox_search/models/location.dart';

const String _render2x = "@2x";
const String _empty = "";

extension MapBoxStaticImageExtension on StaticImage {
  Uri getStaticUrlWithPolylineTb({
    required String apiKey,
    required Location point1,
    required Location point2,
    required int width,
    required int height,
    required String style,
    MapBoxPath? path,

    ///rotates the map around its center(from -180 to 180)
    int? bearing,

    ///tilts the map (perspective effect)(from 0 to 60)
    int? pitch,

    ///@2x renders the map at 2x scale
    bool render2x = false,
  }) {
    String pinUrl2 = _buildLabelMarker(MakiIcons.circle.value).toString();

    Uri uri = _buildBaseUri(style);

    uri = uri.replace(path: "${uri.path}/$pinUrl2(${point2.asString}),$path");

    uri = _buildParams(uri,
        height: height, render2x: render2x, width: width, apiKey: apiKey);

    return uri;
  }

  MapBoxMarker _buildLabelMarker(String symbol) {
    return MapBoxMarker(
      markerColor: const Color.rgb(255, 0, 0) as RgbColor,
      markerLetter: symbol,
      markerSize: MarkerSize.LARGE,
    );
  }

  Uri _buildBaseUri(String style) {
    return Uri.parse("https://api.mapbox.com/styles/v1/mapbox/$style/static");
  }

  Uri _buildParams(
    Uri uri, {
    required int width,
    required int height,
    required String apiKey,

    ///@2x renders the map at 2x scale
    required bool render2x,
  }) {
    uri = uri.replace(path: "${uri.path}/auto");
    uri = uri.replace(
        path: "${uri.path}/${width}x$height${render2x ? _render2x : _empty}");
    uri = uri.replace(queryParameters: {"access_token": apiKey});
    return uri;
  }
}

extension MapBoxStyleExtension on MapBoxStyle {
  String get effectiveValue {
    if (this == MapBoxStyle.Outdoors) {
      return "outdoors-v12";
    }
    return value;
  }
}
