import 'package:geocoding/geocoding.dart';

class GeocodingHelper {
  static Future<String?> addressFromCoordinates(double lat, double lon) async {
    List<Placemark> places = await placemarkFromCoordinates(lat, lon);
    final p = places.firstOrNull;

    if (p == null) {
      return null;
    }

    StringBuffer address = StringBuffer();

    if (p.street != null) {
      address.write(p.street);
    }

    if (p.locality != null) {
      if (address.isNotEmpty) address.write(', ');
      address.write(p.locality);
    }

    if (p.country != null) {
      if (address.isNotEmpty) address.write(', ');
      address.write(p.country);
    }

    return address.isEmpty ? null : address.toString();
  }
}
