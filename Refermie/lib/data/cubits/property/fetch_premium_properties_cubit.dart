import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:ebroker/ui/screens/proprties/view_all.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/network/cache_manger.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchPremiumPropertiesState {}

class FetchPremiumPropertiesInitial extends FetchPremiumPropertiesState {}

class FetchPremiumPropertiesInProgress extends FetchPremiumPropertiesState {}

class FetchPremiumPropertiesSuccess extends FetchPremiumPropertiesState
    implements PropertySuccessStateWireframe {
  FetchPremiumPropertiesSuccess({
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

  FetchPremiumPropertiesSuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? propertymodel,
    int? offset,
    int? total,
  }) {
    return FetchPremiumPropertiesSuccess(
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

class FetchPremiumPropertiesFailure extends FetchPremiumPropertiesState
    implements PropertyErrorStateWireframe {
  FetchPremiumPropertiesFailure(this.error);
  @override
  final String error;

  @override
  set error(_) {}
}

class FetchPremiumPropertiesCubit extends Cubit<FetchPremiumPropertiesState>
    implements PropertyCubitWireframe {
  FetchPremiumPropertiesCubit() : super(FetchPremiumPropertiesInitial());

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
          emit(FetchPremiumPropertiesInProgress());
        },
        delay: loadWithoutDelay ?? false ? 0 : null,
        onNetworkRequest: () async {
          final result = await _propertyRepository.fetchPremiumProperty(
            offset: 0,
            latitude: HiveUtils.getLatitude().toString(),
            longitude: HiveUtils.getLongitude().toString(),
            radius: HiveUtils.getRadius().toString(),
          );
          return FetchPremiumPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: result.modelList,
            offset: 0,
            total: result.total,
          );
        },
        onOfflineData: () {
          return FetchPremiumPropertiesSuccess(
            total: (state as FetchPremiumPropertiesSuccess).total,
            offset: (state as FetchPremiumPropertiesSuccess).offset,
            isLoadingMore:
                (state as FetchPremiumPropertiesSuccess).isLoadingMore,
            loadingMoreError:
                (state as FetchPremiumPropertiesSuccess).loadingMoreError,
            properties: (state as FetchPremiumPropertiesSuccess).properties,
          );
        },
        onSuccess: (data) {
          emit(data);
        },
        hasData: state is FetchPremiumPropertiesSuccess,
      );
    } on Exception catch (e) {
      emit(FetchPremiumPropertiesFailure(e.toString()));
    }
  }

  void update(PropertyModel model) {
    if (state is FetchPremiumPropertiesSuccess) {
      final properties = (state as FetchPremiumPropertiesSuccess).properties;

      final index = properties.indexWhere((element) => element.id == model.id);
      if (index != -1) {
        properties[index] = model;
      }

      emit(
        (state as FetchPremiumPropertiesSuccess)
            .copyWith(propertymodel: properties),
      );
    }
  }

  @override
  Future<void> fetchMore() async {
    try {
      if (state is FetchPremiumPropertiesSuccess) {
        if ((state as FetchPremiumPropertiesSuccess).isLoadingMore) {
          return;
        }
        emit(
          (state as FetchPremiumPropertiesSuccess)
              .copyWith(isLoadingMore: true),
        );
        final result = await _propertyRepository.fetchPremiumProperty(
          offset: (state as FetchPremiumPropertiesSuccess).properties.length,
          latitude: HiveUtils.getLatitude().toString(),
          longitude: HiveUtils.getLongitude().toString(),
          radius: HiveUtils.getRadius().toString(),
        );

        final propertymodelState = state as FetchPremiumPropertiesSuccess;
        propertymodelState.properties.addAll(result.modelList);
        emit(
          FetchPremiumPropertiesSuccess(
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertymodelState.properties,
            offset: (state as FetchPremiumPropertiesSuccess).properties.length,
            total: result.total,
          ),
        );
      }
    } on Exception catch (_) {
      emit(
        (state as FetchPremiumPropertiesSuccess)
            .copyWith(isLoadingMore: false, loadingMoreError: true),
      );
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchPremiumPropertiesSuccess) {
      return (state as FetchPremiumPropertiesSuccess).properties.length <
          (state as FetchPremiumPropertiesSuccess).total;
    }
    return false;
  }
}
