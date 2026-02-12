class UnavailabilityModel {
  const UnavailabilityModel({
    required this.id,
    required this.agentId,
    required this.startDate,
    required this.endDate,
    required this.startTime,
    required this.endTime,
    required this.reason,
    required this.isRecurring,
    required this.recurringType,
    required this.createdAt,
    required this.updatedAt,
  });

  UnavailabilityModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int? ?? 0,
      agentId = json['agent_id']?.toString() ?? '',
      startDate = json['start_date']?.toString() ?? '',
      endDate = json['end_date']?.toString() ?? '',
      startTime = json['start_time']?.toString() ?? '',
      endTime = json['end_time']?.toString() ?? '',
      reason = json['reason']?.toString() ?? '',
      isRecurring = json['is_recurring'] as bool? ?? false,
      recurringType = json['recurring_type']?.toString() ?? '',
      createdAt = json['created_at']?.toString() ?? '',
      updatedAt = json['updated_at']?.toString() ?? '';

  final int id;
  final String agentId;
  final String startDate;
  final String endDate;
  final String startTime;
  final String endTime;
  final String reason;
  final bool isRecurring;
  final String recurringType;
  final String createdAt;
  final String updatedAt;

  UnavailabilityModel copyWith({
    int? id,
    String? agentId,
    String? startDate,
    String? endDate,
    String? startTime,
    String? endTime,
    String? reason,
    bool? isRecurring,
    String? recurringType,
    String? createdAt,
    String? updatedAt,
  }) => UnavailabilityModel(
    id: id ?? this.id,
    agentId: agentId ?? this.agentId,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    reason: reason ?? this.reason,
    isRecurring: isRecurring ?? this.isRecurring,
    recurringType: recurringType ?? this.recurringType,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
}
