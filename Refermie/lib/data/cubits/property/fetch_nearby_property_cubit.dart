import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/ui/screens/proprties/view_all.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/network/network_availability.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchNearbyPropertiesState {}

class FetchNearbyPropertiesInitial extends FetchNearbyPropertiesState {}

class FetchNearbyPropertiesInProgress extends FetchNearbyPropertiesState {}

class FetchNearbyPropertiesSuccess extends FetchNearbyPropertiesState
    implements PropertySuccessStateWireframe {
  FetchNearbyPropertiesSuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.properties,
    required this.offset,
    required this.total,
  });
  @override
  final bool isLoadingMore;
  final bool loadingMoreError;
  @override
  final List<PropertyModel> properties;
  final int offset;
  final int total;

  FetchNearbyPropertiesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? properties,
    int? offset,
    int? total,
  }) {
    return FetchNearbyPropertiesSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      properties: properties ?? this.properties,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  set isLoadingMore(bool isLoadingMore) {}

  @override
  set properties(List<PropertyModel> properties) {}
}

class FetchNearbyPropertiesFailure extends FetchNearbyPropertiesState
    implements PropertyErrorStateWireframe {
  FetchNearbyPropertiesFailure(this.error);
  @override
  final dynamic error;

  @override
  set error(_) {}
}

class FetchNearbyPropertiesCubit extends Cubit<FetchNearbyPropertiesState>
    implements PropertyCubitWireframe {
  FetchNearbyPropertiesCubit() : super(FetchNearbyPropertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  @override
  Future<void> fetch({
    bool? forceRefresh,
    bool? loadWithoutDelay,
  }) async {
    try {
      if (forceRefresh ?? false) {
        final result = await _propertyRepository.fetchNearByProperty(
          offset: 0,
          latitude: HiveUtils.getLatitude().toString(),
          longitude: HiveUtils.getLongitude().toString(),
          radius: HiveUtils.getRadius().toString(),
        );
        emit(
          FetchNearbyPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: result.modelList,
            offset: 0,
            total: result.total,
          ),
        );
      } else {
        if (state is! FetchNearbyPropertiesSuccess) {
          final result = await _propertyRepository.fetchNearByProperty(
            offset: 0,
            latitude: HiveUtils.getLatitude().toString(),
            longitude: HiveUtils.getLongitude().toString(),
            radius: HiveUtils.getRadius().toString(),
          );
          emit(
            FetchNearbyPropertiesSuccess(
              isLoadingMore: false,
              loadingMoreError: false,
              properties: result.modelList,
              offset: 0,
              total: result.total,
            ),
          );
        } else {
          await CheckInternet.check(
            onInternet: () async {
              final result = await _propertyRepository.fetchNearByProperty(
                offset: 0,
                latitude: HiveUtils.getLatitude().toString(),
                longitude: HiveUtils.getLongitude().toString(),
                radius: HiveUtils.getRadius().toString(),
              );
              emit(
                FetchNearbyPropertiesSuccess(
                  isLoadingMore: false,
                  loadingMoreError: false,
                  properties: result.modelList,
                  offset: 0,
                  total: result.total,
                ),
              );
            },
            onNoInternet: () {
              emit(
                FetchNearbyPropertiesSuccess(
                  total: (state as FetchNearbyPropertiesSuccess).total,
                  offset: (state as FetchNearbyPropertiesSuccess).offset,
                  isLoadingMore:
                      (state as FetchNearbyPropertiesSuccess).isLoadingMore,
                  loadingMoreError:
                      (state as FetchNearbyPropertiesSuccess).loadingMoreError,
                  properties:
                      (state as FetchNearbyPropertiesSuccess).properties,
                ),
              );
            },
          );
        }
      }
    } on Exception catch (e) {
      emit(FetchNearbyPropertiesFailure(e as dynamic));
    }
  }

  void update(PropertyModel model) {
    if (state is FetchNearbyPropertiesSuccess) {
      final properties = (state as FetchNearbyPropertiesSuccess).properties;

      final index = properties.indexWhere((element) => element.id == model.id);

      if (index != -1) {
        properties[index] = model;
      }

      emit(
        (state as FetchNearbyPropertiesSuccess)
            .copyWith(properties: properties),
      );
    }
  }

  @override
  Future<void> fetchMore() async {
    try {
      if (state is FetchNearbyPropertiesSuccess) {
        if ((state as FetchNearbyPropertiesSuccess).isLoadingMore) {
          return;
        }
        emit(
          (state as FetchNearbyPropertiesSuccess).copyWith(isLoadingMore: true),
        );
        final result = await _propertyRepository.fetchNearByProperty(
          offset: (state as FetchNearbyPropertiesSuccess).properties.length,

          latitude: HiveUtils.getLatitude().toString(),
          longitude: HiveUtils.getLongitude().toString(),
          radius: HiveUtils.getRadius().toString(),

          // sendCityName: true
        );

        final propertiesState = state as FetchNearbyPropertiesSuccess;
        propertiesState.properties.addAll(result.modelList);
        emit(
          FetchNearbyPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertiesState.properties,
            offset: (state as FetchNearbyPropertiesSuccess).properties.length,
            total: result.total,
          ),
        );
      }
    } on Exception catch (_) {
      emit(
        (state as FetchNearbyPropertiesSuccess)
            .copyWith(isLoadingMore: false, loadingMoreError: true),
      );
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchNearbyPropertiesSuccess) {
      return (state as FetchNearbyPropertiesSuccess).properties.length <
          (state as FetchNearbyPropertiesSuccess).total;
    }
    return false;
  }
}
