import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mbm;
import 'package:mapbox_search/mapbox_search.dart';
import 'package:trailblaze/util/distance_helper.dart';
import 'package:trailblaze/util/format_helper.dart';

class PlaceInfoPanel extends StatefulWidget {
  const PlaceInfoPanel({
    Key? key,
    this.selectedPlace,
    this.userLocation,
  }) : super(key: key);
  final MapBoxPlace? selectedPlace;
  final mbm.Position? userLocation;

  @override
  State<PlaceInfoPanel> createState() => _PlaceInfoPanelState();
}

class _PlaceInfoPanelState extends State<PlaceInfoPanel> {
  num? _getDistanceMeters() {
    if (widget.userLocation == null ||
        widget.selectedPlace == null ||
        widget.selectedPlace!.center == null) {
      return null;
    }

    return DistanceHelper.euclideanDistance(
        mbm.Point(
            coordinates: mbm.Position(widget.selectedPlace?.center?[0] ?? 0,
                widget.selectedPlace?.center?[1] ?? 0)),
        mbm.Point(
          coordinates: widget.userLocation!,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 0, 16, 0),
          child: Column(
            children: [
              if (widget.selectedPlace?.placeName != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Image(
                          width: 32,
                          fit: BoxFit.fill,
                          image: AssetImage('assets/location-pin.png'),
                        ),
                        const Spacer(),
                        Expanded(
                          flex: 11,
                          child: Text(
                            widget.selectedPlace!.placeName!,
                            maxLines: 5,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 6,
                          child: Text(
                            FormatHelper.formatDistance(_getDistanceMeters()),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              else
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: SizedBox(
                    height: 50,
                    width: 50,
                    child: CircularProgressIndicator(),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Coordinates: (${widget.selectedPlace?.center?[1].toStringAsFixed(6)}, ${widget.selectedPlace?.center?[0].toStringAsFixed(6)})",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
