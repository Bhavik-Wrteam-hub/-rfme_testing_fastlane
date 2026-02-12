import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class SetAgentTimeScheduleState {}

class SetAgentTimeScheduleInitial extends SetAgentTimeScheduleState {}

class SetAgentTimeScheduleInProgress extends SetAgentTimeScheduleState {}

class SetAgentTimeScheduleSuccess extends SetAgentTimeScheduleState {
  SetAgentTimeScheduleSuccess(this.response);
  final Map<String, dynamic> response;
}

class SetAgentTimeScheduleFailure extends SetAgentTimeScheduleState {
  SetAgentTimeScheduleFailure(this.errorMessage);
  final String errorMessage;
}

class SetAgentTimeScheduleCubit extends Cubit<SetAgentTimeScheduleState> {
  SetAgentTimeScheduleCubit() : super(SetAgentTimeScheduleInitial());
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> setAgentTimeSchedule({
    required Map<String, dynamic> parameters,
  }) async {
    try {
      emit(SetAgentTimeScheduleInProgress());
      final result = await _appointmentRepository.setAgentTimeSchedule(
        parameters: parameters,
      );

      if (result['error'] == false) {
        emit(SetAgentTimeScheduleSuccess(result));
      } else {
        emit(SetAgentTimeScheduleFailure(result['message'].toString()));
      }
    } on ApiException catch (e) {
      emit(SetAgentTimeScheduleFailure(e.toString()));
    }
  }
}
