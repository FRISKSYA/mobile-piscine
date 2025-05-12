import 'package:flutter/material.dart';

/// Widget that provides a consistent background image across the entire app
class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background image that covers the entire screen
        Positioned.fill(
          child: Image.asset(
            'assets/images/weather_background.jpg',
            fit: BoxFit.cover,
          ),
        ),
        // The actual content of the page
        child,
      ],
    );
  }
}