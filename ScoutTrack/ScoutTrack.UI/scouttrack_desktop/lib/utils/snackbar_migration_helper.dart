import 'package:flutter/material.dart';

void showContextAwareSnackBar(BuildContext context, SnackBar snackBar) {
  final rootContext = _findRootContext(context);

  ScaffoldMessenger.of(rootContext).showSnackBar(snackBar);
}

void showSimpleSnackBar(
  BuildContext context,
  String message, {
  Color backgroundColor = Colors.blue,
  Duration duration = const Duration(seconds: 3),
}) {
  final rootContext = _findRootContext(context);

  ScaffoldMessenger.of(rootContext).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      duration: duration,
    ),
  );
}

BuildContext _findRootContext(BuildContext context) {
  BuildContext currentContext = context;

  while (currentContext.widget is! Scaffold &&
      currentContext.widget is! MaterialApp &&
      currentContext.widget is! Navigator) {
    final parent = currentContext.findAncestorWidgetOfExactType<Scaffold>();
    if (parent != null) {
      return currentContext;
    }

    final modalRoute = ModalRoute.of(currentContext);
    if (modalRoute != null && modalRoute.isFirst) {
      return currentContext;
    }

    final parentContext = currentContext.findAncestorStateOfType<State>();
    if (parentContext != null) {
      currentContext = parentContext.context;
    } else {
      break;
    }
  }

  return currentContext;
}
