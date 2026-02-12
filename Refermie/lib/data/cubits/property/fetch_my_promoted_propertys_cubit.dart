import 'package:ebroker/data/model/advertisement_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchMyPromotedPropertysState {}

class FetchMyPromotedPropertysInitial extends FetchMyPromotedPropertysState {}

class FetchMyPromotedPropertysInProgress
    extends FetchMyPromotedPropertysState {}

class FetchMyPromotedPropertysSuccess extends FetchMyPromotedPropertysState {
  FetchMyPromotedPropertysSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.advertisement,
    required this.offset,
    required this.total,
  });
  final bool isLoadingMore;
  final bool loadingMoreError;
  final List<AdvertisementProperty> advertisement;
  final int offset;
  final int total;

  FetchMyPromotedPropertysSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<AdvertisementProperty>? advertisement,
    int? offset,
    int? total,
  }) {
    return FetchMyPromotedPropertysSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      advertisement: advertisement ?? this.advertisement,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }
}

class FetchMyPromotedPropertysFailure extends FetchMyPromotedPropertysState {
  FetchMyPromotedPropertysFailure(this.errorMessage);
  final dynamic errorMessage;
}

class FetchMyPromotedPropertysCubit
    extends Cubit<FetchMyPromotedPropertysState> {
  FetchMyPromotedPropertysCubit() : super(FetchMyPromotedPropertysInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  Future<void> fetchMyPromotedPropertys() async {
    try {
      emit(FetchMyPromotedPropertysInProgress());

      final result = await _propertyRepository.fetchMyPromotedProeprties(
        offset: 0,
      );

      emit(
        FetchMyPromotedPropertysSuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          advertisement: result.modelList,
          offset: 0,
          total: result.total,
        ),
      );
    } on Exception catch (e) {
      emit(FetchMyPromotedPropertysFailure(e));
    }
  }

  void delete(dynamic id) {
    if (state is FetchMyPromotedPropertysSuccess) {
      final propertymodel = (state as FetchMyPromotedPropertysSuccess)
          .advertisement
        ..removeWhere((element) => element.id == id);

      emit(
        (state as FetchMyPromotedPropertysSuccess)
            .copyWith(advertisement: propertymodel),
      );
    }
  }

  Future<void> fetchMyPromotedPropertysMore() async {
    try {
      if (state is FetchMyPromotedPropertysSuccess) {
        if ((state as FetchMyPromotedPropertysSuccess).isLoadingMore) {
          return;
        }
        emit(
          (state as FetchMyPromotedPropertysSuccess)
              .copyWith(isLoadingMore: true),
        );
        final result = await _propertyRepository.fetchMyPromotedProeprties(
          offset:
              (state as FetchMyPromotedPropertysSuccess).advertisement.length,
        );

        final propertymodelState = state as FetchMyPromotedPropertysSuccess;
        propertymodelState.advertisement.addAll(result.modelList);
        emit(
          FetchMyPromotedPropertysSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            advertisement: propertymodelState.advertisement,
            offset:
                (state as FetchMyPromotedPropertysSuccess).advertisement.length,
            total: result.total,
          ),
        );
      }
    } on Exception catch (_) {
      emit(
        (state as FetchMyPromotedPropertysSuccess)
            .copyWith(isLoadingMore: false, loadingMoreError: true),
      );
    }
  }

  bool hasMoreData() {
    if (state is FetchMyPromotedPropertysSuccess) {
      return (state as FetchMyPromotedPropertysSuccess).advertisement.length <
          (state as FetchMyPromotedPropertysSuccess).total;
    }
    return false;
  }

  void update(AdvertisementProperty model) {
    if (state is FetchMyPromotedPropertysSuccess) {
      final properties =
          (state as FetchMyPromotedPropertysSuccess).advertisement;

      final index = properties.indexWhere((element) => element.id == model.id);
      if (index != -1) {
        properties[index] = model;
      }

      emit(
        (state as FetchMyPromotedPropertysSuccess)
            .copyWith(advertisement: properties),
      );
    }
  }
}
