import 'package:ebroker/data/model/appointment/agent_time_schedule_model.dart';
import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchAgentTimeSchedulesState {}

class FetchAgentTimeSchedulesInitial extends FetchAgentTimeSchedulesState {}

class FetchAgentTimeSchedulesLoading extends FetchAgentTimeSchedulesState {}

class FetchAgentTimeSchedulesSuccess extends FetchAgentTimeSchedulesState {
  FetchAgentTimeSchedulesSuccess({
    required this.schedules,
  });

  final AgentTimeScheduleModel schedules;

  FetchAgentTimeSchedulesSuccess copyWith({
    AgentTimeScheduleModel? schedules,
  }) {
    return FetchAgentTimeSchedulesSuccess(
      schedules: schedules ?? this.schedules,
    );
  }
}

class FetchAgentTimeSchedulesFailure extends FetchAgentTimeSchedulesState {
  FetchAgentTimeSchedulesFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchAgentTimeSchedulesCubit extends Cubit<FetchAgentTimeSchedulesState> {
  FetchAgentTimeSchedulesCubit() : super(FetchAgentTimeSchedulesInitial());

  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> fetchAgentTimeSchedules({
    required bool forceRefresh,
  }) async {
    try {
      emit(FetchAgentTimeSchedulesLoading());
      final data = await _appointmentRepository.getAgentTimeSchedules();
      emit(
        FetchAgentTimeSchedulesSuccess(
          schedules: data,
        ),
      );
    } on ApiException catch (e) {
      emit(FetchAgentTimeSchedulesFailure(e.toString()));
    } on Exception catch (e) {
      emit(FetchAgentTimeSchedulesFailure(e.toString()));
    }
  }

  void clear() {
    emit(FetchAgentTimeSchedulesInitial());
  }
}
