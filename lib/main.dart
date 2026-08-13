import 'package:flutter/material.dart';
import 'app/app.dart';
import 'core/services/fcm_service.dart';
import 'core/services/notification_deep_link.dart';
import 'core/services/notification_local_service.dart';
import 'core/services/sentry_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SentryService.init(() async {
    try {
      await NotificationLocalService.instance.initialize();
    } catch (e) {
      debugPrint('[Main] Notif init failed (non-fatal): $e');
    }

    try {
      await FcmService.instance.initialize();
    } catch (e) {
      debugPrint('[Main] FCM init failed (non-fatal): $e');
    }

    NotificationLocalService.instance.onNotificationTap =
        NotificationDeepLink.instance.handlePayload;

    runApp(const App());
  });
}
