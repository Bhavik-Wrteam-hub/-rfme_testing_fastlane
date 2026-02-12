import 'package:ebroker/data/model/appointment/monthly_time_slots_model.dart';
import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchMonthlyTimeSlotsState {}

class FetchMonthlyTimeSlotsInitial extends FetchMonthlyTimeSlotsState {}

class FetchMonthlyTimeSlotsLoading extends FetchMonthlyTimeSlotsState {}

class FetchMonthlyTimeSlotsSuccess extends FetchMonthlyTimeSlotsState {
  FetchMonthlyTimeSlotsSuccess(this.monthlyTimeSlots);
  final MonthlyTimeSlotsModel monthlyTimeSlots;
}

class FetchMonthlyTimeSlotsFailure extends FetchMonthlyTimeSlotsState {
  FetchMonthlyTimeSlotsFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchMonthlyTimeSlotsCubit extends Cubit<FetchMonthlyTimeSlotsState> {
  FetchMonthlyTimeSlotsCubit() : super(FetchMonthlyTimeSlotsInitial());

  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> fetchMonthlyTimeSlots({
    required String year,
    required String month,
    required String agentId,
    required bool isAdmin,
  }) async {
    try {
      emit(FetchMonthlyTimeSlotsLoading());
      final monthlyTimeSlots = await _appointmentRepository.getMonthlyTimeSlots(
        year: year,
        month: month,
        agentId: agentId,
        isAdmin: isAdmin,
      );
      emit(FetchMonthlyTimeSlotsSuccess(monthlyTimeSlots));
    } on ApiException catch (e) {
      emit(FetchMonthlyTimeSlotsFailure(e.toString()));
    }
  }
}
