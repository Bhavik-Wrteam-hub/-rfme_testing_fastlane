import 'package:ebroker/utils/api.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class UpdateLanguageState {}

class UpdateLanguageInitial extends UpdateLanguageState {}

class UpdateLanguageInProgress extends UpdateLanguageState {}

class UpdateLanguageSuccess extends UpdateLanguageState {
  UpdateLanguageSuccess({this.message = ''});
  final String message;
}

class UpdateLanguageSkipped extends UpdateLanguageState {}

class UpdateLanguageFailure extends UpdateLanguageState {
  UpdateLanguageFailure(this.errorMessage);
  final String errorMessage;
}

class UpdateLanguageCubit extends Cubit<UpdateLanguageState> {
  UpdateLanguageCubit() : super(UpdateLanguageInitial());

  Future<void> updateLanguage({required String languageCode}) async {
    if (!HiveUtils.isUserAuthenticated()) {
      emit(UpdateLanguageSkipped());
      return;
    }

    try {
      emit(UpdateLanguageInProgress());
      final response = await Api.post(
        url: Api.updateLanguage,
        parameter: <String, dynamic>{
          Api.languageCode: languageCode,
        },
      );

      if (response['error'] == true) {
        emit(UpdateLanguageFailure(response['message']?.toString() ?? ''));
        return;
      }

      emit(
        UpdateLanguageSuccess(
          message: response['message']?.toString() ?? '',
        ),
      );
    } on ApiException catch (e) {
      emit(UpdateLanguageFailure(e.toString()));
    }
  }
}
