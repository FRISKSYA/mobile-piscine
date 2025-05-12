import 'package:flutter/material.dart';

/// A reusable error banner widget for displaying error messages in the app
class ErrorBanner extends StatelessWidget {
  /// The error message to display
  final String errorMessage;
  
  /// Whether the error is related to location not being found
  final bool isLocationError;
  
  /// Whether the error is related to connection issues
  final bool isConnectionError;
  
  /// Callback when retry button is pressed (only shown for connection errors)
  final VoidCallback? onRetry;
  
  /// Callback when close button is pressed (shown for non-connection errors)
  final VoidCallback? onClose;

  const ErrorBanner({
    super.key,
    required this.errorMessage,
    this.isLocationError = false,
    this.isConnectionError = false,
    this.onRetry,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    // Determine banner color and icon based on error type
    final Color bannerColor = isLocationError ? Colors.orange : Colors.red.shade700;
    final IconData iconData = isLocationError ? Icons.location_off : Icons.signal_wifi_off;

    // Use different styling for temporary vs persistent errors
    final TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: 14,
      fontWeight: isConnectionError ? FontWeight.bold : FontWeight.normal,
    );

    return Material(
      elevation: 4,
      child: Container(
        color: bannerColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: SafeArea(
          bottom: false,
          child: Row(
            children: [
              Icon(
                iconData,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorMessage,
                  style: textStyle,
                ),
              ),
              if (isConnectionError && onRetry != null)
                TextButton(
                  onPressed: onRetry,
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else if (onClose != null)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 20),
                  onPressed: onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}