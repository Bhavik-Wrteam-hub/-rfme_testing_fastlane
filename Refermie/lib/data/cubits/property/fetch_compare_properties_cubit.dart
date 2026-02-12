import 'package:ebroker/data/model/compare_property_model.dart';
import 'package:ebroker/data/repositories/property_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchComparePropertiesState {}

class FetchComparePropertiesInitial extends FetchComparePropertiesState {}

class FetchComparePropertiesInProgress extends FetchComparePropertiesState {}

class FetchComparePropertiesSuccess extends FetchComparePropertiesState {
  FetchComparePropertiesSuccess({
    required this.hasError,
    required this.comparisionData,
  });
  final bool hasError;
  final ComparePropertyModel comparisionData;

  FetchComparePropertiesSuccess copyWith({
    int? total,
    int? offset,
    bool? isLoadingMore,
    bool? hasMoreData,
    ComparePropertyModel? comparisionData,
  }) =>
      FetchComparePropertiesSuccess(
        hasError: hasMoreData ?? hasError,
        comparisionData: comparisionData ?? this.comparisionData,
      );
}

class FetchComparePropertiesFailure extends FetchComparePropertiesState {
  FetchComparePropertiesFailure(this.errorMessage);
  final String errorMessage;
}

class FetchComparePropertiesCubit extends Cubit<FetchComparePropertiesState> {
  FetchComparePropertiesCubit() : super(FetchComparePropertiesInitial());

  final PropertyRepository _propertyRepository = PropertyRepository();
  Future<void> fetchCompareProperties({
    required int sourcePropertyId,
    required int targetPropertyId,
  }) async {
    try {
      emit(FetchComparePropertiesInProgress());
      final result = await _propertyRepository.compareProperties(
        sourcePropertyId: sourcePropertyId,
        targetPropertyId: targetPropertyId,
      );

      emit(
        FetchComparePropertiesSuccess(
          hasError: false,
          comparisionData: result,
        ),
      );
    } on Exception catch (e) {
      emit(FetchComparePropertiesFailure(e.toString()));
    }
  }
}
