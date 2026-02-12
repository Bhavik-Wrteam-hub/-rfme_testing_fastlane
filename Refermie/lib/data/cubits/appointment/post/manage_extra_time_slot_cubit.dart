import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ManageExtraTimeSlotState {}

class ManageExtraTimeSlotInitial extends ManageExtraTimeSlotState {}

class ManageExtraTimeSlotInProgress extends ManageExtraTimeSlotState {}

class ManageExtraTimeSlotSuccess extends ManageExtraTimeSlotState {
  ManageExtraTimeSlotSuccess({required this.responseData});
  final Map<String, dynamic> responseData;
}

class ManageExtraTimeSlotFailure extends ManageExtraTimeSlotState {
  ManageExtraTimeSlotFailure(this.errorMessage);
  final String errorMessage;
}

class ManageExtraTimeSlotCubit extends Cubit<ManageExtraTimeSlotState> {
  ManageExtraTimeSlotCubit() : super(ManageExtraTimeSlotInitial());

  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> manageExtraTimeSlots({
    required Map<String, dynamic> parameters,
  }) async {
    try {
      emit(ManageExtraTimeSlotInProgress());
      final responseData = await _appointmentRepository.manageExtraTimeSlots(
        parameters: parameters,
      );

      if (responseData['error'] == false) {
        emit(ManageExtraTimeSlotSuccess(responseData: responseData));
      } else {
        emit(ManageExtraTimeSlotFailure(responseData['message'].toString()));
      }
    } on ApiException catch (e) {
      emit(ManageExtraTimeSlotFailure(e.toString()));
    }
  }
}
