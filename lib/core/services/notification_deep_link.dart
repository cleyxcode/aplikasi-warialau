import 'dart:convert';

import 'package:flutter/scheduler.dart';

import '../../app/app.dart';
import '../../app/app_routes.dart';

/// Handles notification → screen deep links for local + FCM taps.
class NotificationDeepLink {
  NotificationDeepLink._();
  static final NotificationDeepLink instance = NotificationDeepLink._();

  Map<String, dynamic>? _pending;
  bool _ready = false;

  /// Call after splash has navigated to a stable route (home/login/etc).
  void markReady() {
    _ready = true;
    _flush();
  }

  void handlePayload(String? payload) {
    if (payload == null || payload.isEmpty) return;
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      handleData(data);
    } catch (_) {
      _navigate(AppRoutes.notifikasi);
    }
  }

  void handleData(Map<String, dynamic> data) {
    if (!_ready || navigatorKey.currentState == null) {
      _pending = data;
      return;
    }
    _go(data);
  }

  void _flush() {
    final pending = _pending;
    if (pending == null) return;
    _pending = null;
    SchedulerBinding.instance.addPostFrameCallback((_) => _go(pending));
  }

  void _go(Map<String, dynamic> data) {
    final tipe = data['tipe']?.toString();
    final rawId = data['referensi_id'] ?? data['id'];
    final id = int.tryParse(rawId?.toString() ?? '');

    if (tipe == 'berita' && id != null) {
      _navigate(AppRoutes.detailBerita, arguments: id);
      return;
    }
    if (tipe == 'pendaftaran' && id != null) {
      _navigate(AppRoutes.detailPendaftaran, arguments: id);
      return;
    }
    _navigate(AppRoutes.notifikasi);
  }

  void _navigate(String route, {Object? arguments}) {
    final nav = navigatorKey.currentState;
    if (nav == null) {
      _pending = {
        'tipe': route == AppRoutes.detailBerita
            ? 'berita'
            : route == AppRoutes.detailPendaftaran
                ? 'pendaftaran'
                : 'umum',
        'referensi_id': arguments,
      };
      return;
    }
    nav.pushNamed(route, arguments: arguments);
  }
}
