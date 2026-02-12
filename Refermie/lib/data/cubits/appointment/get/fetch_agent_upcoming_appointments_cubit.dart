import 'package:ebroker/data/model/appointment/appointment_model.dart';
import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchAgentUpcomingAppointmentsState {}

class FetchAgentUpcomingAppointmentsInitial
    extends FetchAgentUpcomingAppointmentsState {}

class FetchAgentUpcomingAppointmentsLoading
    extends FetchAgentUpcomingAppointmentsState {}

class FetchAgentUpcomingAppointmentsSuccess
    extends FetchAgentUpcomingAppointmentsState {
  FetchAgentUpcomingAppointmentsSuccess({
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

  FetchAgentUpcomingAppointmentsSuccess copyWith({
    List<AppointmentModel>? appointments,
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
  }) {
    return FetchAgentUpcomingAppointmentsSuccess(
      appointments: appointments ?? this.appointments,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
    );
  }
}

class FetchAgentUpcomingAppointmentsFailure
    extends FetchAgentUpcomingAppointmentsState {
  FetchAgentUpcomingAppointmentsFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchAgentUpcomingAppointmentsCubit
    extends Cubit<FetchAgentUpcomingAppointmentsState> {
  FetchAgentUpcomingAppointmentsCubit()
    : super(FetchAgentUpcomingAppointmentsInitial());

  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> fetchAgentUpcomingAppointments({
    required bool forceRefresh,
    String? meetingType,
    String? status,
  }) async {
    try {
      emit(FetchAgentUpcomingAppointmentsLoading());
      final dataOutput = await _appointmentRepository.getAgentAppointments(
        offset: 0,
        dateFilter: 'upcoming',
        meetingType: meetingType,
        status: status,
      );
      final appointments = List<AppointmentModel>.from(dataOutput.modelList);
      emit(
        FetchAgentUpcomingAppointmentsSuccess(
          offset: 0,
          total: dataOutput.total,
          appointments: appointments,
          isLoadingMore: false,
          hasLoadMoreError: false,
        ),
      );
    } on ApiException catch (e) {
      emit(FetchAgentUpcomingAppointmentsFailure(e.toString()));
    }
  }

  bool isLoadingMore() {
    if (state is FetchAgentUpcomingAppointmentsSuccess) {
      return (state as FetchAgentUpcomingAppointmentsSuccess).isLoadingMore;
    }
    return false;
  }

  Future<void> fetchMore({
    String? meetingType,
    String? status,
  }) async {
    if (state is FetchAgentUpcomingAppointmentsSuccess) {
      try {
        final scrollSuccess = state as FetchAgentUpcomingAppointmentsSuccess;
        if (scrollSuccess.isLoadingMore) return;
        emit(
          (state as FetchAgentUpcomingAppointmentsSuccess).copyWith(
            isLoadingMore: true,
          ),
        );

        final dataOutput = await _appointmentRepository.getAgentAppointments(
          offset: (state as FetchAgentUpcomingAppointmentsSuccess)
              .appointments
              .length,
          dateFilter: 'upcoming',
          meetingType: meetingType,
          status: status,
        );

        final currentState = state as FetchAgentUpcomingAppointmentsSuccess;
        final updatedAppointments = currentState.appointments
          ..addAll(dataOutput.modelList);
        emit(
          FetchAgentUpcomingAppointmentsSuccess(
            isLoadingMore: false,
            hasLoadMoreError: false,
            appointments: updatedAppointments,
            offset: updatedAppointments.length,
            total: dataOutput.total,
          ),
        );
      } on ApiException {
        emit(
          (state as FetchAgentUpcomingAppointmentsSuccess).copyWith(
            hasLoadMoreError: true,
          ),
        );
      }
    }
  }

  bool hasMoreData() {
    if (state is FetchAgentUpcomingAppointmentsSuccess) {
      return (state as FetchAgentUpcomingAppointmentsSuccess).appointments
              .whereType<AppointmentModel>()
              .length <
          (state as FetchAgentUpcomingAppointmentsSuccess).total;
    }
    return false;
  }

  bool isAppointmentsEmpty() {
    if (state is FetchAgentUpcomingAppointmentsSuccess) {
      return (state as FetchAgentUpcomingAppointmentsSuccess)
              .appointments
              .isEmpty &&
          !(state as FetchAgentUpcomingAppointmentsSuccess).isLoadingMore;
    }
    return true;
  }

  void clear() {
    emit(FetchAgentUpcomingAppointmentsInitial());
  }
}
