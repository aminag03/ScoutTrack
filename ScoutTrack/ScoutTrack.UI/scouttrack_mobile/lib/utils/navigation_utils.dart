import 'package:flutter/material.dart';

class NavigationUtils {
  static PageRouteBuilder<T> fadeRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 200),
    );
  }

  static PageRouteBuilder<T> slideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }

  static PageRouteBuilder<T> scaleRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: animation.drive(
            Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInOut)),
          ),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 200),
    );
  }

  static PageRouteBuilder<T> fadeSlideRoute<T>(Widget page) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(0.0, 0.3);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        var slideTween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: animation.drive(slideTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 350),
      reverseTransitionDuration: const Duration(milliseconds: 250),
    );
  }

  static Future<T?> navigateWithFade<T>(BuildContext context, Widget page) {
    return Navigator.of(context).pushReplacement<T, dynamic>(fadeRoute(page));
  }

  static Future<T?> navigateWithSlide<T>(BuildContext context, Widget page) {
    return Navigator.of(context).pushReplacement<T, dynamic>(slideRoute(page));
  }

  static Future<T?> navigateWithScale<T>(BuildContext context, Widget page) {
    return Navigator.of(context).pushReplacement<T, dynamic>(scaleRoute(page));
  }

  static Future<T?> navigateWithFadeSlide<T>(
    BuildContext context,
    Widget page,
  ) {
    return Navigator.of(
      context,
    ).pushReplacement<T, dynamic>(fadeSlideRoute(page));
  }
}
