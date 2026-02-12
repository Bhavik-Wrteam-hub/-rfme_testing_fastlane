import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchSimilarPropertiesState {}

class FetchSimilarPropertiesInitial extends FetchSimilarPropertiesState {}

class FetchSimilarPropertiesInProgress extends FetchSimilarPropertiesState {}

class FetchSimilarPropertiesSuccess extends FetchSimilarPropertiesState {
  FetchSimilarPropertiesSuccess({
    required this.total,
    required this.offset,
    required this.isLoadingMore,
    required this.hasError,
    required this.properties,
  });
  final int total;
  final int offset;
  final bool isLoadingMore;
  final bool hasError;
  final List<PropertyModel> properties;

  FetchSimilarPropertiesSuccess copyWith({
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasMoreData,
    List<PropertyModel>? properties,
  }) =>
      FetchSimilarPropertiesSuccess(
        total: total ?? this.total,
        offset: offset ?? this.offset,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        hasError: hasMoreData ?? hasError,
        properties: properties ?? this.properties,
      );
}

class FetchSimilarPropertiesFailure extends FetchSimilarPropertiesState {
  FetchSimilarPropertiesFailure(this.errorMessage);
  final String errorMessage;
}

class FetchSimilarPropertiesCubit extends Cubit<FetchSimilarPropertiesState> {
  FetchSimilarPropertiesCubit() : super(FetchSimilarPropertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();
  Future<void> fetchSimilarProperty({
    required int propertyId,
  }) async {
    try {
      emit(FetchSimilarPropertiesInProgress());
      final result = await _propertyRepository.fetchSimilarProperty(
        propertyId: propertyId,
      );

      emit(
        FetchSimilarPropertiesSuccess(
          total: result.total,
          hasError: false,
          isLoadingMore: false,
          offset: 0,
          properties: result.modelList,
        ),
      );
    } on Exception catch (e) {
      emit(FetchSimilarPropertiesFailure(e.toString()));
    }
  }
}
