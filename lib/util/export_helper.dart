import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:trailblaze/constants/pubspec.yaml.g.dart';
import 'package:xml/xml.dart' as xml;

class ExportHelper {
  static String generateGpx(List<List<num>> coordinates, List<num> elevation) {
    final builder = xml.XmlBuilder();
    const namespace = 'http://www.topografix.com/GPX/1/1';
    const schema = 'http://www.w3.org/2001/XMLSchema-instance';
    const gpxSchema = 'https://graphhopper.com/public/schema/gpx/1.1';
    builder.namespace(namespace);

    builder.processing('xml', 'version="1.0" encoding="UTF-8" standalone="no"');
    builder.element('gpx', namespaces: {
      namespace: "",
      schema: 'xsi',
      gpxSchema: 'gh',
    }, attributes: {
      'creator': 'Trailblaze',
      'version': version
    }, nest: () {
      builder.element('metadata', nest: () {
        builder.element('copyright',
            attributes: {'author': 'OpenStreetMap contributors'});
        builder.element('link', attributes: {
          'href': 'https://github.com/andreytakhtamirov/trailblaze-flutter'
        }, nest: () {
          builder.element('text', nest: 'Trailblaze GPX');
        });
        builder.element('time', nest: DateTime.now().toUtc().toIso8601String());
      });
      builder.element('trk', nest: () {
        builder.element('name', nest: 'Trailblaze Track');
        builder.element('trkseg', nest: () {
          for (int i = 0; i < coordinates.length; i++) {
            builder.element('trkpt', attributes: {
              'lat': coordinates[i][1].toString(),
              'lon': coordinates[i][0].toString()
            }, nest: () {
              builder.element('ele', nest: elevation[i].toString());
            });
          }
        });
      });
    });

    final gpxDocument = builder.buildDocument();
    return gpxDocument.toXmlString();
  }

  static Future<void> shareGpxFile(
      String gpxContent, String routeName, Rect? position) async {
    try {
      final directory = await getTemporaryDirectory();

      if (!_isCoordinate(routeName)) {
        routeName = _sanitizeFileName(routeName
            .split(',')
            .first); // Only take the first part of the address.

        if (routeName.length > 20) {
          routeName = routeName.substring(0, 20);
        }
      } else {
        routeName = _sanitizeFileName(routeName);
      }

      final date = DateFormat('yyyyMMdd').format(DateTime.now());
      String path =
          '${directory.path}/Route-${routeName.replaceAll(' ', '-')}-$date.gpx';

      File file;
      try {
        file = File(path);
        await file.writeAsString(gpxContent);
      } catch (pathNotFoundException) {
        // Change path to not include destination name (could have bad characters).
        path = '${directory.path}/Route-$date.gpx';
        file = File(path);
        await file.writeAsString(gpxContent);
      }

      await Share.shareXFiles([XFile(path)],
          subject: 'Route to $routeName', sharePositionOrigin: position);
      await file.delete();
    } catch (e) {
      log('Error sharing GPX file: $e');
    }
  }

  static String _sanitizeFileName(String input) {
    final RegExp invalidChars = RegExp(r'[<>:"/\\|?*\x00-\x1F]');
    String sanitized = input.replaceAll(invalidChars, '');
    sanitized = sanitized.trim();
    return sanitized;
  }

  static bool _isCoordinate(String input) {
    final RegExp coordinatePattern =
        RegExp(r'^\(\s*-?\d+(\.\d+)?\s*,\s*-?\d+(\.\d+)?\s*\)$');
    return coordinatePattern.hasMatch(input);
  }
}
