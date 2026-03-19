import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';
import '../../features/notifikasi/notifikasi_model.dart';
import '../../features/notifikasi/notifikasi_service.dart';

/// Callback saat notifikasi di-tap (harus top-level / static)
@pragma('vm:entry-point')
void onNotificationTapBackground(NotificationResponse response) {
  // Isolate background — tidak ada BuildContext di sini
  debugPrint('[Notif] Background tap: ${response.payload}');
}

class NotificationLocalService {
  NotificationLocalService._();
  static final NotificationLocalService instance = NotificationLocalService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // Channel Android
  static const _channelId = 'sd_warialau_channel';
  static const _channelName = 'SD Negeri Warialau';
  static const _channelDesc = 'Notifikasi dari SD Negeri Warialau';

  // SharedPreferences key untuk menyimpan ID notif yang sudah ditampilkan
  static const _prefShownKey = 'local_notif_shown_ids';

  Timer? _pollTimer;
  int _lastUnreadCount = 0;
  bool _initialized = false;

  /// Callback saat notifikasi di-tap (ketika app sedang berjalan)
  /// Diisi dari main.dart / navigator key
  void Function(String? payload)? onNotificationTap;

  // ── Inisialisasi ─────────────────────────────────────────

  Future<void> initialize() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('ic_notification');
    const linuxSettings =
        LinuxInitializationSettings(defaultActionName: 'Buka');
    const initSettings = InitializationSettings(
      android: androidSettings,
      linux: linuxSettings,
    );

    await _plugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        debugPrint('[Notif] Tap payload: ${response.payload}');
        onNotificationTap?.call(response.payload);
      },
      onDidReceiveBackgroundNotificationResponse: onNotificationTapBackground,
    );

    // Buat channel Android (wajib Android 8+)
    await _createAndroidChannel();

    _initialized = true;
    debugPrint('[Notif] Initialized');
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

  // ── Request Permission (Android 13+) ──────────────────────

  Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    debugPrint('[Notif] Permission granted: $granted');
    return granted ?? false;
  }

  // ── Tampilkan Notifikasi ──────────────────────────────────

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: 'ic_notification',
      color: AppColors.primary,
      enableVibration: true,
      ticker: 'SD Negeri Warialau',
      styleInformation: BigTextStyleInformation(''),
    );
    const details = NotificationDetails(android: androidDetails);
    await _plugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
    debugPrint('[Notif] Shown: $title');
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

  // ── Polling dari API ──────────────────────────────────────

  /// Mulai polling setiap [intervalSeconds] detik.
  /// Panggil setelah user login.
  void startPolling({int intervalSeconds = 30}) {
    stopPolling();
    // Langsung cek pertama kali
    _checkForNewNotifications();
    _pollTimer = Timer.periodic(
      Duration(seconds: intervalSeconds),
      (_) => _checkForNewNotifications(),
    );
    debugPrint('[Notif] Polling started (${intervalSeconds}s interval)');
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
    debugPrint('[Notif] Polling stopped');
  }

  Future<void> _checkForNewNotifications() async {
    try {
      final unread = await NotifikasiService.getUnreadCount();
      debugPrint('[Notif] Unread count: $unread');

      if (unread == 0) return;

      // Hanya fetch jika ada notif baru (count naik atau pertama kali)
      if (unread <= _lastUnreadCount && _lastUnreadCount != 0) return;
      _lastUnreadCount = unread;

      // Fetch halaman pertama notifikasi
      final result = await NotifikasiService.getNotifikasi(page: 1);
      final shownIds = await _getShownIds();

      for (final notif in result.data) {
        if (!notif.dibaca && !shownIds.contains(notif.id)) {
          await showFromModel(notif);
          shownIds.add(notif.id);
          // Delay antar notifikasi agar tidak tumpuk
          await Future.delayed(const Duration(milliseconds: 300));
        }
      }

      await _saveShownIds(shownIds);
    } catch (e) {
      debugPrint('[Notif] Poll error: $e');
    }
  }

  // ── Reset (saat logout) ───────────────────────────────────

  Future<void> resetOnLogout() async {
    stopPolling();
    _lastUnreadCount = 0;
    await _saveShownIds([]);
    await _plugin.cancelAll();
    debugPrint('[Notif] Reset on logout');
  }

  // ── SharedPreferences helpers ─────────────────────────────

  Future<List<int>> _getShownIds() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefShownKey) ?? [];
    return raw.map((s) => int.tryParse(s) ?? -1).toList();
  }

  Future<void> _saveShownIds(List<int> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefShownKey,
      ids.map((id) => id.toString()).toList(),
    );
  }
}
