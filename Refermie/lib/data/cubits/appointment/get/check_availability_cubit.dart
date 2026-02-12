import 'package:ebroker/data/model/appointment/availability_model.dart';
import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class CheckAvailabilityState {}

class CheckAvailabilityInitial extends CheckAvailabilityState {}

class CheckAvailabilityLoading extends CheckAvailabilityState {}

class CheckAvailabilitySuccess extends CheckAvailabilityState {
  CheckAvailabilitySuccess(this.availability);
  final AvailabilityModel availability;
}

class CheckAvailabilityFailure extends CheckAvailabilityState {
  CheckAvailabilityFailure(this.errorMessage);
  final dynamic errorMessage;
}

class CheckAvailabilityCubit extends Cubit<CheckAvailabilityState> {
  CheckAvailabilityCubit() : super(CheckAvailabilityInitial());

  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> checkAvailability({
    required String agentId,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      emit(CheckAvailabilityLoading());
      final availability = await _appointmentRepository.checkAvailability(
        agentId: agentId,
        date: date,
        startTime: startTime,
        endTime: endTime,
      );
      emit(CheckAvailabilitySuccess(availability));
    } on ApiException catch (e) {
      emit(CheckAvailabilityFailure(e.toString()));
    }
  }
}
