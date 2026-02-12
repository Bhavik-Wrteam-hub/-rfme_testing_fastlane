import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateAgentTimeSchedulesState {}

class UpdateAgentTimeSchedulesInitial extends UpdateAgentTimeSchedulesState {}

class UpdateAgentTimeSchedulesInProgress
    extends UpdateAgentTimeSchedulesState {}

class UpdateAgentTimeSchedulesSuccess extends UpdateAgentTimeSchedulesState {
  UpdateAgentTimeSchedulesSuccess(this.response);
  final Map<String, dynamic> response;
}

class UpdateAgentTimeSchedulesFailure extends UpdateAgentTimeSchedulesState {
  UpdateAgentTimeSchedulesFailure(this.errorMessage);
  final String errorMessage;
}

class UpdateAgentTimeSchedulesCubit
    extends Cubit<UpdateAgentTimeSchedulesState> {
  UpdateAgentTimeSchedulesCubit() : super(UpdateAgentTimeSchedulesInitial());
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> updateAgentTimeSchedules({
    required Map<String, dynamic> parameters,
  }) async {
    try {
      emit(UpdateAgentTimeSchedulesInProgress());
      final result = await _appointmentRepository.updateAgentTimeSchedules(
        parameters: parameters,
      );

      if (result['error'] == false) {
        emit(UpdateAgentTimeSchedulesSuccess(result));
      } else {
        emit(UpdateAgentTimeSchedulesFailure(result['message'].toString()));
      }
    } on ApiException catch (e) {
      emit(UpdateAgentTimeSchedulesFailure(e.toString()));
    }
  }
}
