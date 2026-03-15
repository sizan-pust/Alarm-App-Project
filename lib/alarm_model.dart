//alarm_model.dart
import 'package:intl/intl.dart';

class Alarm {
  String id;
  DateTime time;
  bool isActive;
  String label;
  List<int> repeatDays; // 1-7 for Monday-Sunday
  bool vibrate;
  int snoozeDuration; // in minutes

  Alarm({
    required this.id,
    required this.time,
    this.isActive = true,
    this.label = 'Alarm',
    this.repeatDays = const [],
    this.vibrate = true,
    this.snoozeDuration = 5,
  });

  factory Alarm.fromMap(Map<String, dynamic> map) {
    return Alarm(
      id: map['id'],
      time: DateTime.parse(map['time']),
      isActive: map['isActive'],
      label: map['label'],
      repeatDays: List<int>.from(map['repeatDays']),
      vibrate: map['vibrate'],
      snoozeDuration: map['snoozeDuration'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'time': time.toIso8601String(),
      'isActive': isActive,
      'label': label,
      'repeatDays': repeatDays,
      'vibrate': vibrate,
      'snoozeDuration': snoozeDuration,
    };
  }

  Alarm copyWith({
    String? id,
    DateTime? time,
    bool? isActive,
    String? label,
    List<int>? repeatDays,
    bool? vibrate,
    int? snoozeDuration,
  }) {
    return Alarm(
      id: id ?? this.id,
      time: time ?? this.time,
      isActive: isActive ?? this.isActive,
      label: label ?? this.label,
      repeatDays: repeatDays ?? this.repeatDays,
      vibrate: vibrate ?? this.vibrate,
      snoozeDuration: snoozeDuration ?? this.snoozeDuration,
    );
  }

  String get formattedTime {
    return DateFormat('h:mm a').format(time);
  }

  String get dayPeriod {
    return DateFormat('a').format(time);
  }

  String get repeatText {
    if (repeatDays.isEmpty) return 'Never';
    if (repeatDays.length == 7) return 'Every day';
    if (Set.from(repeatDays).containsAll([1, 2, 3, 4, 5]) &&
        repeatDays.length == 5) {
      return 'Weekdays';
    }
    if (Set.from(repeatDays).containsAll([6, 7]) && repeatDays.length == 2) {
      return 'Weekends';
    }

    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return repeatDays.map((day) => days[day - 1]).join(', ');
  }
}
