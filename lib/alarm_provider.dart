//alarm_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'alarm_model.dart';
import 'notification_helper.dart';

class AlarmProvider extends ChangeNotifier {
  List<Alarm> _alarms = [];
  List<Alarm> get alarms => _alarms;
  Future<void> initialize() async {
    // Example: load from SharedPreferences or other storage
    // This is the line that takes time!
    // await _loadAlarmsFromPersistence();

    // Notify listeners once data is loaded
    notifyListeners();
  }

  AlarmProvider() {
    _loadAlarms();
  }

  Future<void> _loadAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = prefs.getStringList('alarms') ?? [];

    _alarms = alarmsJson
        .map((json) => Alarm.fromMap(jsonDecode(json)))
        .toList();

    _alarms.sort((a, b) => a.time.compareTo(b.time));
    notifyListeners();
  }

  Future<void> _saveAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    final alarmsJson = _alarms
        .map((alarm) => jsonEncode(alarm.toMap()))
        .toList();
    await prefs.setStringList('alarms', alarmsJson);
    notifyListeners();
  }

  Future<void> addAlarm(Alarm alarm) async {
    _alarms.add(alarm);
    await _saveAlarms();
    await NotificationHelper.scheduleAlarm(alarm);
    notifyListeners();
  }

  Future<void> updateAlarm(Alarm updatedAlarm) async {
    final index = _alarms.indexWhere((alarm) => alarm.id == updatedAlarm.id);
    if (index != -1) {
      _alarms[index] = updatedAlarm;
      await _saveAlarms();
      await NotificationHelper.cancelAlarm(updatedAlarm.id);
      if (updatedAlarm.isActive) {
        await NotificationHelper.scheduleAlarm(updatedAlarm);
      }
    }
  }

  Future<void> deleteAlarm(String id) async {
    _alarms.removeWhere((alarm) => alarm.id == id);
    await _saveAlarms();
    await NotificationHelper.cancelAlarm(id);
    notifyListeners();
  }

  Future<void> toggleAlarm(String id) async {
    final index = _alarms.indexWhere((alarm) => alarm.id == id);
    if (index != -1) {
      final alarm = _alarms[index];
      final updatedAlarm = alarm.copyWith(isActive: !alarm.isActive);
      _alarms[index] = updatedAlarm;
      await _saveAlarms();

      if (updatedAlarm.isActive) {
        await NotificationHelper.scheduleAlarm(updatedAlarm);
      } else {
        await NotificationHelper.cancelAlarm(id);
      }
      notifyListeners();
    }
  }

  Alarm? getAlarmById(String id) {
    return _alarms.firstWhere((alarm) => alarm.id == id);
  }
}
