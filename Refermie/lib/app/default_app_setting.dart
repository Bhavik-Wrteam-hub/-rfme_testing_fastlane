import 'package:ebroker/exports/main_export.dart';

AppSettingsDataModel fallbackSettingAppSettings = AppSettingsDataModel(
  appHomeScreen: AppIcons.fallbackHomeLogo,
  placeholderLogo: AppIcons.fallbackPlaceholderLogo,
  lightPrimary: primaryColor_,
  lightSecondary: secondaryColor_,
  lightTertiary: tertiaryColor_,
  darkPrimary: primaryColorDark,
  darkSecondary: secondaryColorDark,
  darkTertiary: tertiaryColorDark,
);

///DO not touch this
class LoadAppSettings {
  Future<void> load({required bool initBox}) async {
    try {
      try {
        if (initBox) {
          await HiveUtils.initBoxes();
        }
        final response = await Api.get(
          url: Api.apiGetAppSettings,
          queryParameters: {
            if (HiveUtils.getUserId() != null) 'user_id': HiveUtils.getUserId(),
          },
        );
        if (response['data'] == null) {
          throw ApiException('No data found');
        }
        final data = response['data'] as Map<String, dynamic>;
        appSettings = AppSettingsDataModel.fromJson(data);
        await HiveUtils.setAppThemeSetting(data);
      } on ApiException {
        appSettings = AppSettingsDataModel.fromJson(
          HiveUtils.getAppThemeSettings(),
        );
      }
    } on Exception catch (_) {
      appSettings = fallbackSettingAppSettings;
    }
  }
}
