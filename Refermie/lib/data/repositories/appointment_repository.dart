import 'package:ebroker/data/model/appointment/agent_time_schedule_model.dart';
import 'package:ebroker/data/model/appointment/appointment_model.dart';
import 'package:ebroker/data/model/appointment/availability_model.dart';
import 'package:ebroker/data/model/appointment/booking_preferences_model.dart';
import 'package:ebroker/data/model/appointment/extra_time_slot_model.dart';
import 'package:ebroker/data/model/appointment/monthly_time_slots_model.dart';
import 'package:ebroker/data/model/appointment/unavailability_model.dart';
import 'package:ebroker/data/model/appointment/user_report_model.dart';
import 'package:ebroker/data/model/data_output.dart';
import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/constant.dart';

class AppointmentRepository {
  // GET APIs
  Future<MonthlyTimeSlotsModel> getMonthlyTimeSlots({
    required String year,
    required String month,
    required String agentId,
    required bool isAdmin,
  }) async {
    final response = await Api.get(
      url: Api.getMonthlyTimeSlots,
      queryParameters: {
        'year': year,
        'month': month,
        'agent_id': isAdmin ? '0' : agentId,
      },
    );
    return MonthlyTimeSlotsModel.fromJson(
      response['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Future<AvailabilityModel> checkAvailability({
    required String agentId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    final response = await Api.get(
      url: Api.checkAvailability,
      queryParameters: {
        'agent_id': agentId,
        'date': date,
        'start_time': startTime,
        'end_time': endTime,
      },
    );
    return AvailabilityModel.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<DataOutput<AppointmentModel>> getUserAppointments({
    required int offset,
    required String dateFilter,
    String? meetingType,
    String? status,
  }) async {
    final queryParams = {
      Api.limit: Constant.loadLimit,
      Api.offset: offset,
      'date_filter': dateFilter,
    };
    
    // Add optional filters if provided
    if (meetingType != null && meetingType.isNotEmpty) {
      queryParams['meeting_type'] = meetingType;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    
    final response = await Api.get(
      url: Api.getUserAppointments,
      queryParameters: queryParams,
    );
    final modelList = (response['data'] as List)
        .map<AppointmentModel>(
          (e) => AppointmentModel.fromJson(Map.from(e as Map? ?? {})),
        )
        .toList();
    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<DataOutput<AppointmentModel>> getAgentAppointments({
    required int offset,
    required String dateFilter,
    String? meetingType,
    String? status,
  }) async {
    final queryParams = {
      Api.limit: Constant.loadLimit,
      Api.offset: offset,
      'date_filter': dateFilter,
    };
    
    // Add optional filters if provided
    if (meetingType != null && meetingType.isNotEmpty) {
      queryParams['meeting_type'] = meetingType;
    }
    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }
    
    final response = await Api.get(
      url: Api.getAgentAppointments,
      queryParameters: queryParams,
    );
    if (response['data'] == null) {
      return DataOutput(
        total: 0,
        modelList: [],
      );
    }
    final modelList = (response['data'] as List)
        .map<AppointmentModel>(
          (e) => AppointmentModel.fromJson(Map.from(e as Map? ?? {})),
        )
        .toList();
    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<BookingPreferencesModel> getBookingPreferences() async {
    final response = await Api.get(
      url: Api.getBookingPreferences,
    );
    return BookingPreferencesModel.fromJson(
      response['data'] as Map<String, dynamic>? ?? {},
    );
  }

  Future<AgentTimeScheduleModel> getAgentTimeSchedules() async {
    final response = await Api.get(
      url: Api.getAgentTimeSchedules,
      queryParameters: {
        Api.limit: Constant.loadLimit,
      },
    );
    final result = AgentTimeScheduleModel.fromJson(
      response['data'] as Map<String, dynamic>? ?? {},
    );
    return result;
  }

  Future<DataOutput<UnavailabilityModel>> getUnavailabilityData() async {
    final response = await Api.get(
      url: Api.getUnavailabilityData,
      queryParameters: {
        Api.limit: Constant.loadLimit,
      },
    );
    final modelList = (response['data'] as List)
        .map<UnavailabilityModel>(
          (e) => UnavailabilityModel.fromJson(Map.from(e as Map? ?? {})),
        )
        .toList();
    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<DataOutput<ExtraTimeSlotModel>> getExtraTimeSlots() async {
    final response = await Api.get(
      url: Api.getExtraTimeSlots,
      queryParameters: {
        Api.limit: Constant.loadLimit,
      },
    );
    final modelList = (response['data'] as List)
        .map<ExtraTimeSlotModel>(
          (e) => ExtraTimeSlotModel.fromJson(Map.from(e as Map? ?? {})),
        )
        .toList();
    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  Future<DataOutput<UserReportModel>> getUserReports() async {
    final response = await Api.get(
      url: Api.getUserReports,
    );

    final modelList = (response['data'] as List)
        .map<UserReportModel>(
          (e) => UserReportModel.fromJson(Map.from(e as Map? ?? {})),
        )
        .toList();
    return DataOutput(
      total: int.parse(response['total']?.toString() ?? '0'),
      modelList: modelList,
    );
  }

  // POST APIs
  Future<Map<String, dynamic>> createAppointmentRequest({
    required String propertyId,
    required String meetingType,
    required String date,
    required String startTime,
    required String endTime,
    required String notes,
  }) async {
    final parameters = {
      'property_id': propertyId,
      'meeting_type': meetingType,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
      'notes': notes,
    };
    return Api.post(url: Api.postAppointmentRequest, parameter: parameters);
  }

  Future<Map<String, dynamic>> updateAppointmentStatus({
    required String appointmentId,
    required String status,
    required String reason,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    // allowed status are confirmed,cancelled,rescheduled, Reason is only required for cancelled and rescheduled
    final parameters = {
      'appointment_id': appointmentId,
      'status': status,
      'reason': reason,
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
    }..removeWhere((key, value) => value == '');
    return Api.post(url: Api.updateAppointmentStatus, parameter: parameters);
  }

  Future<Map<String, dynamic>> updateMeetingType({
    required String appointmentId,
    required String meetingType,
  }) async {
    final parameters = {
      'appointment_id': appointmentId,
      'meeting_type': meetingType,
    };
    return Api.post(url: Api.updateMeetingType, parameter: parameters);
  }

  Future<Map<String, dynamic>> updateBookingPreferences({
    required String meetingDurationMinutes,
    required String leadTimeMinutes,
    required String bufferTimeMinutes,
    required String autoConfirm,
    required String cancelRescheduleBufferMinutes,
    required String autoCancelAfterMinutes,
    required String autoCancelMessage,
    required String dailyBookingLimit,
    required String availableMeetingTypes,
    required String antiSpamEnabled,
    required String timezone,
  }) async {
    final parameters = {
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
    };
    return Api.post(url: Api.postBookingPreferences, parameter: parameters);
  }

  Future<Map<String, dynamic>> setAgentTimeSchedule({
    required Map<String, dynamic> parameters,
  }) async {
    return Api.post(url: Api.setAgentTimeSchedule, parameter: parameters);
  }

  Future<Map<String, dynamic>> updateAgentTimeSchedules({
    required Map<String, dynamic> parameters,
  }) async {
    return Api.post(url: Api.postAgentTimeSchedules, parameter: parameters);
  }

  Future<Map<String, dynamic>> addUnavailability({
    required String date,
    required String typeOfUnavailability,
    required String startTime,
    required String endTime,
    required String reason,
  }) async {
    final parameters = {
      'date': date,
      'type_of_unavailability': typeOfUnavailability,
      'start_time': startTime,
      'end_time': endTime,
      'reason': reason,
    };
    return Api.post(url: Api.addUnavailability, parameter: parameters);
  }

  Future<Map<String, dynamic>> manageExtraTimeSlots({
    required Map<String, dynamic> parameters,
  }) async {
    parameters.removeWhere((key, value) => value == '');
    return Api.post(url: Api.manageExtraTimeSlots, parameter: parameters);
  }

  Future<Map<String, dynamic>> reportUser({
    required String userId,
    required String reason,
  }) async {
    final parameters = {
      'user_id': userId,
      'reason': reason,
    };
    return Api.post(url: Api.reportUser, parameter: parameters);
  }

  // DELETE APIs
  Future<Map<String, dynamic>> deleteUnavailability({
    required String unavailabilityId,
  }) async {
    return Api.delete(
      url: '${Api.deleteUnavailability}?unavailability_id=$unavailabilityId',
    );
  }

  Future<Map<String, dynamic>> deleteExtraTimeSlot({
    required Map<String, dynamic> parameters,
  }) async {
    return Api.post(
      url: Api.deleteExtraTimeSlot,
      parameter: parameters,
    );
  }
}
