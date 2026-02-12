import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class DeleteExtraTimeSlotState {}

class DeleteExtraTimeSlotInitial extends DeleteExtraTimeSlotState {}

class DeleteExtraTimeSlotInProgress extends DeleteExtraTimeSlotState {}

class DeleteExtraTimeSlotSuccess extends DeleteExtraTimeSlotState {
  DeleteExtraTimeSlotSuccess({required this.responseData});
  final Map<String, dynamic> responseData;
}

class DeleteExtraTimeSlotFailure extends DeleteExtraTimeSlotState {
  DeleteExtraTimeSlotFailure(this.errorMessage);
  final dynamic errorMessage;
}

class DeleteExtraTimeSlotCubit extends Cubit<DeleteExtraTimeSlotState> {
  DeleteExtraTimeSlotCubit() : super(DeleteExtraTimeSlotInitial());

  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> deleteExtraTimeSlot({
    required Map<String, dynamic> parameters,
  }) async {
    try {
      emit(DeleteExtraTimeSlotInProgress());
      final responseData = await _appointmentRepository.deleteExtraTimeSlot(
        parameters: parameters,
      );
      if (responseData['error'] == false) {
        emit(DeleteExtraTimeSlotSuccess(responseData: responseData));
      } else {
        emit(DeleteExtraTimeSlotFailure(responseData['message'].toString()));
      }
    } on ApiException catch (e) {
      emit(DeleteExtraTimeSlotFailure(e.toString()));
    }
  }
}
