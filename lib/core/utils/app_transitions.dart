import 'package:flutter/material.dart';

/// Slide from right + fade-in, with secondary push-left effect.
/// Used for all forward navigations.
class AppRoute<T> extends PageRouteBuilder<T> {
  AppRoute({required Widget page, RouteSettings? settings})
      : super(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, secondaryAnimation, child) {
            // Incoming: slide from right + fade
            final slideIn = Tween<Offset>(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));

            final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                parent: animation,
                curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
              ),
            );

            // Outgoing (current page): slide slightly left
            final slideOut = Tween<Offset>(
              begin: Offset.zero,
              end: const Offset(-0.12, 0.0),
            ).animate(CurvedAnimation(
              parent: secondaryAnimation,
              curve: Curves.easeInCubic,
            ));

            final fadeOut = Tween<double>(begin: 1.0, end: 0.85).animate(
              CurvedAnimation(
                parent: secondaryAnimation,
                curve: Curves.easeIn,
              ),
            );

            return SlideTransition(
              position: slideOut,
              child: FadeTransition(
                opacity: fadeOut,
                child: SlideTransition(
                  position: slideIn,
                  child: FadeTransition(opacity: fadeIn, child: child),
                ),
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 380),
          reverseTransitionDuration: const Duration(milliseconds: 300),
        );
}

/// Bottom sheet style — slides up from bottom.
class AppRouteBottomUp<T> extends PageRouteBuilder<T> {
  AppRouteBottomUp({required Widget page, RouteSettings? settings})
      : super(
          settings: settings,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            final slide = Tween<Offset>(
              begin: const Offset(0.0, 1.0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));
            final fade = Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(
                  parent: animation,
                  curve: const Interval(0.0, 0.4, curve: Curves.easeOut)),
            );
            return FadeTransition(
              opacity: fade,
              child: SlideTransition(position: slide, child: child),
            );
          },
          transitionDuration: const Duration(milliseconds: 400),
          reverseTransitionDuration: const Duration(milliseconds: 320),
        );
}

/// Fade only — for overlays and dialogs.
class AppRouteFade<T> extends PageRouteBuilder<T> {
  AppRouteFade({required Widget page, RouteSettings? settings})
      : super(
          settings: settings,
          opaque: false,
          barrierColor: Colors.black54,
          pageBuilder: (_, __, ___) => page,
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 300),
          reverseTransitionDuration: const Duration(milliseconds: 250),
        );
}
