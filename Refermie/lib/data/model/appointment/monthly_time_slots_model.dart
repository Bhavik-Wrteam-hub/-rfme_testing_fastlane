class MonthlyTimeSlotsModel {
  MonthlyTimeSlotsModel({
    required this.agentId,
    required this.month,
    required this.year,
    required this.timezone,
    required this.agentTimezone,
    required this.days,
    required this.availableMeetingTypes,
  });

  factory MonthlyTimeSlotsModel.fromJson(Map<String, dynamic> json) {
    final parsedDays = <String, List<TimeSlot>>{};
    if (json['days'] != null) {
      (json['days'] as Map<String, dynamic>? ?? {}).forEach((date, slots) {
        parsedDays[date] = (slots as List<dynamic>? ?? [])
            .map(
              (slot) => TimeSlot.fromJson(slot as Map<String, dynamic>? ?? {}),
            )
            .toList();
      });
    }

    return MonthlyTimeSlotsModel(
      agentId: json['agent_id']?.toString() ?? '',
      month: json['month']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? '',
      agentTimezone: json['agent_timezone']?.toString() ?? '',
      days: parsedDays,
      availableMeetingTypes: json['availability_types']?.toString() ?? '',
    );
  }
  final String agentId;
  final String month;
  final String year;
  final String timezone;
  final String agentTimezone;
  final Map<String, List<TimeSlot>> days;
  final String availableMeetingTypes;

  Map<String, dynamic> toJson() {
    final jsonDays = <String, dynamic>{};
    days.forEach((date, slots) {
      jsonDays[date] = slots.map((slot) => slot.toJson()).toList();
    });

    return {
      'agent_id': agentId,
      'month': month,
      'year': year,
      'timezone': timezone,
      'agent_timezone': agentTimezone,
      'days': jsonDays,
      'availability_types': availableMeetingTypes,
    };
  }
}

class TimeSlot {
  TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.startAt,
    required this.endAt,
    required this.availableMeetingTypes,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      startAt: json['start_at']?.toString() ?? '',
      endAt: json['end_at']?.toString() ?? '',
      availableMeetingTypes: json['availability_types']?.toString() ?? '',
    );
  }
  final String startTime;
  final String endTime;
  final String startAt;
  final String endAt;
  final String availableMeetingTypes;

  Map<String, dynamic> toJson() {
    return {
      'start_time': startTime,
      'end_time': endTime,
      'start_at': startAt,
      'end_at': endAt,
      'availability_types': availableMeetingTypes,
    };
  }
}
