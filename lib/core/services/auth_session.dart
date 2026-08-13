import 'package:flutter/material.dart';
import '../../app/app.dart';
import '../../app/app_routes.dart';
import 'notification_local_service.dart';
import 'storage_service.dart';

/// Menangani sesi kadaluarsa (HTTP 401) secara terpusat.
class AuthSession {
  AuthSession._();

  static Future<void> handleUnauthorized() async {
    await StorageService.clearAll();
    try {
      await NotificationLocalService.instance.resetOnLogout();
    } catch (_) {}

    final nav = navigatorKey.currentState;
    if (nav == null) return;

    nav.pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);

    final ctx = navigatorKey.currentContext;
    if (ctx != null && ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        const SnackBar(
          content: Text('Sesi berakhir. Silakan masuk kembali.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
