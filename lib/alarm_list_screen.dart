//alarm_list_screen.dart
import 'package:esp/add_alarm.dart';
import 'package:esp/notification_helper.dart' show NotificationHelper;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'alarm_model.dart';
import 'alarm_provider.dart';

class AlarmListScreen extends StatelessWidget {
  const AlarmListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('University Alarm App')),
      body: Consumer<AlarmProvider>(
        builder: (context, provider, child) {
          if (provider.alarms.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.alarm_add, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 20),
                  const Text(
                    'No alarms set',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Tap the + button to add an alarm',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.alarms.length,
            itemBuilder: (context, index) {
              final alarm = provider.alarms[index];
              return AlarmCard(
                alarm: alarm,
                onToggle: () => provider.toggleAlarm(alarm.id),
                onEdit: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddAlarmScreen(alarm: alarm),
                    ),
                  );
                },
                onDelete: () => _showDeleteDialog(context, alarm.id, provider),
              );
            },
          );
        },
      ),
      // Add this in the AlarmListScreen build method after the floatingActionButton
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.small(
            onPressed: () async {
              // Test notification immediately
              const AndroidNotificationDetails androidDetails =
                  AndroidNotificationDetails(
                    'alarm_channel',
                    'Alarms',
                    channelDescription: 'Alarm notifications',
                    importance: Importance.max,
                    priority: Priority.high,
                  );

              const DarwinNotificationDetails iosDetails =
                  DarwinNotificationDetails();

              await NotificationHelper.showNotification(
                999,
                'Test Alarm',
                'This is a test notification',
                NotificationDetails(android: androidDetails, iOS: iosDetails),
              );
              print('Test notification sent');
            },
            child: const Icon(Icons.notifications),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddAlarmScreen()),
              );
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    String alarmId,
    AlarmProvider provider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Alarm'),
        content: const Text('Are you sure you want to delete this alarm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteAlarm(alarmId);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AlarmCard({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Switch(
                      value: alarm.isActive,
                      onChanged: (value) => onToggle(),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      alarm.formattedTime,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: alarm.isActive ? Colors.blue : Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      alarm.dayPeriod,
                      style: TextStyle(
                        fontSize: 16,
                        color: alarm.isActive ? Colors.blue : Colors.grey,
                      ),
                    ),
                  ],
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              alarm.label,
              style: TextStyle(
                fontSize: 18,
                color: alarm.isActive ? Colors.black87 : Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              alarm.repeatText,
              style: TextStyle(
                fontSize: 14,
                color: alarm.isActive ? Colors.blue : Colors.grey,
              ),
            ),
            if (!alarm.isActive)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Alarm is off',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
