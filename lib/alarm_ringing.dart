//alarm_ringing.dart
import 'package:esp/alarm_model.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';
import 'alarm_provider.dart';
import 'notification_helper.dart';

class AlarmRingScreen extends StatefulWidget {
  final String alarmLabel;
  final bool fromNotification;
  final bool launchedFromNotification;

  const AlarmRingScreen({
    super.key,
    required this.alarmLabel,
    this.fromNotification = false,
    this.launchedFromNotification = false,
  });

  @override
  State<AlarmRingScreen> createState() => _AlarmRingScreenState();
}

class _AlarmRingScreenState extends State<AlarmRingScreen> {
  //final AudioPlayer _audioPlayer = AudioPlayer();
  late AudioPlayer _audioPlayer;
  late TextEditingController _answerController;
  int? _leftOperand;
  int? _rightOperand;
  String _operator = '+';
  int? _correctAnswer;
  Alarm? _currentAlarm;
  @override
  void initState() {
    super.initState();
    NotificationHelper.cancelAlarm(widget.alarmLabel);
    _fetchAlarmDetails();
    _audioPlayer = AudioPlayer();
    _answerController = TextEditingController();
    _startAlarm();
  }

  @override
  void dispose() {
    _answerController.dispose();
    _stopAlarm();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _generateProblem() {
    final rand = Random();
    final ops = ['+', '-', '*'];
    _operator = ops[rand.nextInt(ops.length)];
    switch (_operator) {
      case '+':
        _leftOperand = rand.nextInt(50) + 1;
        _rightOperand = rand.nextInt(50) + 1;
        _correctAnswer = _leftOperand! + _rightOperand!;
        break;
      case '-':
        _leftOperand = rand.nextInt(50) + 20;
        _rightOperand = rand.nextInt(20) + 1;
        _correctAnswer = _leftOperand! - _rightOperand!;
        break;
      case '*':
        _leftOperand = rand.nextInt(12) + 2;
        _rightOperand = rand.nextInt(9) + 2;
        _correctAnswer = _leftOperand! * _rightOperand!;
        break;
    }
    _answerController.text = '';
  }

  Future<bool> _showMathChallenge() async {
    _generateProblem();
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        String? errorText;
        return StatefulBuilder(
          builder: (ctx2, setStateDialog) {
            return AlertDialog(
              title: const Text('Solve to Dismiss'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_leftOperand!} $_operator ${_rightOperand!} = ?',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _answerController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Your answer',
                      errorText: errorText,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(ctx2).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    final input = int.tryParse(_answerController.text.trim());
                    if (input != null && input == _correctAnswer) {
                      Navigator.of(ctx2).pop(true);
                    } else {
                      // show error in dialog by rebuilding with local state
                      setStateDialog(() {
                        errorText = 'Incorrect answer, try again';
                        _answerController.text = '';
                      });
                    }
                  },
                  child: const Text('Check'),
                ),
              ],
            );
          },
        );
      },
    );
    return result ?? false;
  }

  void _fetchAlarmDetails() {
    // Since initState runs before the provider is fully ready in the build tree
    // when launched from a killed state, we can't reliably use Provider.of here.
    // We'll trust the build method to do the fetch or handle the crash gracefully.
    // However, for safety, let's keep the find logic in the build method
    // but use a try-catch for the initial rendering.
  }
  void _startAlarm() async {
    // Play custom sound from assets
    await _audioPlayer.play(AssetSource('alarm.mp3'), volume: 2.0);
    // Set to loop
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(pattern: [1000, 500, 1000, 500], repeat: 1);
    }
  }

  void _stopAlarm() {
    _audioPlayer.stop();
    Vibration.cancel();
  }

  String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AlarmProvider>(context, listen: false);
    Alarm? alarm;
    String displayLabel = "Alarm Ringing"; // Default display text

    // ⭐️ FIX 3: Gracefully find the alarm by ID, handle 'No element' crash
    try {
      alarm = provider.alarms.firstWhere(
        // widget.alarmLabel now holds the unique ID (from payload)
        (a) => a.id == widget.alarmLabel,
        orElse: () {
          // Return a dummy/null alarm if not found to prevent crash
          return provider.alarms.first;
        },
      );
      displayLabel = alarm.label;
    } catch (e) {
      // Handle crash if provider list is empty (should not happen if an alarm triggered it)
      print("Alarm not found or list empty: $e");
      alarm = null;
    }
    if (alarm == null) {
      return const Scaffold(
        backgroundColor: Colors.red,
        body: Center(
          child: Text(
            "Error: Alarm data missing.",
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.alarm, size: 100, color: Colors.red),
              const SizedBox(height: 30),

              Text(
                displayLabel,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              Text(
                _getCurrentTime(),
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                _getCurrentDate(),
                style: const TextStyle(fontSize: 20, color: Colors.grey),
              ),

              const SizedBox(height: 50),

              /// DISMISS
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final solved = await _showMathChallenge();
                    if (!solved) return; // user cancelled or failed

                    // correct answer: stop alarm and update provider
                    _stopAlarm();
                    provider.updateAlarm(alarm!.copyWith(isActive: false));

                    if (widget.fromNotification) {
                      if (widget.launchedFromNotification &&
                          !Navigator.canPop(context)) {
                        SystemNavigator.pop();
                      } else if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/home', (route) => false);
                      }
                    } else {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/home', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.done, size: 30),
                  label: const Text('DISMISS', style: TextStyle(fontSize: 20)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// SNOOZE
              SizedBox(
                width: double.infinity,
                height: 60,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _stopAlarm();

                    final snoozeTime = DateTime.now().add(
                      Duration(minutes: alarm!.snoozeDuration),
                    );

                    provider.updateAlarm(
                      alarm.copyWith(time: snoozeTime, isActive: true),
                    );

                    if (widget.fromNotification) {
                      if (widget.launchedFromNotification &&
                          !Navigator.canPop(context)) {
                        SystemNavigator.pop();
                      } else if (Navigator.canPop(context)) {
                        Navigator.of(context).pop();
                      } else {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/home', (route) => false);
                      }
                    } else {
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil('/home', (route) => false);
                    }
                  },
                  icon: const Icon(Icons.snooze, size: 30),
                  label: Text(
                    'SNOOZE (${alarm.snoozeDuration} MIN)',
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
