import 'package:ebroker/data/model/appointment/extra_time_slot_model.dart';
import 'package:ebroker/data/repositories/appointment_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchExtraTimeSlotsState {}

class FetchExtraTimeSlotsInitial extends FetchExtraTimeSlotsState {}

class FetchExtraTimeSlotsLoading extends FetchExtraTimeSlotsState {}

class FetchExtraTimeSlotsSuccess extends FetchExtraTimeSlotsState {
  FetchExtraTimeSlotsSuccess({
    required this.offset,
    required this.total,
    required this.extraTimeSlots,
    required this.isLoadingMore,
    required this.hasLoadMoreError,
  });

  final int offset;
  final int total;
  final List<ExtraTimeSlotModel> extraTimeSlots;
  final bool isLoadingMore;
  final bool hasLoadMoreError;

  FetchExtraTimeSlotsSuccess copyWith({
    List<ExtraTimeSlotModel>? extraTimeSlots,
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasLoadMoreError,
  }) {
    return FetchExtraTimeSlotsSuccess(
      extraTimeSlots: extraTimeSlots ?? this.extraTimeSlots,
      total: total ?? this.total,
      offset: offset ?? this.offset,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasLoadMoreError: hasLoadMoreError ?? this.hasLoadMoreError,
    );
  }
}

class FetchExtraTimeSlotsFailure extends FetchExtraTimeSlotsState {
  FetchExtraTimeSlotsFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchExtraTimeSlotsCubit extends Cubit<FetchExtraTimeSlotsState> {
  FetchExtraTimeSlotsCubit() : super(FetchExtraTimeSlotsInitial());

  final AppointmentRepository _appointmentRepository = AppointmentRepository();

  Future<void> fetchExtraTimeSlots({
    required bool forceRefresh,
  }) async {
    try {
      emit(FetchExtraTimeSlotsLoading());
      final dataOutput = await _appointmentRepository.getExtraTimeSlots();
      final extraTimeSlots = List<ExtraTimeSlotModel>.from(
        dataOutput.modelList,
      );
      emit(
        FetchExtraTimeSlotsSuccess(
          offset: 0,
          total: dataOutput.total,
          extraTimeSlots: extraTimeSlots,
          isLoadingMore: false,
          hasLoadMoreError: false,
        ),
      );
    } on ApiException catch (e) {
      emit(FetchExtraTimeSlotsFailure(e.toString()));
    }
  }

  bool isLoadingMore() {
    if (state is FetchExtraTimeSlotsSuccess) {
      return (state as FetchExtraTimeSlotsSuccess).isLoadingMore;
    }
    return false;
  }

  bool hasMoreData() {
    if (state is FetchExtraTimeSlotsSuccess) {
      return (state as FetchExtraTimeSlotsSuccess).extraTimeSlots
              .whereType<ExtraTimeSlotModel>()
              .length <
          (state as FetchExtraTimeSlotsSuccess).total;
    }
    return false;
  }

  bool isExtraTimeSlotsEmpty() {
    if (state is FetchExtraTimeSlotsSuccess) {
      return (state as FetchExtraTimeSlotsSuccess).extraTimeSlots.isEmpty &&
          !(state as FetchExtraTimeSlotsSuccess).isLoadingMore;
    }
    return true;
  }
}
