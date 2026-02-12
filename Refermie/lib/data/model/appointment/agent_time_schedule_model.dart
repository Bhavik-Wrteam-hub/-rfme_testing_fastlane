class AgentTimeScheduleModel {
  AgentTimeScheduleModel({
    required this.timeSchedules,
    required this.extraSlots,
  });

  factory AgentTimeScheduleModel.fromJson(Map<String, dynamic> json) {
    return AgentTimeScheduleModel(
      timeSchedules: (json['time_schedules'] as List<dynamic>? ?? [])
          .map((e) => TimeSchedule.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
      extraSlots: (json['extra_slots'] as List<dynamic>? ?? [])
          .map((e) => ExtraSlot.fromJson(e as Map<String, dynamic>? ?? {}))
          .toList(),
    );
  }
  final List<TimeSchedule> timeSchedules;
  final List<ExtraSlot> extraSlots;

  Map<String, dynamic> toJson() {
    return {
      'time_schedules': timeSchedules.map((e) => e.toJson()).toList(),
      'extra_slots': extraSlots.map((e) => e.toJson()).toList(),
    };
  }
}

class TimeSchedule {
  TimeSchedule({
    required this.id,
    required this.isAdminData,
    required this.agentId,
    required this.adminId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.appointmentCount,
  });

  factory TimeSchedule.fromJson(Map<String, dynamic> json) {
    return TimeSchedule(
      id: json['id']?.toString() ?? '',
      isAdminData: json['is_admin_data']?.toString() ?? '',
      agentId: json['agent_id']?.toString() ?? '',
      adminId: json['admin_id']?.toString() ?? '',
      dayOfWeek: json['day_of_week']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      isActive: json['is_active']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      appointmentCount: json['appointment_count']?.toString() ?? '0',
    );
  }
  final String id;
  final String isAdminData;
  final String agentId;
  final String adminId;
  final String dayOfWeek;
  final String startTime;
  final String endTime;
  final String isActive;
  final String createdAt;
  final String updatedAt;
  final String appointmentCount;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_admin_data': isAdminData,
      'agent_id': agentId,
      'admin_id': adminId,
      'day_of_week': dayOfWeek,
      'start_time': startTime,
      'end_time': endTime,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'appointment_count': appointmentCount,
    };
  }
}

class ExtraSlot {
  ExtraSlot({
    required this.id,
    required this.isAdminData,
    required this.agentId,
    required this.adminId,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.reason,
    required this.createdAt,
    required this.updatedAt,
    required this.appointmentCount,
  });

  factory ExtraSlot.fromJson(Map<String, dynamic> json) {
    return ExtraSlot(
      id: json['id']?.toString() ?? '',
      isAdminData: json['is_admin_data']?.toString() ?? '',
      agentId: json['agent_id']?.toString() ?? '',
      adminId: json['admin_id']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      endTime: json['end_time']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      appointmentCount: json['appointment_count']?.toString() ?? '0',
    );
  }
  final String id;
  final String isAdminData;
  final String agentId;
  final String adminId;
  final String date;
  final String startTime;
  final String endTime;
  final String reason;
  final String createdAt;
  final String updatedAt;
  final String appointmentCount;
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_admin_data': isAdminData,
      'agent_id': agentId,
      'admin_id': adminId,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'reason': reason,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'appointment_count': appointmentCount,
    };
  }
}
