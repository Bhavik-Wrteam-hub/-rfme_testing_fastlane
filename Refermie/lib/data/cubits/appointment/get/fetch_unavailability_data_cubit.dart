import 'package:ebroker/data/model/appointment/unavailability_model.dart';
import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchUnavailabilityDataState {}

class FetchUnavailabilityDataInitial extends FetchUnavailabilityDataState {}

class FetchUnavailabilityDataLoading extends FetchUnavailabilityDataState {}

class FetchUnavailabilityDataSuccess extends FetchUnavailabilityDataState {
  FetchUnavailabilityDataSuccess({
    required this.offset,
    required this.total,
    required this.unavailabilityData,
    required this.isLoadingMore,
    required this.hasLoadMoreError,
  });

  final int offset;
  final int total;
  final List<UnavailabilityModel> unavailabilityData;
  final bool isLoadingMore;
  final bool hasLoadMoreError;

  FetchUnavailabilityDataSuccess copyWith({
    List<UnavailabilityModel>? unavailabilityData,
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
  }) {
    return FetchUnavailabilityDataSuccess(
      unavailabilityData: unavailabilityData ?? this.unavailabilityData,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
    );
  }
}

class FetchUnavailabilityDataFailure extends FetchUnavailabilityDataState {
  FetchUnavailabilityDataFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchUnavailabilityDataCubit extends Cubit<FetchUnavailabilityDataState> {
  FetchUnavailabilityDataCubit() : super(FetchUnavailabilityDataInitial());

  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> fetchUnavailabilityData({
    required bool forceRefresh,
  }) async {
    try {
      emit(FetchUnavailabilityDataLoading());
      final dataOutput = await _appointmentRepository.getUnavailabilityData();
      final unavailabilityData = List<UnavailabilityModel>.from(
        dataOutput.modelList,
      );
      emit(
        FetchUnavailabilityDataSuccess(
          offset: 0,
          total: dataOutput.total,
          unavailabilityData: unavailabilityData,
          isLoadingMore: false,
          hasLoadMoreError: false,
        ),
      );
    } on ApiException catch (e) {
      emit(FetchUnavailabilityDataFailure(e.toString()));
    }
  }

  bool isLoadingMore() {
    if (state is FetchUnavailabilityDataSuccess) {
      return (state as FetchUnavailabilityDataSuccess).isLoadingMore;
    }
    return false;
  }

  bool hasMoreData() {
    if (state is FetchUnavailabilityDataSuccess) {
      return (state as FetchUnavailabilityDataSuccess).unavailabilityData
              .whereType<UnavailabilityModel>()
              .length <
          (state as FetchUnavailabilityDataSuccess).total;
    }
    return false;
  }

  bool isUnavailabilityDataEmpty() {
    if (state is FetchUnavailabilityDataSuccess) {
      return (state as FetchUnavailabilityDataSuccess)
              .unavailabilityData
              .isEmpty &&
          !(state as FetchUnavailabilityDataSuccess).isLoadingMore;
    }
    return true;
  }
}
