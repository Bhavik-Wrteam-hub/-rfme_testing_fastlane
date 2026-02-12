import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/model/user_model.dart';

class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.isAdminAppointment,
    required this.userId,
    required this.propertyId,
    required this.meetingType,
    required this.availableMeetingTypes,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.isAutoConfirmed,
    required this.lastStatusUpdatedBy,
    required this.notes,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
    this.adminId,
    this.agentId,
    this.reason,
    this.agent,
    this.user,
    this.property,
  });

  AppointmentModel.fromJson(Map<String, dynamic> json)
    : id = json['id'] as int? ?? 0,
      isAdminAppointment = json['is_admin_appointment']?.toString() ?? '0',
      adminId = json['admin_id']?.toString() ?? '',
      agentId = json['agent_id']?.toString() ?? '',
      userId = json['user_id']?.toString() ?? '',
      propertyId = json['property_id']?.toString() ?? '',
      meetingType = json['meeting_type']?.toString() ?? '',
      availableMeetingTypes = json['availability_types']?.toString() ?? '',
      startAt = json['start_at']?.toString() ?? '',
      endAt = json['end_at']?.toString() ?? '',
      status = json['status']?.toString() ?? '',
      isAutoConfirmed = json['is_auto_confirmed']?.toString() ?? '0',
      lastStatusUpdatedBy = json['last_status_updated_by']?.toString() ?? '',
      notes = json['notes']?.toString() ?? '',
      date = json['date']?.toString() ?? '',
      createdAt = json['created_at']?.toString() ?? '',
      updatedAt = json['updated_at']?.toString() ?? '',
      reason = json['reason']?.toString() ?? '',
      user = json['user'] != null
          ? UserModel.fromJson(json['user'] as Map<String, dynamic>? ?? {})
          : null,
      agent = json['agent'] != null
          ? UserModel.fromJson(json['agent'] as Map<String, dynamic>? ?? {})
          : json['admin'] != null
          ? UserModel.fromJson(json['admin'] as Map<String, dynamic>? ?? {})
          : null,
      property = json['property'] != null
          ? PropertyModel.fromMap(
              json['property'] as Map<String, dynamic>? ?? {},
            )
          : null;

  final int id;
  final String isAdminAppointment;
  final String? adminId;
  final String? agentId;
  final String userId;
  final String propertyId;
  final String meetingType;
  final String availableMeetingTypes;
  final String startAt;
  final String endAt;
  final String status;
  final String isAutoConfirmed;
  final String lastStatusUpdatedBy;
  final String notes;
  final String date;
  final String createdAt;
  final String updatedAt;
  final String? reason;
  final UserModel? user;
  final PropertyModel? property;
  final UserModel? agent;
  AppointmentModel copyWith({
    int? id,
    String? isAdminAppointment,
    String? adminId,
    String? agentId,
    String? userId,
    String? propertyId,
    String? meetingType,
    String? availableMeetingTypes,
    String? startAt,
    String? endAt,
    String? status,
    String? isAutoConfirmed,
    String? lastStatusUpdatedBy,
    String? notes,
    String? date,
    String? createdAt,
    String? updatedAt,
    String? reason,
    UserModel? user,
    PropertyModel? property,
    UserModel? agent,
  }) => AppointmentModel(
    id: id ?? this.id,
    isAdminAppointment: isAdminAppointment ?? this.isAdminAppointment,
    adminId: adminId ?? this.adminId,
    agentId: agentId ?? this.agentId,
    userId: userId ?? this.userId,
    propertyId: propertyId ?? this.propertyId,
    meetingType: meetingType ?? this.meetingType,
    availableMeetingTypes: availableMeetingTypes ?? this.availableMeetingTypes,
    startAt: startAt ?? this.startAt,
    endAt: endAt ?? this.endAt,
    status: status ?? this.status,
    isAutoConfirmed: isAutoConfirmed ?? this.isAutoConfirmed,
    lastStatusUpdatedBy: lastStatusUpdatedBy ?? this.lastStatusUpdatedBy,
    notes: notes ?? this.notes,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    reason: reason ?? this.reason,
    user: user ?? this.user,
    property: property ?? this.property,
    agent: agent ?? this.agent,
  );
}
