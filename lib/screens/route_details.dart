import 'package:flutter/material.dart';
import 'package:trailblaze/data/list_item.dart';
import 'package:trailblaze/widgets/map_widget.dart';

class RouteDetails extends StatelessWidget {
  const RouteDetails({
    Key? key,
    required this.item,
  }) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
      ),
      body: SafeArea(
        child: MapWidget(
          forceTopBottomPadding: true,
          isInteractiveMap: false,
          routeToDisplay: item.route,
        ),
      ),
    );
  }
}
