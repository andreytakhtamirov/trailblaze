import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';

class PlaceInfo extends StatefulWidget {
  const PlaceInfo(
      {Key? key, this.selectedPlace, required this.onDirectionsClicked})
      : super(key: key);
  final MapBoxPlace? selectedPlace;
  final void Function(MapBoxPlace place) onDirectionsClicked;

  @override
  State<PlaceInfo> createState() => _PlaceInfoState();
}

class _PlaceInfoState extends State<PlaceInfo> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              offset: const Offset(0, 3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.selectedPlace?.placeName != null)
                    Text(
                      widget.selectedPlace!.placeName!,
                      maxLines: _isExpanded ? 5 : 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    Row(
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(6),
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    ),
                  const SizedBox(height: 16),
                  MaterialButton(
                    onPressed: () {
                      if (widget.selectedPlace != null) {
                        widget.onDirectionsClicked(widget.selectedPlace!);
                      }
                    },
                    color: Colors.indigo,
                    child: const Text(
                      "Directions",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
