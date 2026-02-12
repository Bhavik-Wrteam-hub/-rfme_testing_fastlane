import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/ui/screens/proprties/view_all.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/network/network_availability.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchMostViewedPropertiesState {}

class FetchMostViewedPropertiesInitial extends FetchMostViewedPropertiesState {}

class FetchMostViewedPropertiesInProgress
    extends FetchMostViewedPropertiesState {}

class FetchMostViewedPropertiesSuccess extends FetchMostViewedPropertiesState
    implements PropertySuccessStateWireframe {
  FetchMostViewedPropertiesSuccess({
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

  FetchMostViewedPropertiesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? properties,
    int? offset,
    int? total,
  }) {
    return FetchMostViewedPropertiesSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      properties: properties ?? this.properties,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  set properties(List<PropertyModel> properties) {}

  @override
  set isLoadingMore(bool isLoadingMore) {}
}

class FetchMostViewedPropertiesFailure extends FetchMostViewedPropertiesState
    implements PropertyErrorStateWireframe {
  FetchMostViewedPropertiesFailure(this.error);
  @override
  final dynamic error;

  @override
  set error(_) {}
}

class FetchMostViewedPropertiesCubit
    extends Cubit<FetchMostViewedPropertiesState>
    implements PropertyCubitWireframe {
  FetchMostViewedPropertiesCubit() : super(FetchMostViewedPropertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  @override
  Future<void> fetch({
    bool? forceRefresh,
    bool? loadWithoutDelay,
  }) async {
    // if (state is FetchMostViewedPropertiesSuccess) {
    //   return;
    // }
    if (forceRefresh != true) {
      if (state is FetchMostViewedPropertiesSuccess) {
        // WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
        await Future<dynamic>.delayed(
          Duration(
            seconds: loadWithoutDelay ?? false
                ? 0
                : AppSettings.hiddenAPIProcessDelay,
          ),
        );
        // });
      } else {
        emit(FetchMostViewedPropertiesInProgress());
      }
    } else {
      emit(FetchMostViewedPropertiesInProgress());
    }
    try {
      if (forceRefresh ?? false) {
        final result = await _propertyRepository.fetchMostViewedProperty(
          offset: 0,
          latitude: HiveUtils.getLatitude().toString(),
          longitude: HiveUtils.getLongitude().toString(),
          radius: HiveUtils.getRadius().toString(),
        );

        emit(
          FetchMostViewedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: result.modelList,
            offset: 0,
            total: result.total,
          ),
        );
      } else {
        if (state is! FetchMostViewedPropertiesSuccess) {
          final result = await _propertyRepository.fetchMostViewedProperty(
            latitude: HiveUtils.getLatitude().toString(),
            longitude: HiveUtils.getLongitude().toString(),
            radius: HiveUtils.getRadius().toString(),
            offset: 0,
          );

          emit(
            FetchMostViewedPropertiesSuccess(
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
              final result = await _propertyRepository.fetchMostViewedProperty(
                offset: 0,
                latitude: HiveUtils.getLatitude().toString(),
                longitude: HiveUtils.getLongitude().toString(),
                radius: HiveUtils.getRadius().toString(),
              );

              emit(
                FetchMostViewedPropertiesSuccess(
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
                FetchMostViewedPropertiesSuccess(
                  total: (state as FetchMostViewedPropertiesSuccess).total,
                  offset: (state as FetchMostViewedPropertiesSuccess).offset,
                  isLoadingMore:
                      (state as FetchMostViewedPropertiesSuccess).isLoadingMore,
                  loadingMoreError: (state as FetchMostViewedPropertiesSuccess)
                      .loadingMoreError,
                  properties:
                      (state as FetchMostViewedPropertiesSuccess).properties,
                ),
              );
            },
          );
        }
      }
    } on Exception catch (e) {
      emit(FetchMostViewedPropertiesFailure(e as dynamic));
    }
  }

  void update(PropertyModel model) {
    if (state is FetchMostViewedPropertiesSuccess) {
      final properties = (state as FetchMostViewedPropertiesSuccess).properties;

      final index = properties.indexWhere((element) => element.id == model.id);

      if (index != -1) {
        properties[index] = model;
      }

      emit(
        (state as FetchMostViewedPropertiesSuccess)
            .copyWith(properties: properties),
      );
    }
  }

  @override
  Future<void> fetchMore() async {
    try {
      if (state is FetchMostViewedPropertiesSuccess) {
        if ((state as FetchMostViewedPropertiesSuccess).isLoadingMore) {
          return;
        }
        emit(
          (state as FetchMostViewedPropertiesSuccess)
              .copyWith(isLoadingMore: true),
        );
        final result = await _propertyRepository.fetchMostViewedProperty(
          offset: (state as FetchMostViewedPropertiesSuccess).properties.length,
          latitude: HiveUtils.getLatitude().toString(),
          longitude: HiveUtils.getLongitude().toString(),
          radius: HiveUtils.getRadius().toString(),
        );

        final propertiesState = state as FetchMostViewedPropertiesSuccess;
        propertiesState.properties.addAll(result.modelList);
        emit(
          FetchMostViewedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertiesState.properties,
            offset:
                (state as FetchMostViewedPropertiesSuccess).properties.length,
            total: result.total,
          ),
        );
      }
    } on Exception catch (_) {
      emit(
        (state as FetchMostViewedPropertiesSuccess)
            .copyWith(isLoadingMore: false, loadingMoreError: true),
      );
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchMostViewedPropertiesSuccess) {
      return (state as FetchMostViewedPropertiesSuccess).properties.length <
          (state as FetchMostViewedPropertiesSuccess).total;
    }
    return false;
  }
}
