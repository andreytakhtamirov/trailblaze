import 'package:fixnum/fixnum.dart';
import 'dart:math' as math;
import 'package:polyline_codec/polyline_codec.dart';

class CoordinatesWithElevation {
  List<List<num>> coordinates = [];
  List<num> elevation = [];

  void addPoint(List<num> coordinate, elevation) {
    coordinates.add(coordinate);
    this.elevation.add(elevation);
  }
}

extension PolylineCodecExtension on PolylineCodec {
  static CoordinatesWithElevation decodeWithElevation(String str,
      {int precision = 5}) {
    final CoordinatesWithElevation coordinatesWithElevation =
        CoordinatesWithElevation();

    var index = 0,
        lat = 0,
        lng = 0,
        elevation = 0,
        shift = 0,
        result = 0,
        factor = math.pow(10, precision);

    int? latitudeChange, longitudeChange, elevationChange, byte;

    // Coordinates have variable length when encoded, so just keep
    // track of whether we've hit the end of the string. In each
    // loop iteration, a single coordinate is decoded.
    while (index < str.length) {
      // Reset shift, result, and byte
      byte = null;
      shift = 0;
      result = 0;

      do {
        byte = str.codeUnitAt(index++) - 63;
        result |= ((Int32(byte) & Int32(0x1f)) << shift).toInt();
        shift += 5;
      } while (byte >= 0x20);

      latitudeChange =
          ((result & 1) != 0 ? ~(Int32(result) >> 1) : (Int32(result) >> 1))
              .toInt();

      shift = result = 0;

      do {
        byte = str.codeUnitAt(index++) - 63;
        result |= ((Int32(byte) & Int32(0x1f)) << shift).toInt();
        shift += 5;
      } while (byte >= 0x20);

      longitudeChange =
          ((result & 1) != 0 ? ~(Int32(result) >> 1) : (Int32(result) >> 1))
              .toInt();

      shift = result = 0;

      do {
        byte = str.codeUnitAt(index++) - 63;
        result |= ((Int32(byte) & Int32(0x1f)) << shift).toInt();
        shift += 5;
      } while (byte >= 0x20);

      elevationChange =
          ((result & 1) != 0 ? ~(Int32(result) >> 1) : (Int32(result) >> 1))
              .toInt();

      lat += latitudeChange;
      lng += longitudeChange;
      elevation += elevationChange;

      coordinatesWithElevation
          .addPoint([lat / factor, lng / factor], elevation/100);
    }

    return coordinatesWithElevation;
  }
}
