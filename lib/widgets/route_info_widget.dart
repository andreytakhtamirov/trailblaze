import 'package:flutter/material.dart';
import 'package:mapbox_search/mapbox_search.dart';

class RouteInfo extends StatefulWidget {
  const RouteInfo({Key? key, this.selectedPlace}) : super(key: key);
  final MapBoxPlace? selectedPlace;

  @override
  State<RouteInfo> createState() => _RouteInfoState();
}

class _RouteInfoState extends State<RouteInfo> {
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Route Info",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 300),
                    crossFadeState: _isExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: Column(
                      children: [
                        Row(
                          children: const [
                            Text(
                              "Duration:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              "10 minutes",
                            ),
                          ],
                        ),
                        Row(
                          children: const [
                            Text(
                              "Distance:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              "42km",
                            ),
                          ],
                        ),
                      ],
                    ),
                    secondChild: Column(
                      children: [
                        Row(
                          children: const [
                            Text(
                              "Duration:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              "10 minutes",
                            ),
                          ],
                        ),
                        Row(
                          children: const [
                            Text(
                              "Distance:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Spacer(),
                            Text(
                              "42km",
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            MaterialButton(
                              onPressed: () {},
                              color: Colors.indigo,
                              child: const Text(
                                "Edit",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const Spacer(),
                            MaterialButton(
                              onPressed: () {},
                              color: Colors.red,
                              child: const Text(
                                "Discard",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        MaterialButton(
                          onPressed: () {},
                          color: Colors.green,
                          child: const Text(
                            "Save",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
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
