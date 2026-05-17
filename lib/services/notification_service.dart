import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Placeholder / framework for scheduling slot reminders when their time arrives.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      ),
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    _initialized = true;
  }

  void _onNotificationTapped(NotificationResponse response) {
    if (kDebugMode) {
      debugPrint('Notification tapped: ${response.payload}');
    }
  }

  /// Schedules a one-shot reminder at [scheduledAt] for [planText].
  /// Returns false if scheduling failed (e.g. past time, permissions).
  Future<bool> scheduleSlotReminder({
    required int notificationId,
    required DateTime scheduledAt,
    required String title,
    required String body,
    String? payload,
  }) async {
    await initialize();

    if (scheduledAt.isBefore(DateTime.now())) {
      if (kDebugMode) {
        debugPrint('Cannot schedule reminder in the past: $scheduledAt');
      }
      return false;
    }

    try {
      await _plugin.zonedSchedule(
        notificationId,
        title,
        body.isEmpty ? 'Time for your planned activity' : body,
        tz.TZDateTime.from(scheduledAt, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'day_planner_slots',
            'Day Planner Reminders',
            channelDescription: 'Reminders for your daily time slots',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: payload,
      );
      return true;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Failed to schedule notification: $e');
      }
      return false;
    }
  }

  Future<void> cancelReminder(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  int notificationIdForSlot(String dateKey, String timeLabel) {
    return '$dateKey|$timeLabel'.hashCode.abs() % 2147483647;
  }

  /// Parses "05:00 AM" style label into DateTime on [date].
  DateTime? slotDateTime(DateTime date, String timeLabel) {
    try {
      final parts = timeLabel.split(' ');
      if (parts.length != 2) return null;
      final period = parts[1];
      final hm = parts[0].split(':');
      if (hm.length != 2) return null;
      var hour = int.parse(hm[0]);
      final minute = int.parse(hm[1]);
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return null;
    }
  }
}
