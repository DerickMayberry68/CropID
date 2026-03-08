import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart' show Color;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Wraps flutter_local_notifications for foreground alerts.
/// On web, this is a no-op — Realtime state updates + badge are sufficient.
/// Mobile support (Android/iOS) is active.
class LocalNotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (kIsWeb || _initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    _initialized = true;
  }

  /// Show a high-priority danger alert notification.
  static Future<void> showDangerAlert({
    required String title,
    required String body,
  }) async {
    if (kIsWeb || !_initialized) return;

    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'crop_danger_alerts',
        'Spray Danger Alerts',
        channelDescription:
            'Alerts when a neighboring farmer plans to spray chemicals near your crops',
        importance: Importance.high,
        priority: Priority.high,
        color: Color(0xFFB71C1C), // danger red
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000, // unique ID
      title,
      body,
      details,
    );
  }
}
