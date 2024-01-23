import 'package:flutter/material.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'dart:math' as math;

class LoginView extends StatelessWidget {
  final void Function() onLoginPressed;

  const LoginView({super.key, required this.onLoginPressed});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            left: 30,
            bottom: 56,
            child: Transform.rotate(
              angle: math.pi / 180 * 0,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                child: const Icon(
                  Icons.park_outlined,
                  size: 100,
                  color: Color(0xFF2C4925),
                ),
              ),
            ),
          ),
          Positioned(
            left: 50,
            bottom: 50,
            child: Transform.rotate(
              angle: math.pi / 180 * 0,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
                child: const Icon(
                  Icons.park,
                  size: 100,
                  color: Color(0xFF386927),
                ),
              ),
            ),
          ),
          Positioned(
            left: -60,
            bottom: -260,
            child: Column(
              children: [
                Transform.rotate(
                  angle: math.pi / 180 * 10,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()
                      ..scale(-1.0, 1.0, 1.0)
                      ..setTranslationRaw(0, 5, 0),
                    child: Container(
                      height: 72,
                      width: 72,
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.directions_bike_sharp,
                        size: 70,
                        color: Color(0xFFBDCBB8),
                      ),
                    ),
                  ),
                ),
                Transform.rotate(
                  angle: math.pi / 180 * 10,
                  child: Container(
                    height: 300,
                    width: 600,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(400),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -160,
            top: -200,
            child: Transform.rotate(
              angle: math.pi / 180 * 15,
              child: Container(
                height: 300,
                width: 500,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5EFF5),
                  borderRadius: BorderRadius.circular(700),
                ),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 1.0),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: Image(
                        width: kDevicePixelRatio * 50,
                        fit: BoxFit.fill,
                        image: const AssetImage('assets/app_icon.jpg'),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SizedBox(
                    width: 200,
                    child: Text(
                      "Log in to view your profile",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        height: 1.25,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                MaterialButton(
                  color: Theme.of(context).colorScheme.tertiary,
                  onPressed: onLoginPressed,
                  child: const Text(
                    'LOG IN',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 100,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
