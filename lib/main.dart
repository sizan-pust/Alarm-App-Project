//main.dart
import 'package:esp/alarm_ringing.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'alarm_provider.dart';
import 'alarm_list_screen.dart';
import 'notification_helper.dart';

// Global Key for navigation from Notification Handlers
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize timezone database (required for scheduled notifications)
  tz.initializeTimeZones();
  // Use the current local timezone
  tz.setLocalLocation(tz.getLocation('Asia/Dhaka'));

  // Request critical permissions for a reliable alarm
  await Permission.notification.request();
  await Permission.scheduleExactAlarm.request();

  // Request System Alert Window for full-screen intent (Android specific)
  // This is required to reliably show the screen over other apps/lock screen.
  await Permission.systemAlertWindow.request();

  await NotificationHelper.init();
  final alarmProvider = AlarmProvider();
  await alarmProvider.initialize();
  runApp(
    ChangeNotifierProvider.value(value: alarmProvider, child: const AlarmApp()),
  );
}

class AlarmApp extends StatelessWidget {
  const AlarmApp({super.key});

  @override
  Widget build(BuildContext context) {
    final initialRoute = NotificationHelper.initialPayload != null
        ? '/ringing' // Use a named route or just indicate the path
        : '/home';
    return MaterialApp(
      // Assign the Global Key to MaterialApp
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Alarm App',
      theme: ThemeData(useMaterial3: true, primarySwatch: Colors.blue),
      initialRoute: initialRoute,
      routes: {
        '/home': (context) => const AlarmListScreen(),
        '/ringing': (context) {
          // 3. Extract the payload and pass it to the ringing screen
          final alarmId = NotificationHelper.initialPayload!;
          // Set the payload to null immediately after using it
          NotificationHelper.initialPayload = null;

          return AlarmRingScreen(alarmLabel: alarmId);
        },
      },
      // Routes are still fine, but navigation from the notification handler
      // will use the navigatorKey and MaterialPageRoute.
    );
  }
}
