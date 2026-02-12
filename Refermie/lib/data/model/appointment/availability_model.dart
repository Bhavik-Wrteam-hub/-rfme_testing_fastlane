class AvailabilityModel {
  const AvailabilityModel({
    required this.agentId,
    required this.date,
    required this.timeSlot,
    required this.isAvailable,
    required this.reason,
  });

  AvailabilityModel.fromJson(Map<String, dynamic> json)
    : agentId = json['agent_id']?.toString() ?? '',
      date = json['date']?.toString() ?? '',
      timeSlot = json['time_slot']?.toString() ?? '',
      isAvailable = json['is_available'] as bool? ?? false,
      reason = json['reason']?.toString() ?? '';

  final String agentId;
  final String date;
  final String timeSlot;
  final bool isAvailable;
  final String reason;

  AvailabilityModel copyWith({
    String? agentId,
    String? date,
    String? timeSlot,
    bool? isAvailable,
    String? reason,
  }) => AvailabilityModel(
    agentId: agentId ?? this.agentId,
    date: date ?? this.date,
    timeSlot: timeSlot ?? this.timeSlot,
    isAvailable: isAvailable ?? this.isAvailable,
    reason: reason ?? this.reason,
  );
}
