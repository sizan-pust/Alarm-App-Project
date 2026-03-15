//notification_helper.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'alarm_model.dart';
import 'main.dart';
import 'alarm_ringing.dart';

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static String? initialPayload;

  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    final details = await _notificationsPlugin
        .getNotificationAppLaunchDetails();
    if (details != null &&
        details.didNotificationLaunchApp &&
        details.notificationResponse?.payload != null) {
      // Store the payload for main.dart to use for navigation
      initialPayload = details.notificationResponse!.payload;

      // Cancel the notification that launched the app
      await _notificationsPlugin.cancel(initialPayload!.hashCode);
    }
    await _notificationsPlugin.initialize(
      settings,
      // 1. THIS IS THE MISSING PIECE: Handle notification tap
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        if (response.payload != null) {
          final alarmId = response.payload!;

          await _notificationsPlugin.cancel(
            alarmId.hashCode,
          ); // Navigate to Ringing Screen using the Global Key
          if (navigatorKey.currentState != null) {
            // Note: We are using pushReplacement to ensure the Ringing Screen
            // is the top-most screen and no back-stack conflict occurs.
            navigatorKey.currentState!.pushReplacement(
              MaterialPageRoute(
                builder: (context) => AlarmRingScreen(alarmLabel: alarmId),
              ),
            );
          }
        }
      },
    );

    await _createNotificationChannel();
  }

  static Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'alarm_channel',
      'Alarms',
      description: 'Channel for alarm notifications',
      importance: Importance.max,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('alarm_sound'),
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  static Future<void> scheduleAlarm(Alarm alarm) async {
    if (!alarm.isActive) return;

    final now = tz.TZDateTime.now(tz.local);

    var scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      alarm.time.hour,
      alarm.time.minute,
    );

    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      'Alarms',
      channelDescription: 'Alarm notifications',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      fullScreenIntent: true, // Recommended for alarms
      sound: RawResourceAndroidNotificationSound('alarm_sound'),

      // actions: <AndroidNotificationAction>[
      //   AndroidNotificationAction('stop_id', 'Stop Alarm'),// Removed actions for simplicity, but if you use them, they need proper native handling.
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _notificationsPlugin.zonedSchedule(
      alarm.hashCode,
      '⏰ Alarm',
      alarm.label,
      scheduledTime,
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // uiLocalNotificationDateInterpretation:
      //     UILocalNotificationDateInterpretation.absoluteTime,
      payload:
          alarm.id, // 2. Pass the label as payload so we can read it on click
    );
  }

  static Future<void> cancelAlarm(String alarmId) async {
    // You were using alarmId.hashCode, ensure your ID hashing is consistent.
    // In your alarm_model, ID is a String timestamp.
    // Ideally, store an integer ID in the model for notifications.
    // For now, this works if consistent:
    await _notificationsPlugin.cancel(alarmId.hashCode);
  }

  static Future<void> cancelAllAlarms() async {
    await _notificationsPlugin.cancelAll();
  }

  // Update showNotification to support payload for testing
  static Future<void> showNotification(
    int id,
    String title,
    String body,
    NotificationDetails details,
  ) async {
    await _notificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: 'Test Alarm', // Payload for test button
    );
  }
}
