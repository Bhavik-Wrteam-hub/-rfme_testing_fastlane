import 'package:ebroker/data/repositories/favourites_repository.dart';
import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum FavoriteType {
  add('1'),
  remove('0');

  const FavoriteType(this.value);
  final String value;
}

abstract class AddToFavoriteCubitState {}

class AddToFavoriteCubitInitial extends AddToFavoriteCubitState {}

class AddToFavoriteCubitInProgress extends AddToFavoriteCubitState {
  AddToFavoriteCubitInProgress();
}

class AddToFavoriteCubitSuccess extends AddToFavoriteCubitState {
  AddToFavoriteCubitSuccess({
    required this.favorite,
    required this.id,
  });
  final int id;
  final FavoriteType favorite;
}

class AddToFavoriteCubitFailure extends AddToFavoriteCubitState {
  AddToFavoriteCubitFailure(this.errorMessage, this.id);
  final String errorMessage;
  final int id;
}

class AddToFavoriteCubitCubit extends Cubit<AddToFavoriteCubitState> {
  AddToFavoriteCubitCubit() : super(AddToFavoriteCubitInitial());

  final FavoriteRepository _favouriteRepository = FavoriteRepository();

  Future<void> setFavorite({
    required int propertyId,
    required FavoriteType type,
  }) async {
    try {
      emit(AddToFavoriteCubitInProgress());

      await _favouriteRepository.addToFavorite(propertyId, type.value);

      emit(AddToFavoriteCubitSuccess(id: propertyId, favorite: type));
    } on ApiException catch (e) {
      emit(AddToFavoriteCubitFailure(e.toString(), propertyId));
    }
  }
}
