import 'package:ebroker/utils/hive_keys.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class LanguageState {}

class LanguageInitial extends LanguageState {}

class LanguageLoader extends LanguageState {
  LanguageLoader(this.languageCode, {required this.isRTL});
  final bool isRTL;
  final dynamic languageCode;
}

class LanguageLoadFail extends LanguageState {
  LanguageLoadFail({required this.error});
  final dynamic error;
}

class LanguageCubit extends Cubit<LanguageState> {
  LanguageCubit() : super(LanguageInitial());

  void emitLanguageLoader({required String code, required bool isRtl}) {
    emit(LanguageLoader(code, isRTL: isRtl));
  }

  void loadCurrentLanguage() {
    final language = Hive.box<dynamic>(HiveKeys.languageBox)
        .get(HiveKeys.currentLanguageKey) as Map?;
    if (language != null) {
      emit(
        LanguageLoader(
          language['code'],
          isRTL: language['isRTL'] as bool? ?? false,
        ),
      );
    } else {
      emit(LanguageLoader('en', isRTL: false));
    }
  }

  bool get isRTL {
    if (state is LanguageLoader) {
      return (state as LanguageLoader).isRTL;
    }
    return false;
  }
}
