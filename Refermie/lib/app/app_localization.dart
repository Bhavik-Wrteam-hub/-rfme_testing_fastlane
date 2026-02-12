//For localization of app

import 'dart:convert';

import 'package:ebroker/utils/hive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalization {
  AppLocalization(this.locale);
  final Locale locale;

  //it will hold key of text and it's values in given language
  late Map<String, String> _localizedValues;

  //to access app-localization instance any where in app using context
  static AppLocalization? of(BuildContext context) {
    return Localizations.of(context, AppLocalization);
  }

  //to load json(language) from assets
  Future<dynamic> loadJson() async {
    final jsonStringValues =
        await rootBundle.loadString('assets/languages/template.json');
    // value from root-bundle will be encoded string
    var mappedJson = <String, dynamic>{};
    final getLanguage = HiveUtils.getLanguage() as Map<dynamic, dynamic>?;
    final languageIsNull = getLanguage == null || getLanguage['data'] == null;
    if (languageIsNull) {
      mappedJson = json.decode(jsonStringValues) as Map<String, dynamic>;
    } else {
      mappedJson = Map<String, dynamic>.from(
        getLanguage['data'] as Map<dynamic, dynamic>,
      );
    }
    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  //to get translated value of given title/key
  String? getTranslatedValues(String? key) {
    return _localizedValues[key!];
  }

  //need to declare custom delegate
  static const LocalizationsDelegate<AppLocalization> delegate =
      _AppLocalizationDelegate();
}

//Custom app delegate
class _AppLocalizationDelegate extends LocalizationsDelegate<AppLocalization> {
  const _AppLocalizationDelegate();

  //providing all supported languages
  @override
  bool isSupported(Locale locale) {
    //
    return true;
  }

  //load languageCode.json files
  @override
  Future<AppLocalization> load(Locale locale) async {
    final localization = AppLocalization(locale);
    await localization.loadJson();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalization> old) {
    return true;
  }
}
