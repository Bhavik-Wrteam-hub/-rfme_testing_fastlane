import 'package:ebroker/utils/api.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class FetchLanguageState {}

class FetchLanguageInitial extends FetchLanguageState {}

class FetchLanguageInProgress extends FetchLanguageState {}

class FetchLanguageSuccess extends FetchLanguageState {
  FetchLanguageSuccess({
    required this.languageData,
    required this.code,
    required this.name,
    required this.data,
    required this.isRTL,
  });

  factory FetchLanguageSuccess.fromMap(Map<String, dynamic> map) {
    return FetchLanguageSuccess(
      languageData: map['data'] as Map<dynamic, dynamic>,
      code: map['code'] as String,
      isRTL: int.parse(map['rtl'].toString()) == 1,
      name: map['name'] as String,
      data: map['file_name'] as Map<dynamic, dynamic>,
    );
  }
  final Map<dynamic, dynamic> languageData;
  final String code;
  final String name;
  final Map<dynamic, dynamic> data;
  final bool isRTL;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'data': languageData,
      'code': code,
      'name': name,
      'file_name': data,
      'isRTL': isRTL,
    };
  }
}

class FetchLanguageFailure extends FetchLanguageState {
  FetchLanguageFailure(this.errorMessage);
  final String errorMessage;
}

class FetchLanguageCubit extends Cubit<FetchLanguageState> {
  FetchLanguageCubit() : super(FetchLanguageInitial());

  Future<void> getLanguage(String languageCode) async {
    try {
      emit(FetchLanguageInProgress());

      final response = await Api.get(
        url: Api.getLanguages,
        queryParameters: {Api.languageCode: languageCode},
        useAuthToken: false,
      );

      final responseData = response['data'] as Map<String, dynamic>? ?? {};
      emit(
        FetchLanguageSuccess(
          languageData: responseData,
          isRTL: responseData['rtl'] == 1,
          code: responseData['code']?.toString() ?? '',
          data: responseData['file_name'] as Map<dynamic, dynamic>? ?? {},
          name: responseData['name']?.toString() ?? '',
        ),
      );
    } on Exception catch (e) {
      emit(FetchLanguageFailure('Error fetching languages$e'));
    }
  }
}
