import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'api_service.dart';
import 'notification_deep_link.dart';
import 'notification_local_service.dart';
import 'storage_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background isolate: keep minimal — OS shows notification tray.
  debugPrint('[FCM] Background message: ${message.messageId}');
}

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  bool enabled = false;
  String? _currentToken;

  Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('[FCM] Web platform — push disabled');
      return;
    }

    try {
      await Firebase.initializeApp();
      enabled = true;
    } catch (e, st) {
      enabled = false;
      debugPrint('[FCM] Firebase not configured (polling fallback): $e');
      debugPrint('$st');
      return;
    }

    try {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission(alert: true, badge: true, sound: true);

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);

      // Cold start: app opened from terminated state via notification tap
      final initial = await messaging.getInitialMessage();
      if (initial != null) {
        _onOpened(initial);
      }

      messaging.onTokenRefresh.listen((token) {
        _currentToken = token;
        registerToken();
      });

      final token = await messaging.getToken();
      _currentToken = token;
      debugPrint('[FCM] Initialized, token: ${token != null ? 'ok' : 'null'}');
    } catch (e) {
      enabled = false;
      debugPrint('[FCM] Setup failed (non-fatal): $e');
    }
  }

  void _onOpened(RemoteMessage message) {
    final data = Map<String, dynamic>.from(message.data);
    if (data.isEmpty && message.notification != null) {
      data['title'] = message.notification!.title;
      data['body'] = message.notification!.body;
    }
    NotificationDeepLink.instance.handleData(data);
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final notification = message.notification;
    final title =
        notification?.title ?? message.data['title'] as String? ?? 'SD Negeri Warialau';
    final body = notification?.body ?? message.data['body'] as String? ?? '';
    if (body.isEmpty) return;

    String? payload;
    if (message.data.isNotEmpty) {
      payload = jsonEncode(message.data);
    }

    await NotificationLocalService.instance.showSimple(title, body, payload);
    await NotificationLocalService.instance.refreshUnreadBadge();
  }

  Future<void> registerToken() async {
    if (!enabled) return;

    final auth = await StorageService.getToken();
    if (auth == null || auth.isEmpty) return;

    try {
      final messaging = FirebaseMessaging.instance;
      _currentToken ??= await messaging.getToken();
      final token = _currentToken;
      if (token == null || token.isEmpty) return;

      await ApiService.instance.post(
        '/device-tokens',
        data: {
          'token': token,
          'platform': _platform,
          'device_name': _deviceName,
        },
      );
      debugPrint('[FCM] Device token registered');
    } on DioException catch (e) {
      debugPrint('[FCM] Register token failed: ${e.message}');
    } catch (e) {
      debugPrint('[FCM] Register token failed: $e');
    }
  }

  Future<void> unregisterToken() async {
    if (!enabled) return;

    final token = _currentToken;
    if (token == null || token.isEmpty) {
      try {
        _currentToken = await FirebaseMessaging.instance.getToken();
      } catch (_) {}
    }
    final toRemove = _currentToken;
    if (toRemove == null || toRemove.isEmpty) return;

    try {
      await ApiService.instance.delete(
        '/device-tokens',
        data: {'token': toRemove},
      );
      debugPrint('[FCM] Device token unregistered');
    } on DioException catch (e) {
      debugPrint('[FCM] Unregister token failed: ${e.message}');
    } catch (e) {
      debugPrint('[FCM] Unregister token failed: $e');
    } finally {
      _currentToken = null;
    }
  }

  void resetOnLogout() {
    _currentToken = null;
  }

  String get _platform {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'other';
  }

  String get _deviceName {
    try {
      return Platform.localHostname;
    } catch (_) {
      return '${Platform.operatingSystem} device';
    }
  }
}
