import 'package:ebroker/data/model/appointment/appointment_model.dart';
import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchAgentPreviousAppointmentsState {}

class FetchAgentPreviousAppointmentsInitial
    extends FetchAgentPreviousAppointmentsState {}

class FetchAgentPreviousAppointmentsLoading
    extends FetchAgentPreviousAppointmentsState {}

class FetchAgentPreviousAppointmentsSuccess
    extends FetchAgentPreviousAppointmentsState {
  FetchAgentPreviousAppointmentsSuccess({
    required this.offset,
    required this.total,
    required this.appointments,
    required this.isLoadingMore,
    required this.hasLoadMoreError,
  });

  final int offset;
  final int total;
  final List<AppointmentModel> appointments;
  final bool isLoadingMore;
  final bool hasLoadMoreError;

  FetchAgentPreviousAppointmentsSuccess copyWith({
    List<AppointmentModel>? appointments,
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
  }) {
    return FetchAgentPreviousAppointmentsSuccess(
      appointments: appointments ?? this.appointments,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
    );
  }
}

class FetchAgentPreviousAppointmentsFailure
    extends FetchAgentPreviousAppointmentsState {
  FetchAgentPreviousAppointmentsFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchAgentPreviousAppointmentsCubit
    extends Cubit<FetchAgentPreviousAppointmentsState> {
  FetchAgentPreviousAppointmentsCubit()
    : super(FetchAgentPreviousAppointmentsInitial());

  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> fetchAgentPreviousAppointments({
    required bool forceRefresh,
    String? meetingType,
    String? status,
  }) async {
    try {
      emit(FetchAgentPreviousAppointmentsLoading());
      final dataOutput = await _appointmentRepository.getAgentAppointments(
        offset: 0,
        dateFilter: 'previous',
        meetingType: meetingType,
        status: status,
      );
      final appointments = List<AppointmentModel>.from(dataOutput.modelList);
      emit(
        FetchAgentPreviousAppointmentsSuccess(
          offset: 0,
          total: dataOutput.total,
          appointments: appointments,
          isLoadingMore: false,
          hasLoadMoreError: false,
        ),
      );
    } on ApiException catch (e) {
      emit(FetchAgentPreviousAppointmentsFailure(e.toString()));
    }
  }

  bool isLoadingMore() {
    if (state is FetchAgentPreviousAppointmentsSuccess) {
      return (state as FetchAgentPreviousAppointmentsSuccess).isLoadingMore;
    }
    return false;
  }

  Future<void> fetchMore({
    String? meetingType,
    String? status,
  }) async {
    if (state is FetchAgentPreviousAppointmentsSuccess) {
      try {
        final scrollSuccess = state as FetchAgentPreviousAppointmentsSuccess;
        if (scrollSuccess.isLoadingMore) return;
        emit(
          (state as FetchAgentPreviousAppointmentsSuccess).copyWith(
            isLoadingMore: true,
          ),
        );

        final dataOutput = await _appointmentRepository.getAgentAppointments(
          offset: (state as FetchAgentPreviousAppointmentsSuccess)
              .appointments
              .length,
          dateFilter: 'previous',
          meetingType: meetingType,
          status: status,
        );

        final currentState = state as FetchAgentPreviousAppointmentsSuccess;
        final updatedAppointments = currentState.appointments
          ..addAll(dataOutput.modelList);
        emit(
          FetchAgentPreviousAppointmentsSuccess(
            isLoadingMore: false,
            hasLoadMoreError: false,
            appointments: updatedAppointments,
            offset: updatedAppointments.length,
            total: dataOutput.total,
          ),
        );
      } on ApiException {
        emit(
          (state as FetchAgentPreviousAppointmentsSuccess).copyWith(
            hasLoadMoreError: true,
          ),
        );
      }
    }
  }

  bool hasMoreData() {
    if (state is FetchAgentPreviousAppointmentsSuccess) {
      return (state as FetchAgentPreviousAppointmentsSuccess).appointments
              .whereType<AppointmentModel>()
              .length <
          (state as FetchAgentPreviousAppointmentsSuccess).total;
    }
    return false;
  }

  bool isAppointmentsEmpty() {
    if (state is FetchAgentPreviousAppointmentsSuccess) {
      return (state as FetchAgentPreviousAppointmentsSuccess)
              .appointments
              .isEmpty &&
          !(state as FetchAgentPreviousAppointmentsSuccess).isLoadingMore;
    }
    return true;
  }

  void clear() {
    emit(FetchAgentPreviousAppointmentsInitial());
  }
}
