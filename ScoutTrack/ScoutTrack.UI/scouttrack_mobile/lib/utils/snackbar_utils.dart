import 'package:flutter/material.dart';

String formatErrorMessage(Object error) {
  if (error is String) {
    return error;
  }
  final message = error.toString();

  if (message.startsWith('Exception:')) {
    return message.replaceFirst('Exception: ', '');
  }

  if (message.startsWith('Greška: Greška:')) {
    return message.replaceFirst('Greška: Greška:', 'Greška:');
  }

  return message;
}

void showErrorSnackbar(BuildContext context, Object error) {
  final errorMessage = formatErrorMessage(error);

  _showOverlaySnackbar(
    context,
    message: errorMessage,
    backgroundColor: Colors.red,
    icon: Icons.error,
  );
}

void showSuccessSnackbar(BuildContext context, String message) {
  _showOverlaySnackbar(
    context,
    message: message,
    backgroundColor: Colors.green,
    icon: Icons.check_circle,
  );
}

void showWarningSnackbar(BuildContext context, String message) {
  _showOverlaySnackbar(
    context,
    message: message,
    backgroundColor: Colors.orange,
    icon: Icons.warning,
  );
}

void showInfoSnackbar(BuildContext context, String message) {
  _showOverlaySnackbar(
    context,
    message: message,
    backgroundColor: Colors.blue,
    icon: Icons.info,
  );
}

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

  Future.delayed(duration, () {
    overlayEntry.remove();
  });
}

void showContextAwareSnackBar(BuildContext context, SnackBar snackBar) {
  try {
    final rootContext = _findRootContext(context);
    ScaffoldMessenger.of(rootContext).showSnackBar(snackBar);
  } catch (e) {
    _fallbackShowSnackBar(snackBar);
  }
}

void showSimpleSnackBar(
  BuildContext context,
  String message, {
  Color backgroundColor = Colors.blue,
  Duration duration = const Duration(seconds: 3),
}) {
  showCustomSnackbar(
    context,
    message: message,
    backgroundColor: backgroundColor,
    duration: duration,
  );
}

BuildContext _findRootContext(BuildContext context) {
  BuildContext currentContext = context;

  final modalRoute = ModalRoute.of(currentContext);
  if (modalRoute != null && !modalRoute.isFirst) {
    final parentContext = currentContext.findAncestorStateOfType<State>();
    if (parentContext != null) {
      currentContext = parentContext.context;
    }
  }

  try {
    final scaffoldMessenger = ScaffoldMessenger.maybeOf(currentContext);
    if (scaffoldMessenger != null) {
      return currentContext;
    }
  } catch (e) {
    // Continue with other methods
  }

  final scaffold = currentContext.findAncestorWidgetOfExactType<Scaffold>();
  if (scaffold != null) {
    return currentContext;
  }

  BuildContext? lastValidContext = currentContext;
  int maxIterations = 10;
  int iterations = 0;

  while (iterations < maxIterations &&
      currentContext.widget is! Scaffold &&
      currentContext.widget is! MaterialApp &&
      currentContext.widget is! Navigator) {
    iterations++;

    final parentScaffold = currentContext
        .findAncestorWidgetOfExactType<Scaffold>();
    if (parentScaffold != null) {
      return currentContext;
    }

    try {
      final scaffoldMessenger = ScaffoldMessenger.maybeOf(currentContext);
      if (scaffoldMessenger != null) {
        return currentContext;
      }
    } catch (e) {
      // Continue
    }

    final modalRoute = ModalRoute.of(currentContext);
    if (modalRoute != null && modalRoute.isFirst) {
      return currentContext;
    }

    final parentContext = currentContext.findAncestorStateOfType<State>();
    if (parentContext != null) {
      lastValidContext = currentContext;
      currentContext = parentContext.context;
    } else {
      break;
    }
  }

  return lastValidContext ?? currentContext;
}

void _fallbackShowSnackBar(SnackBar snackBar) {
  try {
    if (SnackBarUtils.scaffoldMessengerKey?.currentState != null) {
      SnackBarUtils.scaffoldMessengerKey!.currentState!.showSnackBar(snackBar);
    } else {
      print('SnackBar: ${snackBar.content}');
    }
  } catch (e) {
    print('SnackBar: ${snackBar.content}');
  }
}

class SnackBarUtils {
  static GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey;

  static void initialize(
    GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey,
  ) {
    SnackBarUtils.scaffoldMessengerKey = scaffoldMessengerKey;
  }

  static void showSnackBar(
    String message, {
    Color? backgroundColor,
    Duration? duration,
    BuildContext? context,
  }) {
    if (context != null) {
      showCustomSnackbar(
        context,
        message: message,
        backgroundColor: backgroundColor ?? Colors.green,
        duration: duration ?? const Duration(seconds: 3),
      );
      return;
    }

    if (scaffoldMessengerKey?.currentState != null) {
      scaffoldMessengerKey!.currentState!.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor ?? Colors.green,
          duration: duration ?? const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  static void showErrorSnackBar(Object message, {BuildContext? context}) {
    if (context != null) {
      showErrorSnackbar(context, message);
    } else {
      showSnackBar(
        message.toString(),
        backgroundColor: Colors.red,
        context: context,
      );
    }
  }

  static void showSuccessSnackBar(String message, {BuildContext? context}) {
    if (context != null) {
      showSuccessSnackbar(context, message);
    } else {
      showSnackBar(message, backgroundColor: Colors.green, context: context);
    }
  }

  static void showWarningSnackBar(String message, {BuildContext? context}) {
    if (context != null) {
      showWarningSnackbar(context, message);
    } else {
      showSnackBar(message, backgroundColor: Colors.orange, context: context);
    }
  }

  static void showInfoSnackBar(String message, {BuildContext? context}) {
    if (context != null) {
      showInfoSnackbar(context, message);
    } else {
      showSnackBar(message, backgroundColor: Colors.blue, context: context);
    }
  }
}
