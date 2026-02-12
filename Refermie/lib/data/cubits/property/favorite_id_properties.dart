import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteIDsCubit extends Cubit<FavoriteIDsState> {
  FavoriteIDsCubit() : super(FavoriteIDsState(list: {}));

  void addToFavoriteLocal(int id) {
    state.list.add(id);
    emit(FavoriteIDsState(list: state.list));
  }

  void removeFromFavourite(int id) {
    state.list.remove(id);
    emit(FavoriteIDsState(list: state.list));
  }

  bool isFavourite(int id) {
    return state.list.contains(id);
  }
}

class FavoriteIDsState {
  FavoriteIDsState({
    required this.list,
  });
  Set<int> list;
}
