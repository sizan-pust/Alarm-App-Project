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

    if (await Vibration.hasVibrator() == true) {
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
    final dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final dayName = dayNames[now.weekday - 1];
    final monthName = monthNames[now.month - 1];
    return '$dayName, ${now.day} $monthName';
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AlarmProvider>(context, listen: false);
    Alarm? alarm;

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
    // Figma-like ringing UI: gradient background, large time, date and small icon,
    // centered prompt, snooze small button, and large dismiss button at bottom.
    final mq = MediaQuery.of(context);
    final timeFontSize = mq.size.width * 0.20; // responsive large time
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFF6B9D), // vibrant pink
              Color(0xFFE0488E), // darker pink/magenta
              Color(0xFFC837AB), // purple
              Color(0xFF5E72E4), // blue
            ],
            stops: [0.0, 0.35, 0.65, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Top row: small icon and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.wb_sunny_outlined,
                      size: 24,
                      color: Colors.white70,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getCurrentDate(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Large time
                Text(
                  _getCurrentTime(),
                  style: TextStyle(
                    fontFamily: 'SF Pro Display',
                    fontSize: timeFontSize,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 0.9,
                  ),
                ),

                const SizedBox(height: 16),

                // Title / prompt
                const Text(
                  'Wake up!',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 32),

                // Small centered snooze button
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.25),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    // Keep original snooze behavior
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
                  child: const Text(
                    'Snooze',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),

                const Spacer(),

                // Bottom large dismiss button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final solved = await _showMathChallenge();
                      if (!solved) return;

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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF6C84C),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Dismiss',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
