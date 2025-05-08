import 'package:flutter/material.dart';
import '../config/theme.dart';

/// Custom search bar with location button for the app bar
class WeatherSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onLocationPressed;
  final ValueChanged<String>? onSubmitted;

  const WeatherSearchBar({
    super.key,
    required this.controller,
    required this.onLocationPressed,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = AppTheme.isSmallScreen(context);

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Search location...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 6 : 8,
              ),
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white.withAlpha(229), // 0.9 * 255 = 229
            ),
            onSubmitted: onSubmitted,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.location_on),
          onPressed: onLocationPressed,
          iconSize: isSmallScreen ? 24 : 28,
        ),
      ],
    );
  }
}