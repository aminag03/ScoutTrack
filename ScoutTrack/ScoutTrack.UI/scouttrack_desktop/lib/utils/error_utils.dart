import 'package:flutter/material.dart';

String formatErrorMessage(Object error) {
  if (error is String) {
    return error;
  }
  final message = error.toString();
  if (message.startsWith('Exception:')) {
    return message.replaceFirst('Exception: ', '');
  }
  return message;
}

/// Shows an error snackbar that will appear with proper brightness
/// even when dialogs are open by using overlay
void showErrorSnackbar(BuildContext context, Object error) {
  final errorMessage = formatErrorMessage(error);

  _showOverlaySnackbar(
    context,
    message: errorMessage,
    backgroundColor: Colors.red,
    icon: Icons.error,
  );
}

/// Shows a success snackbar that will appear with proper brightness
/// even when dialogs are open by using overlay
void showSuccessSnackbar(BuildContext context, String message) {
  _showOverlaySnackbar(
    context,
    message: message,
    backgroundColor: Colors.green,
    icon: Icons.check_circle,
  );
}

/// Shows a custom snackbar that will appear with proper brightness
/// even when dialogs are open by using overlay
void showCustomSnackbar(
  BuildContext context, {
  required String message,
  Color backgroundColor = Colors.blue,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
}) {
  _showOverlaySnackbar(
    context,
    message: message,
    backgroundColor: backgroundColor,
    icon: icon,
    duration: duration,
  );
}

/// Shows a snackbar using overlay to ensure it appears above all dialogs
void _showOverlaySnackbar(
  BuildContext context, {
  required String message,
  required Color backgroundColor,
  IconData? icon,
  Duration duration = const Duration(seconds: 3),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: Colors.white),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  overlay.insert(overlayEntry);

  // Auto-remove after duration
  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}
