import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CreateAppointmentRequestState {}

class CreateAppointmentRequestInitial extends CreateAppointmentRequestState {}

class CreateAppointmentRequestInProgress
    extends CreateAppointmentRequestState {}

class CreateAppointmentRequestSuccess extends CreateAppointmentRequestState {
  CreateAppointmentRequestSuccess(this.response);
  final Map<String, dynamic> response;
}

class CreateAppointmentRequestFailure extends CreateAppointmentRequestState {
  CreateAppointmentRequestFailure(this.errorMessage);
  final String errorMessage;
}

class CreateAppointmentRequestCubit
    extends Cubit<CreateAppointmentRequestState> {
  CreateAppointmentRequestCubit() : super(CreateAppointmentRequestInitial());
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> createAppointmentRequest({
    required String propertyId,
    required String meetingType,
    required String date,
    required String startTime,
    required String endTime,
    required String notes,
  }) async {
    try {
      emit(CreateAppointmentRequestInProgress());
      final result = await _appointmentRepository.createAppointmentRequest(
        propertyId: propertyId,
        meetingType: meetingType,
        date: date,
        startTime: startTime,
        endTime: endTime,
        notes: notes,
      );

      if (result['error'] == false) {
        emit(CreateAppointmentRequestSuccess(result));
      } else {
        emit(CreateAppointmentRequestFailure(result['message'].toString()));
      }
    } on ApiException catch (e) {
      emit(CreateAppointmentRequestFailure(e.toString()));
    }
  }
}
