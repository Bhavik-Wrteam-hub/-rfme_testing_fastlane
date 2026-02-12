import 'package:ebroker/data/model/google_place_model.dart';
import 'package:ebroker/data/repositories/location_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class GooglePlaceAutocompleteState {}

class GooglePlaceAutocompleteInitial extends GooglePlaceAutocompleteState {}

class GooglePlaceAutocompleteInProgress extends GooglePlaceAutocompleteState {}

class GooglePlaceAutocompleteSuccess extends GooglePlaceAutocompleteState {
  GooglePlaceAutocompleteSuccess(this.autocompleteResult);
  List<GooglePlaceModel> autocompleteResult;
}

class GooglePlaceAutocompleteFail extends GooglePlaceAutocompleteState {
  GooglePlaceAutocompleteFail(this.error);
  dynamic error;
}

class GooglePlaceAutocompleteCubit extends Cubit<GooglePlaceAutocompleteState> {
  GooglePlaceAutocompleteCubit() : super(GooglePlaceAutocompleteInitial());
  final GooglePlaceRepository _googlePlaceAutocomplete =
      GooglePlaceRepository();

  ///This method will search location from text,
  ///We use it for search location
  Future<void> getLocationFromText({
    required String text,
  }) async {
    try {
      emit(GooglePlaceAutocompleteInProgress());
      final googlePlaceAutocompleteResponse =
          await _googlePlaceAutocomplete.serchCities(text);
      emit(GooglePlaceAutocompleteSuccess(googlePlaceAutocompleteResponse));
    } on Exception catch (e) {
      emit(GooglePlaceAutocompleteFail(e));
      rethrow;
    }
  }

  ///this will clear all data and set it to its initial state so,
  ///When we don't need these all data we clear it.
  void clearCubit() {
    emit(GooglePlaceAutocompleteSuccess([]));
    Future.delayed(const Duration(microseconds: 300), () {
      emit(GooglePlaceAutocompleteInitial());
    });
  }
}
