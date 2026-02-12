import 'package:ebroker/data/model/appointment/user_report_model.dart';
import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchUserReportsState {}

class FetchUserReportsInitial extends FetchUserReportsState {}

class FetchUserReportsLoading extends FetchUserReportsState {}

class FetchUserReportsSuccess extends FetchUserReportsState {
  FetchUserReportsSuccess({
    required this.offset,
    required this.total,
    required this.userReports,
    required this.isLoadingMore,
    required this.hasLoadMoreError,
  });

  final int offset;
  final int total;
  final List<UserReportModel> userReports;
  final bool isLoadingMore;
  final bool hasLoadMoreError;

  FetchUserReportsSuccess copyWith({
    List<UserReportModel>? userReports,
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
  }) {
    return FetchUserReportsSuccess(
      userReports: userReports ?? this.userReports,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
    );
  }
}

class FetchUserReportsFailure extends FetchUserReportsState {
  FetchUserReportsFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchUserReportsCubit extends Cubit<FetchUserReportsState> {
  FetchUserReportsCubit() : super(FetchUserReportsInitial());

  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> fetchUserReports({
    required bool forceRefresh,
  }) async {
    try {
      emit(FetchUserReportsLoading());
      final dataOutput = await _appointmentRepository.getUserReports();
      final userReports = List<UserReportModel>.from(dataOutput.modelList);
      emit(
        FetchUserReportsSuccess(
          offset: 0,
          total: dataOutput.total,
          userReports: userReports,
          isLoadingMore: false,
          hasLoadMoreError: false,
        ),
      );
    } on ApiException catch (e) {
      emit(FetchUserReportsFailure(e.toString()));
    }
  }

  bool isLoadingMore() {
    if (state is FetchUserReportsSuccess) {
      return (state as FetchUserReportsSuccess).isLoadingMore;
    }
    return false;
  }

  bool hasMoreData() {
    if (state is FetchUserReportsSuccess) {
      return (state as FetchUserReportsSuccess).userReports
              .whereType<UserReportModel>()
              .length <
          (state as FetchUserReportsSuccess).total;
    }
    return false;
  }

  bool isUserReportsEmpty() {
    if (state is FetchUserReportsSuccess) {
      return (state as FetchUserReportsSuccess).userReports.isEmpty &&
          !(state as FetchUserReportsSuccess).isLoadingMore;
    }
    return true;
  }
}
