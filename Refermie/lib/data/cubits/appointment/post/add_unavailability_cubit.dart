import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class AddUnavailabilityState {}

class AddUnavailabilityInitial extends AddUnavailabilityState {}

class AddUnavailabilityInProgress extends AddUnavailabilityState {}

class AddUnavailabilitySuccess extends AddUnavailabilityState {
  AddUnavailabilitySuccess(this.response);
  final Map<String, dynamic> response;
}

class AddUnavailabilityFailure extends AddUnavailabilityState {
  AddUnavailabilityFailure(this.errorMessage);
  final String errorMessage;
}

class AddUnavailabilityCubit extends Cubit<AddUnavailabilityState> {
  AddUnavailabilityCubit() : super(AddUnavailabilityInitial());
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> addUnavailability({
    required String date,
    required String typeOfUnavailability,
    required String startTime,
    required String endTime,
    required String reason,
  }) async {
    try {
      emit(AddUnavailabilityInProgress());
      final result = await _appointmentRepository.addUnavailability(
        date: date,
        typeOfUnavailability: typeOfUnavailability,
        startTime: startTime,
        endTime: endTime,
        reason: reason,
      );

      if (result['error'] == false) {
        emit(AddUnavailabilitySuccess(result));
      } else {
        emit(AddUnavailabilityFailure(result['message'].toString()));
      }
    } on ApiException catch (e) {
      emit(AddUnavailabilityFailure(e.toString()));
    }
  }
}
