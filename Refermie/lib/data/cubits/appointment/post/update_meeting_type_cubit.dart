import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateMeetingTypeState {}

class UpdateMeetingTypeInitial extends UpdateMeetingTypeState {}

class UpdateMeetingTypeInProgress extends UpdateMeetingTypeState {}

class UpdateMeetingTypeSuccess extends UpdateMeetingTypeState {
  UpdateMeetingTypeSuccess(this.response);
  final Map<String, dynamic> response;
}

class UpdateMeetingTypeFailure extends UpdateMeetingTypeState {
  UpdateMeetingTypeFailure(this.errorMessage);
  final String errorMessage;
}

class UpdateMeetingTypeCubit extends Cubit<UpdateMeetingTypeState> {
  UpdateMeetingTypeCubit() : super(UpdateMeetingTypeInitial());
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> updateMeetingType({
    required String appointmentId,
    required String meetingType,
  }) async {
    try {
      emit(UpdateMeetingTypeInProgress());
      final result = await _appointmentRepository.updateMeetingType(
        appointmentId: appointmentId,
        meetingType: meetingType,
      );

      if (result['error'] == false) {
        emit(UpdateMeetingTypeSuccess(result));
      } else {
        emit(UpdateMeetingTypeFailure(result['message'].toString()));
      }
    } on ApiException catch (e) {
      emit(UpdateMeetingTypeFailure(e.toString()));
    }
  }
}
