import 'package:ebroker/data/model/appointment/appointment_model.dart';
import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchUserPreviousAppointmentsState {}

class FetchUserPreviousAppointmentsInitial
    extends FetchUserPreviousAppointmentsState {}

class FetchUserPreviousAppointmentsLoading
    extends FetchUserPreviousAppointmentsState {}

class FetchUserPreviousAppointmentsSuccess
    extends FetchUserPreviousAppointmentsState {
  FetchUserPreviousAppointmentsSuccess({
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

  FetchUserPreviousAppointmentsSuccess copyWith({
    List<AppointmentModel>? appointments,
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
  }) {
    return FetchUserPreviousAppointmentsSuccess(
      appointments: appointments ?? this.appointments,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
    );
  }
}

class FetchUserPreviousAppointmentsFailure
    extends FetchUserPreviousAppointmentsState {
  FetchUserPreviousAppointmentsFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchUserPreviousAppointmentsCubit
    extends Cubit<FetchUserPreviousAppointmentsState> {
  FetchUserPreviousAppointmentsCubit()
    : super(FetchUserPreviousAppointmentsInitial());

  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> fetchUserPreviousAppointments({
    required bool forceRefresh,
    String? meetingType,
    String? status,
  }) async {
    try {
      emit(FetchUserPreviousAppointmentsLoading());
      final dataOutput = await _appointmentRepository.getUserAppointments(
        offset: 0,
        dateFilter: 'previous',
        meetingType: meetingType,
        status: status,
      );
      final appointments = List<AppointmentModel>.from(dataOutput.modelList);
      emit(
        FetchUserPreviousAppointmentsSuccess(
          offset: 0,
          total: dataOutput.total,
          appointments: appointments,
          isLoadingMore: false,
          hasLoadMoreError: false,
        ),
      );
    } on ApiException catch (e) {
      emit(FetchUserPreviousAppointmentsFailure(e.toString()));
    }
  }

  bool isLoadingMore() {
    if (state is FetchUserPreviousAppointmentsSuccess) {
      return (state as FetchUserPreviousAppointmentsSuccess).isLoadingMore;
    }
    return false;
  }

  Future<void> fetchMore({
    String? meetingType,
    String? status,
  }) async {
    if (state is FetchUserPreviousAppointmentsSuccess) {
      try {
        final scrollSuccess = state as FetchUserPreviousAppointmentsSuccess;
        if (scrollSuccess.isLoadingMore) return;
        emit(
          (state as FetchUserPreviousAppointmentsSuccess).copyWith(
            isLoadingMore: true,
          ),
        );

        final dataOutput = await _appointmentRepository.getUserAppointments(
          offset: (state as FetchUserPreviousAppointmentsSuccess)
              .appointments
              .length,
          dateFilter: 'previous',
          meetingType: meetingType,
          status: status,
        );

        final currentState = state as FetchUserPreviousAppointmentsSuccess;
        final updatedAppointments = currentState.appointments
          ..addAll(dataOutput.modelList);
        emit(
          FetchUserPreviousAppointmentsSuccess(
            isLoadingMore: false,
            hasLoadMoreError: false,
            appointments: updatedAppointments,
            offset: updatedAppointments.length,
            total: dataOutput.total,
          ),
        );
      } on ApiException {
        emit(
          (state as FetchUserPreviousAppointmentsSuccess).copyWith(
            hasLoadMoreError: true,
          ),
        );
      }
    }
  }

  bool hasMoreData() {
    if (state is FetchUserPreviousAppointmentsSuccess) {
      return (state as FetchUserPreviousAppointmentsSuccess).appointments
              .whereType<AppointmentModel>()
              .length <
          (state as FetchUserPreviousAppointmentsSuccess).total;
    }
    return false;
  }

  bool isAppointmentsEmpty() {
    if (state is FetchUserPreviousAppointmentsSuccess) {
      return (state as FetchUserPreviousAppointmentsSuccess)
              .appointments
              .isEmpty &&
          !(state as FetchUserPreviousAppointmentsSuccess).isLoadingMore;
    }
    return true;
  }

  void clear() {
    emit(FetchUserPreviousAppointmentsInitial());
  }
}
