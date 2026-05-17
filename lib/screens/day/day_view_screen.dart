import 'package:flutter/material.dart';

import '../../models/time_slot_plan.dart';
import '../../services/notification_service.dart';
import '../../services/plan_storage_service.dart';
import '../../theme/app_theme.dart';
import '../../utils/timeline_utils.dart';

class DayViewScreen extends StatefulWidget {
  const DayViewScreen({super.key, required this.selectedDate});

  final DateTime selectedDate;

  @override
  State<DayViewScreen> createState() => _DayViewScreenState();
}

class _DayViewScreenState extends State<DayViewScreen> {
  final _storage = PlanStorageService();
  final _notifications = NotificationService.instance;
  final _slots = generateDayTimelineLabels();
  final _controllers = <String, TextEditingController>{};
  final _reminderEnabled = <String, bool>{};
  final _saved = <String, bool>{};

  bool _loading = true;
  late String _dateKey;

  @override
  void initState() {
    super.initState();
    _dateKey = dateStorageKey(widget.selectedDate);
    for (final label in _slots) {
      _controllers[label] = TextEditingController();
      _reminderEnabled[label] = false;
      _saved[label] = false;
    }
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final texts = await _storage.loadPlansForDate(_dateKey);
    final reminders = await _storage.loadRemindersForDate(_dateKey);
    if (!mounted) return;
    setState(() {
      for (final label in _slots) {
        _controllers[label]?.text = texts[label] ?? '';
        _reminderEnabled[label] = reminders[label] ?? false;
        _saved[label] = (texts[label] ?? '').isNotEmpty;
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveSlot(String timeLabel) async {
    final text = _controllers[timeLabel]?.text.trim() ?? '';
    final reminder = _reminderEnabled[timeLabel] ?? false;

    final plan = TimeSlotPlan(
      dateKey: _dateKey,
      timeLabel: timeLabel,
      text: text,
      reminderEnabled: reminder,
    );

    await _storage.savePlan(plan);

    final notificationId =
        _notifications.notificationIdForSlot(_dateKey, timeLabel);

    if (reminder && text.isNotEmpty) {
      final slotTime =
          _notifications.slotDateTime(widget.selectedDate, timeLabel);
      if (slotTime != null) {
        final scheduled = await _notifications.scheduleSlotReminder(
          notificationId: notificationId,
          scheduledAt: slotTime,
          title: 'Day Planner',
          body: text,
          payload: '$_dateKey|$timeLabel',
        );
        if (!scheduled && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Could not schedule reminder (time may have passed or permissions needed).',
              ),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } else {
      await _notifications.cancelReminder(notificationId);
    }

    if (!mounted) return;
    setState(() => _saved[timeLabel] = text.isNotEmpty);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(reminder ? 'Saved with reminder' : 'Plan saved'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          formatDateHeader(widget.selectedDate),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              itemCount: _slots.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.notifications_active_outlined,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Enable the bell on a slot to schedule a reminder when that time arrives.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final timeLabel = _slots[index - 1];
                final controller = _controllers[timeLabel]!;
                final hasReminder = _reminderEnabled[timeLabel] ?? false;
                final isSaved = _saved[timeLabel] ?? false;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 76,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 14),
                          child: Text(
                            timeLabel,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textMuted,
                              fontFeatures: const [],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextField(
                          controller: controller,
                          maxLines: 2,
                          minLines: 1,
                          decoration: InputDecoration(
                            hintText: 'What\'s the plan?',
                            suffixIcon: IconButton(
                              icon: Icon(
                                hasReminder
                                    ? Icons.notifications_active
                                    : Icons.notifications_none_outlined,
                                color: hasReminder
                                    ? theme.colorScheme.primary
                                    : AppColors.textMuted,
                              ),
                              tooltip: 'Toggle reminder',
                              onPressed: () {
                                setState(() {
                                  _reminderEnabled[timeLabel] = !hasReminder;
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton.filled(
                        onPressed: () => _saveSlot(timeLabel),
                        icon: Icon(
                          isSaved ? Icons.check_rounded : Icons.save_outlined,
                        ),
                        tooltip: 'Save',
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
