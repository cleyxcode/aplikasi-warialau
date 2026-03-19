import 'dart:convert';
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/app_routes.dart';
import 'core/services/notification_local_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await NotificationLocalService.instance.initialize();

  NotificationLocalService.instance.onNotificationTap = (payload) {
    if (payload == null) return;
    try {
      final data   = jsonDecode(payload) as Map<String, dynamic>;
      final tipe   = data['tipe'] as String?;
      final refId  = data['referensi_id'];
      final nav    = navigatorKey.currentState;
      if (nav == null) return;

      if (tipe == 'berita' && refId != null) {
        nav.pushNamed(AppRoutes.detailBerita, arguments: refId);
      } else if (tipe == 'pendaftaran' && refId != null) {
        nav.pushNamed(AppRoutes.detailPendaftaran, arguments: refId);
      } else {
        nav.pushNamed(AppRoutes.notifikasi);
      }
    } catch (_) {
      navigatorKey.currentState?.pushNamed(AppRoutes.notifikasi);
    }
  };

  runApp(const App());
}
