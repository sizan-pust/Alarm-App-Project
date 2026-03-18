//alarm_list_screen.dart
import 'package:esp/add_alarm.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'alarm_model.dart';
import 'alarm_provider.dart';

class AlarmListScreen extends StatelessWidget {
  const AlarmListScreen({super.key});

  String _getMonthYear(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  List<Widget> _buildDateRow(DateTime now) {
    final today = DateTime.now().day;
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    // Get the first day of the current month
    final firstDay = DateTime(currentYear, currentMonth, 1);
    final lastDay = DateTime(currentYear, currentMonth + 1, 0).day;

    // Calculate starting position (which day of week does month start on)
    final startingDayOfWeek = firstDay.weekday % 7; // 0 = Sunday, 6 = Saturday

    // Get previous month's last day for padding
    final prevMonthLastDay = DateTime(currentYear, currentMonth, 0).day;
    final prevDaysToShow = startingDayOfWeek;

    List<Widget> widgets = [];

    // Add days from previous month
    for (int i = 0; i < prevDaysToShow; i++) {
      widgets.add(
        _buildDateBox(
          (prevMonthLastDay - prevDaysToShow + i + 1).toString(),
          false,
          false,
        ),
      );
    }

    // Add days of current month
    for (int day = 1; day <= lastDay; day++) {
      final isToday = day == today;
      widgets.add(_buildDateBox(day.toString(), isToday, true));
    }

    // Add days from next month if needed
    final remainingDays = 7 - (widgets.length % 7);
    if (remainingDays < 7) {
      for (int day = 1; day <= remainingDays; day++) {
        widgets.add(_buildDateBox(day.toString(), false, false));
      }
    }

    // Take only the first 7 for a single row
    return widgets.take(7).toList();
  }

  Widget _buildDateBox(String date, bool isToday, bool isCurrentMonth) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 2),
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: isToday ? const Color(0xFFF6C84C) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              date,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isToday ? FontWeight.bold : FontWeight.w500,
                color: isCurrentMonth
                    ? (isToday ? Colors.black87 : Colors.grey)
                    : Colors.grey[300],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FB),
      body: Consumer<AlarmProvider>(
        builder: (context, provider, child) {
          return SafeArea(
            child: Column(
              children: [
                // Top greeting header
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 18,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Good Morning ☀️',
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Soham Ningurkar',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Let\'s build your habbits',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                      CircleAvatar(
                        radius: 20,
                        backgroundImage: null,
                        backgroundColor: Colors.grey[300],
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                // Calendar/Date selector
                SizedBox(
                  height: 100,
                  child: Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Month and Year
                        Text(
                          _getMonthYear(DateTime.now()),
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Days of week and dates
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _buildDateRow(DateTime.now()),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Tabs: Alarm / Goals
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF6C84C),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Alarm',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Goals',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Alarms grid or empty state
                Expanded(
                  child: provider.alarms.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/empty_alarm.png',
                                width: 180,
                                height: 140,
                                errorBuilder: (_, __, ___) => Icon(
                                  Icons.alarm_off,
                                  size: 120,
                                  color: Colors.grey[300],
                                ),
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'No Alarm found',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Add alarm to set goals',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 1.15,
                                ),
                            itemCount: provider.alarms.length,
                            itemBuilder: (context, index) {
                              final alarm = provider.alarms[index];
                              return FigmaAlarmCard(
                                alarm: alarm,
                                onToggle: () => provider.toggleAlarm(alarm.id),
                                onEdit: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          AddAlarmScreen(alarm: alarm),
                                    ),
                                  );
                                },
                                onDelete: () => _showDeleteDialog(
                                  context,
                                  alarm.id,
                                  provider,
                                ),
                              );
                            },
                          ),
                        ),
                ),
              ],
            ),
          );
        },
      ),
      // Bottom navigation with centered FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddAlarmScreen()),
          );
        },
        backgroundColor: const Color(0xFFF6C84C),
        child: const Icon(Icons.add, color: Colors.black87),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(onPressed: () {}, icon: const Icon(Icons.home)),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.calendar_today),
              ),
              const SizedBox(width: 48), // space for FAB
              IconButton(onPressed: () {}, icon: const Icon(Icons.bar_chart)),
              IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
            ],
          ),
        ),
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

class FigmaAlarmCard extends StatelessWidget {
  final Alarm alarm;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FigmaAlarmCard({
    super.key,
    required this.alarm,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: alarm.isActive ? Colors.yellow.shade700 : Colors.transparent,
            width: alarm.isActive ? 1.5 : 0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarm.formattedTime,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: alarm.isActive ? Colors.black87 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alarm.dayPeriod,
                      style: TextStyle(
                        color: alarm.isActive ? Colors.black54 : Colors.grey,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Switch(value: alarm.isActive, onChanged: (_) => onToggle()),
                    PopupMenuButton<String>(
                      onSelected: (v) {
                        if (v == 'edit') onEdit();
                        if (v == 'delete') onDelete();
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const Spacer(),
            Text(
              alarm.label,
              style: TextStyle(
                fontSize: 16,
                color: alarm.isActive ? Colors.black87 : Colors.grey,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              alarm.repeatText,
              style: TextStyle(
                color: alarm.isActive ? Colors.blue : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
