import 'package:flutter/material.dart';

class UsernameValidity extends StatelessWidget {
  final String? errorMessage;

  const UsernameValidity({
    super.key,
    required this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (errorMessage?.isNotEmpty == true) {
      return Text(
        errorMessage!,
        style: const TextStyle(color: Colors.red),
      );
    } else {
      return const SizedBox();
    }
  }
}
