class TimeSlotPlan {
  const TimeSlotPlan({
    required this.dateKey,
    required this.timeLabel,
    required this.text,
    this.reminderEnabled = false,
  });

  final String dateKey;
  final String timeLabel;
  final String text;
  final bool reminderEnabled;

  String get storageKey => '$dateKey|$timeLabel';

  TimeSlotPlan copyWith({
    String? text,
    bool? reminderEnabled,
  }) =>
      TimeSlotPlan(
        dateKey: dateKey,
        timeLabel: timeLabel,
        text: text ?? this.text,
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      );

  Map<String, dynamic> toJson() => {
        'dateKey': dateKey,
        'timeLabel': timeLabel,
        'text': text,
        'reminderEnabled': reminderEnabled,
      };

  factory TimeSlotPlan.fromJson(Map<String, dynamic> json) => TimeSlotPlan(
        dateKey: json['dateKey'] as String,
        timeLabel: json['timeLabel'] as String,
        text: json['text'] as String? ?? '',
        reminderEnabled: json['reminderEnabled'] as bool? ?? false,
      );
}
