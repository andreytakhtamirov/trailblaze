class CoordinateHelper {
  static final RegExp _kDegreesDirectionRegex =
      RegExp(r'(\d+(\.\d+)?)°\s?([NS])\s?(\d+(\.\d+)?)°\s?([EW])');
  static final RegExp _kDecimalDegreesRegex =
      RegExp(r'^-?\d+(\.\d+)?,\s?-?\d+(\.\d+)?$');

  static String _cleanForDecimalDegrees(String input) {
    // Make sure coordinates are split by comma
    input = !input.contains(',') ? input.replaceFirst(' ', ',') : input;
    input = input.replaceAll(RegExp(r'[()]'), ''); // Remove parentheses
    return input;
  }

  static String _cleanForDegreesDirection(String input) {
    // Remove comma
    input = input.contains(',') ? input.replaceFirst(',', '') : input;
    return input;
  }

  static List<double> stringToDecimalDegrees(String input) {
    if (!_kDecimalDegreesRegex.hasMatch(_cleanForDecimalDegrees(input))) {
      return [-1, -1];
    }

    final coordinates = _cleanForDecimalDegrees(input).split(',');
    final latitude = double.tryParse(coordinates[0].trim());
    final longitude = double.tryParse(coordinates[1].trim());
    return [latitude ?? -1, longitude ?? -1];
  }

  static List<double> stringToDegreesDirection(String input) {
    final match =
        _kDegreesDirectionRegex.firstMatch(_cleanForDegreesDirection(input));
    if (match == null) {
      return [-1, -1];
    }

    double latitude = double.parse(match.group(1)!);
    String latDirection = match.group(3)!;
    double longitude = double.parse(match.group(4)!);
    String lonDirection = match.group(6)!;

    if (latDirection == 'S') latitude = -latitude;
    if (lonDirection == 'W') longitude = -longitude;

    return [latitude, longitude];
  }
}
