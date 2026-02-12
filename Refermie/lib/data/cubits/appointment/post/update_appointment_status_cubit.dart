import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateAppointmentStatusState {}

class UpdateAppointmentStatusInitial extends UpdateAppointmentStatusState {}

class UpdateAppointmentStatusInProgress extends UpdateAppointmentStatusState {}

class UpdateAppointmentStatusSuccess extends UpdateAppointmentStatusState {
  UpdateAppointmentStatusSuccess(this.response);
  final Map<String, dynamic> response;
}

class UpdateAppointmentStatusFailure extends UpdateAppointmentStatusState {
  UpdateAppointmentStatusFailure(this.errorMessage);
  final String errorMessage;
}

class UpdateAppointmentStatusCubit extends Cubit<UpdateAppointmentStatusState> {
  UpdateAppointmentStatusCubit() : super(UpdateAppointmentStatusInitial());
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
    required String reason,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      emit(UpdateAppointmentStatusInProgress());
      final result = await _appointmentRepository.updateAppointmentStatus(
        appointmentId: appointmentId,
        status: status,
        reason: reason,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );

      if (result['error'] == false) {
        emit(UpdateAppointmentStatusSuccess(result));
      } else {
        emit(UpdateAppointmentStatusFailure(result['message'].toString()));
      }
    } on ApiException catch (e) {
      emit(UpdateAppointmentStatusFailure(e.toString()));
    }
  }
}
