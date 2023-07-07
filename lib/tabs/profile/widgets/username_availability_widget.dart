import 'package:flutter/material.dart';

class UsernameAvailability extends StatelessWidget {
  final Future<bool>? futureAvailability;
  final bool bypassVerification;

  const UsernameAvailability({
    super.key,
    required this.futureAvailability,
    this.bypassVerification = false,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: futureAvailability,
      builder: (context, snapshot) {
        if (bypassVerification) {
          return const SizedBox();
        }

        if (snapshot.connectionState == ConnectionState.waiting ||
            futureAvailability == null) {
          return const SizedBox(
            height: 24,
            width: 24,
            child: CircularProgressIndicator(
              strokeWidth: 3,
            ),
          );
        } else if (snapshot.hasData) {
          final isAvailable = snapshot.data!;
          final availabilityColor = isAvailable ? Colors.green : Colors.red;
          const availableIcon = Icons.check_circle_rounded;
          const notAvailableText = "Not Available";

          if (isAvailable) {
            return Icon(
              availableIcon,
              color: availabilityColor,
            );
          } else {
            return Text(
              notAvailableText,
              style: TextStyle(color: availabilityColor),
            );
          }
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
