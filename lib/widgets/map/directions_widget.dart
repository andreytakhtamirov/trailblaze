import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trailblaze/data/instruction.dart';
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/managers/navigation_state_notifier.dart';
import 'package:trailblaze/services/navigation_service.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:trailblaze/widgets/animated/animated_icon.dart';

class DirectionsWidget extends ConsumerStatefulWidget {
  const DirectionsWidget(this.route, {super.key});

  final TrailblazeRoute route;

  @override
  ConsumerState<DirectionsWidget> createState() => _DirectionsWidgetState();
}

class _DirectionsWidgetState extends ConsumerState<DirectionsWidget> {
  late final List<Instruction>? _instructions = widget.route.instructions;
  final NavigationService _navigationService = NavigationService();

  final kAnimationDuration = const Duration(milliseconds: 300);
  Curve kAnimationCurve = Curves.easeInOut;
  final double kDirectionArrowMaxSize = 104;
  final double kDirectionArrowMinSize = 54;
  final double kDirectionsDistanceMaxSize = 40;
  final double kDirectionsDistanceMinSize = 20;

  @override
  initState() {
    super.initState();
    final notifier = ref.read(navigationStateProvider.notifier);
    _navigationService.initializeLocationStream(
        notifier, widget.route.instructions);
  }

  @override
  void dispose() {
    _navigationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currIndex =
        ref.watch(navigationStateProvider).currentInstructionIndex ?? 0;

    final nextInstruction =
        (currIndex >= 0 && currIndex + 1 < (_instructions?.length ?? 0))
            ? _instructions![currIndex + 1]
            : null;

    final distanceToNext =
        ref.watch(navigationStateProvider).distanceToInstruction;
    final directionToRoute =
        ref.watch(navigationStateProvider).directionToRoute;

    return Column(
      children: [
        AnimatedContainer(
          duration: kAnimationDuration,
          curve: kAnimationCurve,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: instructionView(
                nextInstruction, distanceToNext, directionToRoute),
          ),
        ),
      ],
    );
  }

  Widget instructionView(
      Instruction? instruction, num? distanceToNext, num? directionToRoute) {
    final IconData icon;
    final num? distance;
    final String instructionLabel;
    final String instructionStreet;
    double? arrowBearing;
    bool isOffCourse = false;

    if (instruction != null) {
      icon = instruction.sign.icon;
      distance = distanceToNext;
      instructionLabel = instruction.text;
      instructionStreet = instruction.streetName;
    } else {
      icon = Icons.arrow_upward_rounded;
      distance = distanceToNext;
      instructionLabel = "Get back on track";
      instructionStreet = "Follow the direction of the arrow";
      arrowBearing = (directionToRoute ?? 0).toDouble() * math.pi / 180;
      isOffCourse = true;
    }

    final double iconSize =
        isOffCourse ? kDirectionArrowMaxSize : kDirectionArrowMinSize;
    final double fontSize =
        isOffCourse ? kDirectionsDistanceMaxSize : kDirectionsDistanceMinSize;

    return Row(
      children: [
        Expanded(
          flex: !isOffCourse ? 2 : 3,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 8, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.rotate(
                    angle: arrowBearing ?? 0,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: SizeAnimatedIcon(
                        icon: icon,
                        iconColor: Colors.white,
                        minSize: kDirectionArrowMinSize,
                        maxSize: kDirectionArrowMaxSize,
                        size: iconSize,
                        duration: kAnimationDuration,
                        curve: kAnimationCurve,
                      ),
                    )),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: kAnimationDuration,
                  curve: kAnimationCurve,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      maxLines: 1,
                      FormatHelper.formatDistancePrecise(distance),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  instructionLabel,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  instructionStreet,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
