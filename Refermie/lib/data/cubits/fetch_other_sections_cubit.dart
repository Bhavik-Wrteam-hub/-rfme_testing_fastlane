import 'package:ebroker/data/model/other_sections_model.dart';
import 'package:ebroker/data/repositories/home_screen_data_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class FetchOtherSectionsState {}

class FetchOtherSectionsInitial extends FetchOtherSectionsState {}

class FetchOtherSectionsLoading extends FetchOtherSectionsState {}

class FetchOtherSectionsSuccess extends FetchOtherSectionsState {
  FetchOtherSectionsSuccess({required this.data});

  final OtherSectionsModel data;
}

class FetchOtherSectionsFailure extends FetchOtherSectionsState {
  FetchOtherSectionsFailure(this.errorMessage);

  final dynamic errorMessage;
}

class FetchOtherSectionsCubit extends Cubit<FetchOtherSectionsState> {
  FetchOtherSectionsCubit() : super(FetchOtherSectionsInitial());

  final HomeScreenDataRepository _repository = HomeScreenDataRepository();

  Future<void> fetch({bool forceRefresh = false}) async {
    try {
      if (forceRefresh || state is! FetchOtherSectionsSuccess) {
        emit(FetchOtherSectionsLoading());
      }
      final data = await _repository.fetchOtherSections();
      emit(FetchOtherSectionsSuccess(data: data));
    } on Exception catch (e) {
      emit(FetchOtherSectionsFailure(e));
    }
  }
}
