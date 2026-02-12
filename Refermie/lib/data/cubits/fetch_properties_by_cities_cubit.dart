import 'package:ebroker/data/model/city_model.dart';
import 'package:ebroker/data/repositories/home_screen_data_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class FetchPropertiesByCitiesState {}

class FetchPropertiesByCitiesInitial extends FetchPropertiesByCitiesState {}

class FetchPropertiesByCitiesLoading extends FetchPropertiesByCitiesState {}

class FetchPropertiesByCitiesSuccess extends FetchPropertiesByCitiesState {
  FetchPropertiesByCitiesSuccess({
    required this.cities,
    required this.isWithImage,
  });

  final List<City> cities;
  final bool isWithImage;

  FetchPropertiesByCitiesSuccess copyWith({
    List<City>? cities,
    bool? isWithImage,
  }) {
    return FetchPropertiesByCitiesSuccess(
      cities: cities ?? this.cities,
      isWithImage: isWithImage ?? this.isWithImage,
    );
  }
}

class FetchPropertiesByCitiesFailure extends FetchPropertiesByCitiesState {
  FetchPropertiesByCitiesFailure(this.errorMessage);

  final dynamic errorMessage;
}

class FetchPropertiesByCitiesCubit extends Cubit<FetchPropertiesByCitiesState> {
  FetchPropertiesByCitiesCubit() : super(FetchPropertiesByCitiesInitial());

  final HomeScreenDataRepository _repository = HomeScreenDataRepository();

  Future<void> fetch() async {
    try {
      if (state is FetchPropertiesByCitiesSuccess) {
        emit(
          (state as FetchPropertiesByCitiesSuccess).copyWith(
            cities: (state as FetchPropertiesByCitiesSuccess).cities,
          ),
        );
      } else {
        emit(FetchPropertiesByCitiesLoading());
      }
      final data = await _repository.fetchPropertiesByCities();
      final cities = data['cities'] as List<City>? ?? [];
      final isWithImage = data['isWithImage'] as bool? ?? false;
      emit(
        FetchPropertiesByCitiesSuccess(
          cities: cities,
          isWithImage: isWithImage,
        ),
      );
    } on Exception catch (e) {
      emit(FetchPropertiesByCitiesFailure(e));
    }
  }
}
