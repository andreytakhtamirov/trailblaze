import 'package:flutter/material.dart';

class LoginView extends StatelessWidget {
  final void Function() onLoginPressed;

  const LoginView({super.key, required this.onLoginPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                "Log in to view your profile",
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
            ),
            MaterialButton(
              color: Theme.of(context).colorScheme.tertiary,
              onPressed: onLoginPressed,
              child: const Text('Log in'),
            ),
          ],
        ),
      ),
    );
  }
}
