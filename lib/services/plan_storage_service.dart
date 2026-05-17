import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/time_slot_plan.dart';

class PlanStorageService {
  static const _plansPrefix = 'day_planner_plan_';

  Future<String?> getPlanText(String dateKey, String timeLabel) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_plansPrefix$dateKey|$timeLabel');
  }

  Future<bool> getReminderEnabled(String dateKey, String timeLabel) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('${_plansPrefix}reminder_$dateKey|$timeLabel') ?? false;
  }

  Future<void> savePlan(TimeSlotPlan plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_plansPrefix${plan.dateKey}|${plan.timeLabel}',
      plan.text,
    );
    await prefs.setBool(
      '${_plansPrefix}reminder_${plan.dateKey}|${plan.timeLabel}',
      plan.reminderEnabled,
    );
  }

  Future<Map<String, String>> loadPlansForDate(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, String>{};
    for (final key in prefs.getKeys()) {
      if (key.startsWith(_plansPrefix) && key.contains(dateKey)) {
        if (key.contains('reminder_')) continue;
        final timeLabel = key.replaceFirst('$_plansPrefix', '').split('|').last;
        result[timeLabel] = prefs.getString(key) ?? '';
      }
    }
    return result;
  }

  Future<Map<String, bool>> loadRemindersForDate(String dateKey) async {
    final prefs = await SharedPreferences.getInstance();
    final result = <String, bool>{};
    for (final key in prefs.getKeys()) {
      if (key.startsWith('${_plansPrefix}reminder_') && key.contains(dateKey)) {
        final timeLabel = key.split('|').last;
        result[timeLabel] = prefs.getBool(key) ?? false;
      }
    }
    return result;
  }
}
