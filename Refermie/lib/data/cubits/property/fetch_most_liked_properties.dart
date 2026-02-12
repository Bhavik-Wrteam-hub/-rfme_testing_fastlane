import 'dart:developer';

import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/ui/screens/proprties/view_all.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/network/network_availability.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchMostLikedPropertiesState {}

class FetchMostLikedPropertiesInitial extends FetchMostLikedPropertiesState {}

class FetchMostLikedPropertiesInProgress
    extends FetchMostLikedPropertiesState {}

class FetchMostLikedPropertiesSuccess extends FetchMostLikedPropertiesState
    implements PropertySuccessStateWireframe {
  FetchMostLikedPropertiesSuccess({
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

  FetchMostLikedPropertiesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? properties,
    int? offset,
    int? total,
  }) {
    return FetchMostLikedPropertiesSuccess(
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

class FetchMostLikedPropertiesFailure extends FetchMostLikedPropertiesState
    implements PropertyErrorStateWireframe {
  FetchMostLikedPropertiesFailure(this.error);
  @override
  final dynamic error;

  @override
  set error(_) {}
}

class FetchMostLikedPropertiesCubit extends Cubit<FetchMostLikedPropertiesState>
    implements PropertyCubitWireframe {
  FetchMostLikedPropertiesCubit() : super(FetchMostLikedPropertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  @override
  Future<void> fetch({
    bool? forceRefresh,
    bool? loadWithoutDelay,
  }) async {
    if (forceRefresh != true) {
      if (state is FetchMostLikedPropertiesSuccess) {
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
        emit(FetchMostLikedPropertiesInProgress());
      }
    } else {
      emit(FetchMostLikedPropertiesInProgress());
    }
    try {
      if (forceRefresh ?? false) {
        final result = await _propertyRepository.fetchMostLikeProperty(
          offset: 0,
          latitude: HiveUtils.getLatitude().toString(),
          longitude: HiveUtils.getLongitude().toString(),
          radius: HiveUtils.getRadius().toString(),
          sendCityName: true,
        );

        emit(
          FetchMostLikedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: result.modelList,
            offset: 0,
            total: result.total,
          ),
        );
      } else {
        if (state is! FetchMostLikedPropertiesSuccess) {
          final result = await _propertyRepository.fetchMostLikeProperty(
            offset: 0,
            latitude: HiveUtils.getLatitude().toString(),
            longitude: HiveUtils.getLongitude().toString(),
            radius: HiveUtils.getRadius().toString(),
            sendCityName: true,
          );

          emit(
            FetchMostLikedPropertiesSuccess(
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
              final result = await _propertyRepository.fetchMostLikeProperty(
                offset: 0,
                latitude: HiveUtils.getLatitude().toString(),
                longitude: HiveUtils.getLongitude().toString(),
                radius: HiveUtils.getRadius().toString(),
                sendCityName: true,
              );

              emit(
                FetchMostLikedPropertiesSuccess(
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
                FetchMostLikedPropertiesSuccess(
                  total: (state as FetchMostLikedPropertiesSuccess).total,
                  offset: (state as FetchMostLikedPropertiesSuccess).offset,
                  isLoadingMore:
                      (state as FetchMostLikedPropertiesSuccess).isLoadingMore,
                  loadingMoreError: (state as FetchMostLikedPropertiesSuccess)
                      .loadingMoreError,
                  properties:
                      (state as FetchMostLikedPropertiesSuccess).properties,
                ),
              );
            },
          );
        }
      }
    } on Exception catch (e) {
      log('Error is most liked $e');
      emit(FetchMostLikedPropertiesFailure(e as dynamic));
    }
  }

  void update(PropertyModel model) {
    if (state is FetchMostLikedPropertiesSuccess) {
      final properties = (state as FetchMostLikedPropertiesSuccess).properties;

      final index = properties.indexWhere((element) => element.id == model.id);

      if (index != -1) {
        properties[index] = model;
      }

      emit(
        (state as FetchMostLikedPropertiesSuccess)
            .copyWith(properties: properties),
      );
    }
  }

  @override
  Future<void> fetchMore() async {
    try {
      if (state is FetchMostLikedPropertiesSuccess) {
        if ((state as FetchMostLikedPropertiesSuccess).isLoadingMore) {
          return;
        }
        emit(
          (state as FetchMostLikedPropertiesSuccess)
              .copyWith(isLoadingMore: true),
        );
        final result = await _propertyRepository.fetchMostLikeProperty(
          offset: (state as FetchMostLikedPropertiesSuccess).properties.length,
          latitude: HiveUtils.getLatitude().toString(),
          longitude: HiveUtils.getLongitude().toString(),
          radius: HiveUtils.getRadius().toString(),
          sendCityName: true,
        );

        final propertiesState = state as FetchMostLikedPropertiesSuccess;
        propertiesState.properties.addAll(result.modelList);
        emit(
          FetchMostLikedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertiesState.properties,
            offset:
                (state as FetchMostLikedPropertiesSuccess).properties.length,
            total: result.total,
          ),
        );
      }
    } on Exception catch (_) {
      emit(
        (state as FetchMostLikedPropertiesSuccess)
            .copyWith(isLoadingMore: false, loadingMoreError: true),
      );
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchMostLikedPropertiesSuccess) {
      return (state as FetchMostLikedPropertiesSuccess).properties.length <
          (state as FetchMostLikedPropertiesSuccess).total;
    }
    return false;
  }
}
