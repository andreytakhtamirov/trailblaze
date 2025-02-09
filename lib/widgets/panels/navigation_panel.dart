import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trailblaze/data/instruction.dart';
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/managers/navigation_state_notifier.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:trailblaze/widgets/map/icon_button_small.dart';
import 'package:turf/turf.dart' as turf;

class NavigationPanel extends ConsumerWidget {
  const NavigationPanel({
    Key? key,
    required this.panelPos,
    required this.scrollController,
    required this.route,
    required this.onExit,
    required this.onSelectInstruction,
  }) : super(key: key);

  final double panelPos;
  final ScrollController scrollController;
  final TrailblazeRoute? route;
  final Function() onExit;
  final Function(Instruction instruction) onSelectInstruction;

  Widget routePreview(
      int? currentInstruction, turf.Position? position, num? distanceToEnd) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                FormatHelper.formatDistancePrecise(distanceToEnd),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // TODO calculate time from distance
              // Text(
              //   FormatHelper.formatDuration(route?.duration),
              //   style: const TextStyle(
              //     fontSize: 14,
              //     fontWeight: FontWeight.w400,
              //   ),
              // ),
            ],
          ),
          IconButtonSmall(
            icon: Icons.close_rounded,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            iconFontSize: 32,
            onTap: onExit,
          ),
        ],
      ),
    );
  }

  Widget instructionsList() {
    return ListView.builder(
      clipBehavior: Clip.antiAlias,
      controller: scrollController,
      padding: const EdgeInsets.only(top: 80),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: route?.instructions?.length,
      itemBuilder: (BuildContext context, int index) {
        final instruction = route?.instructions![index];
        return Column(
          children: [
            instructionItem(instruction),
            if (index < (route?.instructions!.length ?? 1) - 1)
              // Separator with distance
              Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.white,
                child: Row(
                  children: [
                    const Expanded(
                      flex: 3,
                      child: SizedBox(),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text(
                        textAlign: TextAlign.start,
                        FormatHelper.formatDistancePrecise(
                            instruction?.distance),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 7,
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey.withValues(alpha: 0.4)),
                        height: 2,
                      ),
                    )
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget instructionItem(Instruction? instruction) {
    return InkWell(
      onTap: () => onSelectInstruction(instruction!),
      child: Container(
        decoration: const BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          children: [
            Row(
              children: [
                // Icon and Distance
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Icon(
                        instruction?.sign.icon,
                        size: 34,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          instruction?.text ?? "",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          instruction?.streetName ?? "",
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(navigationStateProvider);
    final currentInstruction = notifier.currentInstructionIndex;
    final location = notifier.snappedLocation;
    final distanceToEnd = notifier.distanceToEndOfRoute;

    return panelPos > 0.5
        ? Expanded(
            child: Container(
              color: Colors.grey.shade100,
              child: Stack(
                children: [
                  // The scrollable ListView
                  Positioned.fill(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: instructionsList(),
                    ),
                  ),

                  // The floating widget
                  Positioned(
                    top: 0, // Position at the top of the ListView
                    left: 0,
                    right: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.7),
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                      ),
                      child: ClipRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 4.0, sigmaY: 4.0),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: routePreview(
                                currentInstruction, location, distanceToEnd),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: routePreview(currentInstruction, location, distanceToEnd),
          );
  }
}
