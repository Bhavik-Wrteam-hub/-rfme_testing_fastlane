import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateBookingPreferencesState {}

class UpdateBookingPreferencesInitial extends UpdateBookingPreferencesState {}

class UpdateBookingPreferencesInProgress
    extends UpdateBookingPreferencesState {}

class UpdateBookingPreferencesSuccess extends UpdateBookingPreferencesState {
  UpdateBookingPreferencesSuccess(this.response);
  final Map<String, dynamic> response;
}

class UpdateBookingPreferencesFailure extends UpdateBookingPreferencesState {
  UpdateBookingPreferencesFailure(this.errorMessage);
  final String errorMessage;
}

class UpdateBookingPreferencesCubit
    extends Cubit<UpdateBookingPreferencesState> {
  UpdateBookingPreferencesCubit() : super(UpdateBookingPreferencesInitial());
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> updateBookingPreferences({
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
    try {
      emit(UpdateBookingPreferencesInProgress());
      final result = await _appointmentRepository.updateBookingPreferences(
        meetingDurationMinutes: meetingDurationMinutes,
        leadTimeMinutes: leadTimeMinutes,
        bufferTimeMinutes: bufferTimeMinutes,
        autoConfirm: autoConfirm,
        cancelRescheduleBufferMinutes: cancelRescheduleBufferMinutes,
        autoCancelAfterMinutes: autoCancelAfterMinutes,
        autoCancelMessage: autoCancelMessage,
        dailyBookingLimit: dailyBookingLimit,
        availableMeetingTypes: availableMeetingTypes,
        antiSpamEnabled: antiSpamEnabled,
        timezone: timezone,
      );

      if (result['error'] == false) {
        emit(UpdateBookingPreferencesSuccess(result));
      } else {
        emit(UpdateBookingPreferencesFailure(result['message'].toString()));
      }
    } on ApiException catch (e) {
      emit(UpdateBookingPreferencesFailure(e.toString()));
    }
  }
}
