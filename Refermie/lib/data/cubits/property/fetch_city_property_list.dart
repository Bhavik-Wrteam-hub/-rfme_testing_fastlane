import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/proprties/view_all.dart';

abstract class FetchCityPropertyListState {}

class FetchCityPropertyInitial extends FetchCityPropertyListState {}

class FetchCityPropertyInProgress extends FetchCityPropertyListState {}

class FetchCityPropertySuccess extends FetchCityPropertyListState
    implements PropertySuccessStateWireframe {
  FetchCityPropertySuccess({
    required this.isLoadingMore,
    required this.loadingMoreError,
    required this.properties,
    required this.cityName,
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
  final String cityName;

  @override
  set isLoadingMore(bool isLoadingMore) {}

  @override
  set properties(List<PropertyModel> properties) {}

  FetchCityPropertySuccess copyWith({
    bool? isLoadingMore,
    bool? loadingMoreError,
    List<PropertyModel>? properties,
    int? offset,
    int? total,
    String? cityName,
  }) {
    return FetchCityPropertySuccess(
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadingMoreError: loadingMoreError ?? this.loadingMoreError,
      properties: properties ?? this.properties,
      offset: offset ?? this.offset,
      total: total ?? this.total,
      cityName: cityName ?? this.cityName,
    );
  }
}

class FetchCityPropertyFail extends FetchCityPropertyListState
    implements PropertyErrorStateWireframe {
  FetchCityPropertyFail(this.error);
  @override
  final dynamic error;

  @override
  set error(_) {}
}

class FetchCityPropertyList extends Cubit<FetchCityPropertyListState>
    implements PropertyCubitWireframe {
  FetchCityPropertyList() : super(FetchCityPropertyInitial());
  final PropertyRepository _propertyRepository = PropertyRepository();

  @override
  Future<void> fetch({
    bool? forceRefresh,
    String? cityName,
  }) async {
    if (forceRefresh != true) {
      if (state is FetchCityPropertySuccess) {
        if ((state as FetchCityPropertySuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchCityPropertySuccess).copyWith(isLoadingMore: true));
      } else {
        emit(FetchCityPropertyInProgress());
      }
    } else {
      emit(FetchCityPropertyInProgress());
    }
    try {
      final result = await _propertyRepository.fetchPropertiesFromPlace(
        city: cityName ?? '',
        offset: 0,
      );
      emit(
        FetchCityPropertySuccess(
          isLoadingMore: false,
          loadingMoreError: false,
          properties: result.modelList,
          offset: 0,
          cityName: cityName ?? '',
          total: result.total,
        ),
      );
    } on Exception catch (e) {
      emit(FetchCityPropertyFail(e as dynamic));
    }
  }

  @override
  Future<void> fetchMore() async {
    try {
      if (state is FetchCityPropertySuccess) {
        if ((state as FetchCityPropertySuccess).isLoadingMore) {
          return;
        }
        emit((state as FetchCityPropertySuccess).copyWith(isLoadingMore: true));
        final result = await _propertyRepository.fetchPropertiesFromPlace(
          city: (state as FetchCityPropertySuccess).cityName,
          offset: (state as FetchCityPropertySuccess).properties.length,
        );

        final propertiesState = state as FetchCityPropertySuccess;
        propertiesState.properties.addAll(result.modelList);
        emit(
          FetchCityPropertySuccess(
            cityName: (state as FetchCityPropertySuccess).cityName,
            isLoadingMore: false,
            loadingMoreError: false,
            properties: propertiesState.properties,
            offset: (state as FetchCityPropertySuccess).properties.length,
            total: result.total,
          ),
        );
      }
    } on Exception catch (_) {
      emit(
        (state as FetchCityPropertySuccess)
            .copyWith(isLoadingMore: false, loadingMoreError: true),
      );
    }
  }

  @override
  bool hasMoreData() {
    if (state is FetchCityPropertySuccess) {
      return (state as FetchCityPropertySuccess).properties.length <
          (state as FetchCityPropertySuccess).total;
    }
    return false;
  }

  bool isLoadingMore() {
    if (state is FetchCityPropertySuccess) {
      return (state as FetchCityPropertySuccess).isLoadingMore;
    }
    return false;
  }
}
