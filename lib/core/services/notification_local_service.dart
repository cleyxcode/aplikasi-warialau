import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';
import '../../features/notifikasi/notifikasi_model.dart';
import '../../features/notifikasi/notifikasi_service.dart';

const notifikasiBackgroundTask = 'sd_warialau_notif_poll';

@pragma('vm:entry-point')
void onNotificationTapBackground(NotificationResponse response) {
  debugPrint('[Notif] Background tap: ${response.payload}');
}

@pragma('vm:entry-point')
void notificationBackgroundDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      await NotificationLocalService.instance.initialize();
      await NotificationLocalService.instance.checkForNewNotifications(
        fromBackground: true,
      );
      return Future.value(true);
    } catch (e) {
      debugPrint('[Notif] Background task error: $e');
      return Future.value(false);
    }
  });
}

class NotificationLocalService with WidgetsBindingObserver {
  NotificationLocalService._();
  static final NotificationLocalService instance = NotificationLocalService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId = 'sd_warialau_channel';
  static const _channelName = 'SD Negeri Warialau';
  static const _channelDesc = 'Notifikasi dari SD Negeri Warialau';
  static const _prefShownKey = 'local_notif_shown_ids';

  Timer? _pollTimer;
  int _lastUnreadCount = -1;
  bool _initialized = false;
  bool _observingLifecycle = false;
  bool _backgroundRegistered = false;

  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  void Function(String? payload)? onNotificationTap;

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('ic_notification');
    const linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Buka');
    const initSettings = InitializationSettings(
      android: androidSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        onNotificationTap?.call(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: onNotificationTapBackground,
    );

    await _createAndroidChannel();
    _initialized = true;
  }

  Future<void> _createAndroidChannel() async {
    const androidChannel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    return granted ?? false;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
      color: AppColors.primary,
      enableVibration: true,
      ticker: 'SD Negeri Warialau',
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
    );
    final details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  Future<void> showSimple(String title, String body, [String? payloadJson]) async {
    final id = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    await showNotification(
      id: id,
      title: title,
      body: body,
      payload: payloadJson,
    );
  }

  Future<void> showFromModel(NotifikasiModel notif) async {
    final payload = jsonEncode({
      'id': notif.id,
      'tipe': notif.tipe,
      'referensi_id': notif.referensiId,
    });
    await showNotification(
      id: notif.id,
      title: notif.judul,
      body: notif.pesan,
      payload: payload,
    );
  }

  void startPolling({int intervalSeconds = 30}) {
    stopPolling();
    _ensureLifecycleObserver();
    checkForNewNotifications();
    _pollTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => checkForNewNotifications(),
    );
    _registerBackgroundTask();
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  void _ensureLifecycleObserver() {
    if (_observingLifecycle) return;
    WidgetsBinding.instance.addObserver(this);
    _observingLifecycle = true;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkForNewNotifications();
      startPolling();
    } else if (state == AppLifecycleState.paused) {
      stopPolling();
    }
  }

  Future<void> _registerBackgroundTask() async {
    if (_backgroundRegistered) return;
    try {
      await Workmanager().initialize(notificationBackgroundDispatcher);
      await Workmanager().registerPeriodicTask(
        notifikasiBackgroundTask,
        notifikasiBackgroundTask,
        frequency: const Duration(minutes: 15),
        existingWorkPolicy: ExistingWorkPolicy.keep,
        constraints: Constraints(networkType: NetworkType.connected),
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: const Duration(minutes: 5),
      );
      _backgroundRegistered = true;
    } catch (e) {
      debugPrint('[Notif] Workmanager register failed: $e');
    }
  }

  Future<void> checkForNewNotifications({bool fromBackground = false}) async {
    try {
      final unread = fromBackground
          ? await _fetchUnreadCountBackground()
          : await NotifikasiService.getUnreadCount();

      unreadCount.value = unread;

      if (unread == 0) {
        _lastUnreadCount = 0;
        return;
      }

      final shouldFetch =
          unread > _lastUnreadCount || _lastUnreadCount < 0 || fromBackground;
      _lastUnreadCount = unread;
      if (!shouldFetch) return;

      final List<NotifikasiModel> items = fromBackground
          ? await _fetchNotifikasiBackground()
          : (await NotifikasiService.getNotifikasi(page: 1)).data;

      final shownIds = await _getShownIds();

      for (final notif in items) {
        if (!notif.dibaca && !shownIds.contains(notif.id)) {
          await showFromModel(notif);
          shownIds.add(notif.id);
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      await _saveShownIds(shownIds);
    } catch (e) {
      debugPrint('[Notif] Poll error: $e');
    }
  }

  Future<int> _fetchUnreadCountBackground() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) return 0;

    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
    ));
    final response = await dio.get('/notifikasi/unread-count');
    final data = response.data;
    if (data is! Map) return 0;
    final unread = data['unread'];
    if (unread is int) return unread;
    if (unread is num) return unread.toInt();
    return int.tryParse(unread?.toString() ?? '') ?? 0;
  }

  Future<List<NotifikasiModel>> _fetchNotifikasiBackground() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    if (token == null || token.isEmpty) return [];

    final dio = Dio(BaseOptions(
      baseUrl: AppConstants.baseUrl,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
    ));
    final response = await dio.get(
      '/notifikasi',
      queryParameters: {'page': 1},
    );
    final data = (response.data as Map<String, dynamic>)['data'] as List? ?? [];
    return data
        .map((e) => NotifikasiModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> refreshUnreadBadge() async {
    try {
      final unread = await NotifikasiService.getUnreadCount();
      unreadCount.value = unread;
      _lastUnreadCount = unread;
    } catch (_) {}
  }

  Future<void> resetOnLogout() async {
    stopPolling();
    _lastUnreadCount = -1;
    unreadCount.value = 0;
    await _saveShownIds([]);
    await _plugin.cancelAll();
    try {
      await Workmanager().cancelByUniqueName(notifikasiBackgroundTask);
    } catch (_) {}
    _backgroundRegistered = false;
  }

  Future<List<int>> _getShownIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefShownKey) ?? [];
    var ids = raw.map((s) => int.tryParse(s) ?? -1).toList();
    if (ids.length > 500) {
      ids = ids.sublist(ids.length - 500);
    }
    return ids;
  }

  Future<void> _saveShownIds(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefShownKey,
      ids.map((id) => id.toString()).toList(),
    );
  }
}
