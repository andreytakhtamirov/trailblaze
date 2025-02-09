import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trailblaze/data/list_item.dart';
import 'package:trailblaze/managers/navigation_state_notifier.dart';
import 'package:trailblaze/widgets/map_widget.dart';

class RouteDetails extends ConsumerWidget {
  const RouteDetails({
    Key? key,
    required this.item,
  }) : super(key: key);

  final Item item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isNavigating = ref.watch(isNavigationModeOnProvider);

    return Scaffold(
      appBar: isNavigating
          ? null
          : AppBar(
              title: Text(item.title),
            ),
      body: MapWidget(
        forceTopBottomPadding: !isNavigating,
        isInteractiveMap: false,
        routeToDisplay: item.route,
      ),
      bottomNavigationBar: const SafeArea(child: SizedBox()),
    );
  }
}
