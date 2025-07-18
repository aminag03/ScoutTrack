import 'package:flutter/material.dart';

String formatErrorMessage(Object error) {
  final message = error.toString();
  if (message.startsWith('Exception:')) {
    return message.replaceFirst('Exception: ', '');
  }
  return message;
}

void showErrorSnackbar(BuildContext context, Object error) {
  final errorMessage = formatErrorMessage(error);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.red,
      content: Row(
        children: [
          const Icon(Icons.error, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  );
}
