import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class ReportUserState {}

class ReportUserInitial extends ReportUserState {}

class ReportUserInProgress extends ReportUserState {}

class ReportUserSuccess extends ReportUserState {
  ReportUserSuccess(this.response);
  final Map<String, dynamic> response;
}

class ReportUserFailure extends ReportUserState {
  ReportUserFailure(this.errorMessage);
  final String errorMessage;
}

class ReportUserCubit extends Cubit<ReportUserState> {
  ReportUserCubit() : super(ReportUserInitial());
  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> reportUser({
    required String userId,
    required String reason,
  }) async {
    try {
      emit(ReportUserInProgress());
      final result = await _appointmentRepository.reportUser(
        userId: userId,
        reason: reason,
      );

      if (result['error'] == false) {
        emit(ReportUserSuccess(result));
      } else {
        emit(ReportUserFailure(result['message'].toString()));
      }
    } on ApiException catch (e) {
      emit(ReportUserFailure(e.toString()));
    }
  }
}
