import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteUnavailabilityState {}

class DeleteUnavailabilityInitial extends DeleteUnavailabilityState {}

class DeleteUnavailabilityInProgress extends DeleteUnavailabilityState {}

class DeleteUnavailabilitySuccess extends DeleteUnavailabilityState {
  DeleteUnavailabilitySuccess(this.response);
  final Map<String, dynamic> response;
}

class DeleteUnavailabilityFailure extends DeleteUnavailabilityState {
  DeleteUnavailabilityFailure(this.errorMessage);
  final String errorMessage;
}

class DeleteUnavailabilityCubit extends Cubit<DeleteUnavailabilityState> {
  DeleteUnavailabilityCubit() : super(DeleteUnavailabilityInitial());
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> deleteUnavailability({
    required String unavailabilityId,
  }) async {
    try {
      emit(DeleteUnavailabilityInProgress());
      final result = await _appointmentRepository.deleteUnavailability(
        unavailabilityId: unavailabilityId,
      );

      if (result['error'] == false) {
        emit(DeleteUnavailabilitySuccess(result));
      } else {
        emit(DeleteUnavailabilityFailure(result['message'].toString()));
      }
    } on ApiException catch (e) {
      emit(DeleteUnavailabilityFailure(e.toString()));
    }
  }
}
