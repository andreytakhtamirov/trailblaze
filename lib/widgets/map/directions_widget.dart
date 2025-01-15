import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:trailblaze/data/instruction.dart';
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/managers/navigation_state_notifier.dart';
import 'package:trailblaze/services/navigation_service.dart';
import 'package:trailblaze/util/format_helper.dart';

class DirectionsWidget extends ConsumerStatefulWidget {
  const DirectionsWidget(this.route, {super.key});

  final TrailblazeRoute route;

  @override
  ConsumerState<DirectionsWidget> createState() => _DirectionsWidgetState();
}

class _DirectionsWidgetState extends ConsumerState<DirectionsWidget> {
  late final List<Instruction>? _instructions = widget.route.instructions;
  final NavigationService _navigationService = NavigationService();

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
    final nextInstruction = (currIndex + 1 < (_instructions?.length ?? 0))
        ? _instructions![currIndex + 1]
        : null;

    final distanceToNext =
        ref.watch(navigationStateProvider).distanceToInstruction;

    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(
            milliseconds: 300,
          ),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Icon(
                        nextInstruction?.sign.icon,
                        size: 54,
                        color: Colors.white,
                      ),
                      Text(
                        FormatHelper.formatDistancePrecise(distanceToNext),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nextInstruction?.text ?? "",
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        nextInstruction?.streetName ?? "",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
