class ExtraTimeSlotModel {
  ExtraTimeSlotModel({
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
  });

  factory ExtraTimeSlotModel.fromJson(Map<String, dynamic> json) {
    return ExtraTimeSlotModel(
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
    };
  }
}
