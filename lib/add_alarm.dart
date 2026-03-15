import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'alarm_model.dart';
import 'alarm_provider.dart';

class AddAlarmScreen extends StatefulWidget {
  final Alarm? alarm;

  const AddAlarmScreen({super.key, this.alarm});

  @override
  State<AddAlarmScreen> createState() => _AddAlarmScreenState();
}

class _AddAlarmScreenState extends State<AddAlarmScreen> {
  late TimeOfDay _selectedTime;
  late TextEditingController _labelController;
  late List<bool> _selectedDays;
  late bool _vibrate;
  late int _snoozeDuration;

  @override
  void initState() {
    super.initState();

    if (widget.alarm != null) {
      _selectedTime = TimeOfDay.fromDateTime(widget.alarm!.time);
      _labelController = TextEditingController(text: widget.alarm!.label);
      _selectedDays = List.generate(
        7,
        (index) => widget.alarm!.repeatDays.contains(index + 1),
      );
      _vibrate = widget.alarm!.vibrate;
      _snoozeDuration = widget.alarm!.snoozeDuration;
    } else {
      final now = DateTime.now();
      _selectedTime = TimeOfDay(hour: now.hour, minute: now.minute);
      _labelController = TextEditingController(text: 'Alarm');
      _selectedDays = List.generate(7, (index) => false);
      _vibrate = true;
      _snoozeDuration = 5;
    }
  }

  @override
  void dispose() {
    _labelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.alarm == null ? 'Add Alarm' : 'Edit Alarm'),
        actions: [
          if (widget.alarm != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteAlarm,
              color: Colors.red,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Time Picker
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  children: [
                    Text(
                      _selectedTime.format(context),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Tap to change time',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Label
            TextField(
              controller: _labelController,
              decoration: InputDecoration(
                labelText: 'Alarm Label',
                prefixIcon: const Icon(Icons.label),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
            ),

            const SizedBox(height: 30),

            // Repeat Days
            _buildRepeatDaysSelector(),

            const SizedBox(height: 30),

            // Vibrate Switch
            Card(
              child: SwitchListTile(
                title: const Text('Vibrate'),
                subtitle: const Text('Phone will vibrate when alarm rings'),
                value: _vibrate,
                onChanged: (value) {
                  setState(() {
                    _vibrate = value;
                  });
                },
                secondary: const Icon(Icons.vibration),
              ),
            ),

            const SizedBox(height: 20),

            // Snooze Duration
            Card(
              child: ListTile(
                leading: const Icon(Icons.snooze),
                title: const Text('Snooze Duration'),
                subtitle: Text('$_snoozeDuration minutes'),
                trailing: DropdownButton<int>(
                  value: _snoozeDuration,
                  onChanged: (value) {
                    setState(() {
                      _snoozeDuration = value!;
                    });
                  },
                  items: const [
                    DropdownMenuItem(value: 1, child: Text('1 min')),
                    DropdownMenuItem(value: 5, child: Text('5 min')),
                    DropdownMenuItem(value: 10, child: Text('10 min')),
                    DropdownMenuItem(value: 15, child: Text('15 min')),
                    DropdownMenuItem(value: 30, child: Text('30 min')),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ElevatedButton(
            onPressed: _saveAlarm,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              widget.alarm == null ? 'Save Alarm' : 'Update Alarm',
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRepeatDaysSelector() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Repeat',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          children: List.generate(7, (index) {
            return ChoiceChip(
              label: Text(days[index]),
              selected: _selectedDays[index],
              onSelected: (selected) {
                setState(() {
                  _selectedDays[index] = selected;
                });
              },
              selectedColor: Colors.blue,
              labelStyle: TextStyle(
                color: _selectedDays[index] ? Colors.white : Colors.black,
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        Text(_getRepeatText(), style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  String _getRepeatText() {
    final selectedIndices = <int>[];
    for (int i = 0; i < _selectedDays.length; i++) {
      if (_selectedDays[i]) {
        selectedIndices.add(i + 1);
      }
    }

    if (selectedIndices.isEmpty) return 'Never repeats';
    if (selectedIndices.length == 7) return 'Every day';
    if (Set.from(selectedIndices).containsAll([1, 2, 3, 4, 5]) &&
        selectedIndices.length == 5) {
      return 'Weekdays';
    }
    if (Set.from(selectedIndices).containsAll([6, 7]) &&
        selectedIndices.length == 2) {
      return 'Weekends';
    }

    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return selectedIndices.map((index) => days[index - 1]).join(', ');
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );

    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _saveAlarm() {
    final now = DateTime.now();

    // Create alarm time for TODAY with the selected hour/minute
    // The date part doesn't matter much since we reschedule based on current time
    final alarmTime = DateTime(
      now.year,
      now.month,
      now.day, // Use today's date
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final repeatDays = <int>[];
    for (int i = 0; i < _selectedDays.length; i++) {
      if (_selectedDays[i]) {
        repeatDays.add(i + 1);
      }
    }

    final alarm = Alarm(
      id: widget.alarm?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      time: alarmTime, // Store just hour/minute (date part will be ignored)
      label: _labelController.text.isEmpty ? 'Alarm' : _labelController.text,
      repeatDays: repeatDays,
      vibrate: _vibrate,
      snoozeDuration: _snoozeDuration,
    );

    final provider = Provider.of<AlarmProvider>(context, listen: false);

    if (widget.alarm == null) {
      provider.addAlarm(alarm);
      print('🎯 New alarm added: "${alarm.label}" at ${alarm.formattedTime}');
    } else {
      provider.updateAlarm(alarm);
      print('🔄 Alarm updated: "${alarm.label}" at ${alarm.formattedTime}');
    }

    Navigator.pop(context);
  }

  void _deleteAlarm() {
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
              Provider.of<AlarmProvider>(
                context,
                listen: false,
              ).deleteAlarm(widget.alarm!.id);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
