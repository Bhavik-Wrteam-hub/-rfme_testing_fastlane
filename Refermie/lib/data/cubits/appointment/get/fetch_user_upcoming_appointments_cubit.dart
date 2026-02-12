import 'package:ebroker/data/model/appointment/appointment_model.dart';
import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchUserUpcomingAppointmentsState {}

class FetchUserUpcomingAppointmentsInitial
    extends FetchUserUpcomingAppointmentsState {}

class FetchUserUpcomingAppointmentsLoading
    extends FetchUserUpcomingAppointmentsState {}

class FetchUserUpcomingAppointmentsSuccess
    extends FetchUserUpcomingAppointmentsState {
  FetchUserUpcomingAppointmentsSuccess({
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

  FetchUserUpcomingAppointmentsSuccess copyWith({
    List<AppointmentModel>? appointments,
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
  }) {
    return FetchUserUpcomingAppointmentsSuccess(
      appointments: appointments ?? this.appointments,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
    );
  }
}

class FetchUserUpcomingAppointmentsFailure
    extends FetchUserUpcomingAppointmentsState {
  FetchUserUpcomingAppointmentsFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchUserUpcomingAppointmentsCubit
    extends Cubit<FetchUserUpcomingAppointmentsState> {
  FetchUserUpcomingAppointmentsCubit()
    : super(FetchUserUpcomingAppointmentsInitial());

  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> fetchUserUpcomingAppointments({
    required bool forceRefresh,
    String? meetingType,
    String? status,
  }) async {
    try {
      emit(FetchUserUpcomingAppointmentsLoading());
      final dataOutput = await _appointmentRepository.getUserAppointments(
        offset: 0,
        dateFilter: 'upcoming',
        meetingType: meetingType,
        status: status,
      );
      final appointments = List<AppointmentModel>.from(dataOutput.modelList);
      emit(
        FetchUserUpcomingAppointmentsSuccess(
          offset: 0,
          total: dataOutput.total,
          appointments: appointments,
          isLoadingMore: false,
          hasLoadMoreError: false,
        ),
      );
    } on ApiException catch (e) {
      emit(FetchUserUpcomingAppointmentsFailure(e.toString()));
    }
  }

  bool isLoadingMore() {
    if (state is FetchUserUpcomingAppointmentsSuccess) {
      return (state as FetchUserUpcomingAppointmentsSuccess).isLoadingMore;
    }
    return false;
  }

  Future<void> fetchMore({
    String? meetingType,
    String? status,
  }) async {
    if (state is FetchUserUpcomingAppointmentsSuccess) {
      try {
        final scrollSuccess = state as FetchUserUpcomingAppointmentsSuccess;
        if (scrollSuccess.isLoadingMore) return;
        emit(
          (state as FetchUserUpcomingAppointmentsSuccess).copyWith(
            isLoadingMore: true,
          ),
        );

        final dataOutput = await _appointmentRepository.getUserAppointments(
          offset: (state as FetchUserUpcomingAppointmentsSuccess)
              .appointments
              .length,
          dateFilter: 'upcoming',
          meetingType: meetingType,
          status: status,
        );

        final currentState = state as FetchUserUpcomingAppointmentsSuccess;
        final updatedAppointments = currentState.appointments
          ..addAll(dataOutput.modelList);
        emit(
          FetchUserUpcomingAppointmentsSuccess(
            isLoadingMore: false,
            hasLoadMoreError: false,
            appointments: updatedAppointments,
            offset: updatedAppointments.length,
            total: dataOutput.total,
          ),
        );
      } on ApiException {
        emit(
          (state as FetchUserUpcomingAppointmentsSuccess).copyWith(
            hasLoadMoreError: true,
          ),
        );
      }
    }
  }

  bool hasMoreData() {
    if (state is FetchUserUpcomingAppointmentsSuccess) {
      return (state as FetchUserUpcomingAppointmentsSuccess).appointments
              .whereType<AppointmentModel>()
              .length <
          (state as FetchUserUpcomingAppointmentsSuccess).total;
    }
    return false;
  }

  bool isAppointmentsEmpty() {
    if (state is FetchUserUpcomingAppointmentsSuccess) {
      return (state as FetchUserUpcomingAppointmentsSuccess)
              .appointments
              .isEmpty &&
          !(state as FetchUserUpcomingAppointmentsSuccess).isLoadingMore;
    }
    return true;
  }

  void clear() {
    emit(FetchUserUpcomingAppointmentsInitial());
  }
}
