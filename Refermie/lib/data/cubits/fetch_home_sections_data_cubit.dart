import 'package:ebroker/data/model/home_section_data_model.dart';
import 'package:ebroker/data/repositories/home_screen_data_repository.dart';
import 'package:ebroker/exports/main_export.dart';

abstract class FetchHomeSectionsDataState {}

class FetchHomeSectionsDataInitial extends FetchHomeSectionsDataState {}

class FetchHomeSectionsDataLoading extends FetchHomeSectionsDataState {}

class FetchHomeSectionsDataSuccess extends FetchHomeSectionsDataState {
  FetchHomeSectionsDataSuccess({required this.data});

  final HomeSectionDataModel data;
}

class FetchHomeSectionsDataFailure extends FetchHomeSectionsDataState {
  FetchHomeSectionsDataFailure(this.errorMessage);

  final dynamic errorMessage;
}

class FetchHomeSectionsDataCubit extends Cubit<FetchHomeSectionsDataState> {
  FetchHomeSectionsDataCubit() : super(FetchHomeSectionsDataInitial());

  final HomeScreenDataRepository _repository = HomeScreenDataRepository();

  Future<void> fetch({bool forceRefresh = false}) async {
    try {
      if (forceRefresh || state is! FetchHomeSectionsDataSuccess) {
        emit(FetchHomeSectionsDataLoading());
      }

      final data = await _repository.fetchSectionsData();
      emit(FetchHomeSectionsDataSuccess(data: data));
    } on Exception catch (e) {
      emit(FetchHomeSectionsDataFailure(e));
    }
  }
}
