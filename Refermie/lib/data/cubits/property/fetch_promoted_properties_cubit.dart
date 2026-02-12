import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/ui/screens/proprties/view_all.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/network/cache_manger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchPromotedPropertiesState {}

class FetchPromotedPropertiesInitial extends FetchPromotedPropertiesState {}

class FetchPromotedPropertiesInProgress extends FetchPromotedPropertiesState {}

class FetchPromotedPropertiesSuccess extends FetchPromotedPropertiesState
    implements PropertySuccessStateWireframe {
  FetchPromotedPropertiesSuccess({
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

  FetchPromotedPropertiesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? propertymodel,
    int? offset,
    int? total,
  }) {
    return FetchPromotedPropertiesSuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      properties: propertymodel ?? properties,
      offset: offset ?? this.offset,
      total: total ?? this.total,
    );
  }

  @override
  set isLoadingMore(bool isLoadingMore) {}

  @override
  set properties(List<PropertyModel> properties) {}
}

class FetchPromotedPropertiesFailure extends FetchPromotedPropertiesState
    implements PropertyErrorStateWireframe {
  FetchPromotedPropertiesFailure(this.error);
  @override
  final String error;

  @override
  set error(_) {}
}

class FetchPromotedPropertiesCubit extends Cubit<FetchPromotedPropertiesState>
    implements PropertyCubitWireframe {
  FetchPromotedPropertiesCubit() : super(FetchPromotedPropertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();

  @override
  Future<void> fetch({
    bool? forceRefresh,
    bool? loadWithoutDelay,
  }) async {
    try {
      await CacheData().getData(
        forceRefresh: forceRefresh ?? false,
        onProgress: () {
          emit(FetchPromotedPropertiesInProgress());
        },
        delay: loadWithoutDelay ?? false ? 0 : null,
        onNetworkRequest: () async {
          final result = await _propertyRepository.fetchPromotedProperty(
            offset: 0,
            latitude: HiveUtils.getLatitude().toString(),
            longitude: HiveUtils.getLongitude().toString(),
            radius: HiveUtils.getRadius().toString(),
            sendCityName: true,
          );
          return FetchPromotedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: result.modelList,
            offset: 0,
            total: result.total,
          );
        },
        onOfflineData: () {
          return FetchPromotedPropertiesSuccess(
            total: (state as FetchPromotedPropertiesSuccess).total,
            offset: (state as FetchPromotedPropertiesSuccess).offset,
            isLoadingMore:
                (state as FetchPromotedPropertiesSuccess).isLoadingMore,
            loadingMoreError:
                (state as FetchPromotedPropertiesSuccess).loadingMoreError,
            properties: (state as FetchPromotedPropertiesSuccess).properties,
          );
        },
        onSuccess: (data) {
          emit(data);
        },
        hasData: state is FetchPromotedPropertiesSuccess,
      );
    } on Exception catch (e) {
      emit(FetchPromotedPropertiesFailure(e.toString()));
    }
  }

  void update(PropertyModel model) {
    if (state is FetchPromotedPropertiesSuccess) {
      final properties = (state as FetchPromotedPropertiesSuccess).properties;

      final index = properties.indexWhere((element) => element.id == model.id);
      if (index != -1) {
        properties[index] = model;
      }

      emit(
        (state as FetchPromotedPropertiesSuccess).copyWith(
          propertymodel: properties,
        ),
      );
    }
  }

  @override
  Future<void> fetchMore() async {
    try {
      if (state is FetchPromotedPropertiesSuccess) {
        if ((state as FetchPromotedPropertiesSuccess).isLoadingMore) {
          return;
        }
        emit(
          (state as FetchPromotedPropertiesSuccess).copyWith(
            isLoadingMore: true,
          ),
        );
        final result = await _propertyRepository.fetchPromotedProperty(
          offset: (state as FetchPromotedPropertiesSuccess).properties.length,
          latitude: HiveUtils.getLatitude().toString(),
          longitude: HiveUtils.getLongitude().toString(),
          radius: HiveUtils.getRadius().toString(),
          sendCityName: true,
        );

        final propertymodelState = state as FetchPromotedPropertiesSuccess;
        propertymodelState.properties.addAll(result.modelList);
        emit(
          FetchPromotedPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertymodelState.properties,
            offset: (state as FetchPromotedPropertiesSuccess).properties.length,
            total: result.total,
          ),
        );
      }
    } on Exception catch (_) {
      emit(
        (state as FetchPromotedPropertiesSuccess).copyWith(
          isLoadingMore: false,
          loadingMoreError: true,
        ),
      );
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchPromotedPropertiesSuccess) {
      return (state as FetchPromotedPropertiesSuccess).properties.length <
          (state as FetchPromotedPropertiesSuccess).total;
    }
    return false;
  }
}
