import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trailblaze/data/search_feature_type.dart';
import 'package:trailblaze/extensions/mapbox_search_extension.dart';
import 'package:trailblaze/util/format_helper.dart';

class SearchItemHelper {
  static Widget iconForFeatureType(SearchFeatureType type) {
    switch (type) {
      case SearchFeatureType.category:
        return Icon(
          Icons.search,
          color: Colors.blue.shade900,
        );
      case SearchFeatureType.poi:
        return const Icon(
          Icons.location_on_outlined,
        );
      case SearchFeatureType.address:
        return const Icon(
          Icons.home,
        );
      case SearchFeatureType.place:
        return const Icon(
          Icons.location_city_rounded,
        );
      case SearchFeatureType.neighborhood:
        return const Icon(
          Icons.home_work_outlined,
        );
      case SearchFeatureType.history:
        return const Icon(
          Icons.history,
        );
      default:
        return const Icon(
          Icons.question_mark,
        );
    }
  }

  static Widget titleForFeatureType(SuggestionTb s) {
    final type = getFeatureTypeFromString(s.featureType);
    final label = titleLabelForFeatureType(s);
    switch (type) {
      case SearchFeatureType.category:
        return Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 16,
            color: Colors.blue.shade900,
          ),
        );
      case SearchFeatureType.history:
      case SearchFeatureType.place:
      case SearchFeatureType.neighborhood:
      case SearchFeatureType.poi:
      case SearchFeatureType.address:
      default:
        return Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
          ),
        );
    }
  }

  static String titleLabelForFeatureType(SuggestionTb s) {
    final type = getFeatureTypeFromString(s.featureType);
    switch (type) {
      case SearchFeatureType.category:
      case SearchFeatureType.history:
      case SearchFeatureType.place:
      case SearchFeatureType.neighborhood:
      case SearchFeatureType.poi:
      case SearchFeatureType.address:
      default:
        return s.name;
    }
  }

    static Widget subtitleForFeatureType(SuggestionTb s) {
    final type = getFeatureTypeFromString(s.featureType);
    if (type == SearchFeatureType.category) {
      return Text(
        'Click to see nearby',
        style: TextStyle(
          color: Colors.blue.shade800,
          decoration: TextDecoration.underline,
          decorationColor: Colors.blue.shade800,
          fontSize: 12,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      );
    }
    return Text(
      subtitleLabelForFeatureType(s),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        fontSize: 12,
      ),
    );
  }

  static String subtitleLabelForFeatureType(SuggestionTb s) {
    final type = getFeatureTypeFromString(s.featureType);
    final String label;
    switch (type) {
      case SearchFeatureType.history:
      case SearchFeatureType.place:
      case SearchFeatureType.address:
      case SearchFeatureType.neighborhood:
        label = s.placeFormatted;
        break;
      case SearchFeatureType.poi:
      default:
        label = "${s.address}, ${s.placeFormatted}";
    }

    return label;
  }

  static Widget suffixForFeatureType(Position? location, SuggestionTb s) {
    final type = getFeatureTypeFromString(s.featureType);
    final Widget distance;
    if (location != null && s.distance != null) {
      distance = Text(
        FormatHelper.formatDistance(
          s.distance,
          noRemainder: true,
        ),
      );
    } else {
      distance = const SizedBox();
    }

    switch (type) {
      case SearchFeatureType.category:
        return Icon(
          Icons.open_in_new,
          color: Colors.blue.shade800,
        );
      default:
        return distance;
    }
  }
}
