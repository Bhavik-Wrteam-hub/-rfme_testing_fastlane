class BookingPreferencesModel {
  BookingPreferencesModel({
    required this.id,
    required this.isAdminData,
    required this.agentId,
    required this.adminId,
    required this.meetingDurationMinutes,
    required this.leadTimeMinutes,
    required this.bufferTimeMinutes,
    required this.autoConfirm,
    required this.cancelRescheduleBufferMinutes,
    required this.autoCancelAfterMinutes,
    required this.autoCancelMessage,
    required this.dailyBookingLimit,
    required this.availableMeetingTypes,
    required this.antiSpamEnabled,
    required this.timezone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BookingPreferencesModel.fromJson(Map<String, dynamic> json) {
    return BookingPreferencesModel(
      id: json['id']?.toString() ?? '',
      isAdminData: json['is_admin_data']?.toString() ?? '',
      agentId: json['agent_id']?.toString() ?? '',
      adminId: json['admin_id']?.toString() ?? '',
      meetingDurationMinutes:
          json['meeting_duration_minutes']?.toString() ?? '',
      leadTimeMinutes: json['lead_time_minutes']?.toString() ?? '',
      bufferTimeMinutes: json['buffer_time_minutes']?.toString() ?? '',
      autoConfirm: json['auto_confirm']?.toString() ?? '',
      cancelRescheduleBufferMinutes:
          json['cancel_reschedule_buffer_minutes']?.toString() ?? '',
      autoCancelAfterMinutes:
          json['auto_cancel_after_minutes']?.toString() ?? '',
      autoCancelMessage: json['auto_cancel_message']?.toString() ?? '',
      dailyBookingLimit: json['daily_booking_limit']?.toString() ?? '',
      availableMeetingTypes: json['availability_types']?.toString() ?? '',
      antiSpamEnabled: json['anti_spam_enabled']?.toString() ?? '',
      timezone: json['timezone']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }
  final String id;
  final String isAdminData;
  final String agentId;
  final String adminId;
  final String meetingDurationMinutes;
  final String leadTimeMinutes;
  final String bufferTimeMinutes;
  final String autoConfirm;
  final String cancelRescheduleBufferMinutes;
  final String autoCancelAfterMinutes;
  final String autoCancelMessage;
  final String dailyBookingLimit;
  final String availableMeetingTypes;
  final String antiSpamEnabled;
  final String timezone;
  final String createdAt;
  final String updatedAt;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_admin_data': isAdminData,
      'agent_id': agentId,
      'admin_id': adminId,
      'meeting_duration_minutes': meetingDurationMinutes,
      'lead_time_minutes': leadTimeMinutes,
      'buffer_time_minutes': bufferTimeMinutes,
      'auto_confirm': autoConfirm,
      'cancel_reschedule_buffer_minutes': cancelRescheduleBufferMinutes,
      'auto_cancel_after_minutes': autoCancelAfterMinutes,
      'auto_cancel_message': autoCancelMessage,
      'daily_booking_limit': dailyBookingLimit,
      'availability_types': availableMeetingTypes,
      'anti_spam_enabled': antiSpamEnabled,
      'timezone': timezone,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
