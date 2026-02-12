import 'package:ebroker/data/model/languages_model.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/system_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/encryption/rsa.dart';
import 'package:ebroker/utils/network/cache_manger.dart';

abstract class FetchSystemSettingsState {}

class FetchSystemSettingsInitial extends FetchSystemSettingsState {}

class FetchSystemSettingsInProgress extends FetchSystemSettingsState {}

class FetchSystemSettingsSuccess extends FetchSystemSettingsState {
  FetchSystemSettingsSuccess({required this.settings});
  final Map<dynamic, dynamic> settings;
}

class FetchSystemSettingsFailure extends FetchSystemSettingsState {
  FetchSystemSettingsFailure(this.errorMessage);
  final String errorMessage;
}

class FetchSystemSettingsCubit extends Cubit<FetchSystemSettingsState> {
  FetchSystemSettingsCubit() : super(FetchSystemSettingsInitial());
  final SystemRepository _systemRepository = SystemRepository();
  Future<void> fetchSettings({
    required bool isAnonymous,
    bool? forceRefresh,
  }) async {
    try {
      await CacheData().getData(
        forceRefresh: forceRefresh ?? false,
        delay: 0,
        onProgress: () {
          emit(FetchSystemSettingsInProgress());
        },
        onNetworkRequest: () async {
          try {
            final settings = await _systemRepository.fetchSystemSettings(
              isAnonymouse: isAnonymous,
            );
            return settings;
          } on Exception catch (_) {
            rethrow;
          }
        },
        onOfflineData: () {
          return (state as FetchSystemSettingsSuccess).settings;
        },
        onSuccess: (Map<dynamic, dynamic>? data) {
          if (data == null) return;
          final response = data['data'] as Map<dynamic, dynamic>;
          Constant.currencySymbol =
              _getSetting(data, SystemSetting.currencySymbol)?.toString() ?? '';
          if (response['place_api_key'] != null) {
            Constant.googlePlaceAPIkey = RSAEncryption().decrypt(
              privateKey: Constant.keysDecryptionPasswordRSA,
              encryptedData: response['place_api_key']?.toString() ?? '',
            );
          }
          if ((response.containsKey('demo_mode') as bool?) ?? false) {
            Constant.isDemoModeOn = response['demo_mode'] as bool? ?? false;
          }
          Constant.isAdmobAdsEnabled = (response['show_admob_ads'] == '1');

          Constant.admobBannerAndroid =
              response['android_banner_ad_id']?.toString() ?? '';
          Constant.admobBannerIos =
              response['ios_banner_ad_id']?.toString() ?? '';
          Constant.admobNativeAndroid =
              response['android_native_ad_id']?.toString() ?? '';
          Constant.admobNativeIos =
              response['ios_native_ad_id']?.toString() ?? '';

          Constant.admobInterstitialAndroid =
              response['android_interstitial_ad_id']?.toString() ?? '';
          Constant.admobInterstitialIos =
              response['ios_interstitial_ad_id']?.toString() ?? '';
          AppSettings.homePageLocatoinAlertStatus =
              (response['home_page_location_alert_status'] == '1');
          AppSettings.languages = (response['languages'] as List)
              .map((e) => LanguagesModel.fromJson(e as Map<String, dynamic>))
              .toList();
          AppSettings.distanceOption =
              response['distance_option']?.toString() ?? '';
          AppSettings.isAIEnabled = (response['gemini_ai_enabled'] == true);
          AppSettings.playstoreURLAndroid =
              response['playstore_id']?.toString() ?? '';
          AppSettings.appstoreURLios =
              response['appstore_id']?.toString() ?? '';
          AppSettings.iOSAppId = (response['appstore_id'] ?? '')
              .toString()
              .split('/')
              .last;
          AppSettings.otpServiceProvider =
              response['otp_service_provider']?.toString() ?? '';
          AppSettings.isVerificationRequired =
              (response['verification_required_for_user'] as bool?) ?? false;
          final selectedCurrencyData =
              (response['selected_currency_data'] ?? <String, dynamic>{})
                  as Map;
          if (selectedCurrencyData.isNotEmpty as bool? ?? false) {
            AppSettings.currencyCode =
                selectedCurrencyData['code']?.toString() ?? '';
            AppSettings.currencySymbol =
                selectedCurrencyData['symbol']?.toString() ?? '';
            AppSettings.bankTransferDetails =
                (response['bank_details'] as List?)
                    ?.map((e) => e as Map<String, dynamic>)
                    .toList() ??
                [];
            AppSettings.minRadius =
                response['min_radius_range']?.toString() ?? '';
            AppSettings.maxRadius =
                response['max_radius_range']?.toString() ?? '';
            AppSettings.latitude =
                response['latitude']?.toString() ?? '20.5937';
            AppSettings.longitude =
                response['longitude']?.toString() ?? '78.9629';
            AppSettings.loginBackground =
                response['app_login_background']?.toString() ?? '';
          }
          emit(FetchSystemSettingsSuccess(settings: data));
        },
        hasData: state is FetchSystemSettingsSuccess,
      );
    } on Exception catch (e) {
      emit(FetchSystemSettingsFailure(e.toString()));
    }
  }

  dynamic getSetting(SystemSetting selected) {
    if (state is FetchSystemSettingsSuccess) {
      final settings =
          (state as FetchSystemSettingsSuccess).settings['data'] as Map;

      if (selected == SystemSetting.languageType) {
        return settings['languages'];
      }

      if (selected == SystemSetting.demoMode) {
        if (settings.containsKey('demo_mode')) {
          return settings['demo_mode'];
        } else {
          return false;
        }
      }

      /// where selected is equals to type
      final selectedSettingData =
          settings[Constant.systemSettingKeys[selected]];

      return selectedSettingData;
    }
  }

  Map<dynamic, dynamic> getRawSettings() {
    if (state is FetchSystemSettingsSuccess) {
      return (state as FetchSystemSettingsSuccess).settings['data'] as Map;
    }
    return {};
  }

  dynamic _getSetting(Map<dynamic, dynamic> settings, SystemSetting selected) {
    final selectedSettingData =
        (settings['data'] as Map? ?? {})[Constant.systemSettingKeys[selected]];

    return selectedSettingData;
  }
}
