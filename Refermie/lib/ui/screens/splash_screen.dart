import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/system_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/hive_keys.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AuthenticationState authenticationState;

  bool isSettingsLoaded = false;
  bool isLanguageLoaded = false;

  @override
  void initState() {
    unawaited(connectivityCheck());
    unawaited(
      getDefaultLanguage(
        onSuccess: () {
          if (mounted) {
            setState(() {
              isLanguageLoaded = true;
            });
          }
        },
        context: context,
      ),
    );

    unawaited(checkIsUserAuthenticated());
    super.initState();

    unawaited(MobileAds.instance.initialize());
  }

  Future<void> connectivityCheck() async {
    await Connectivity().checkConnectivity().then((value) async {
      if (value.contains(ConnectivityResult.none)) {
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute<dynamic>(
            builder: (context) {
              return NoInternet(
                onRetry: () async {
                  try {
                    await LoadAppSettings().load(initBox: true);

                    // Check internet connectivity before redirecting
                    final connectivityResult = await Connectivity()
                        .checkConnectivity();
                    if (!connectivityResult.contains(ConnectivityResult.none)) {
                      // Only redirect to splash screen if internet is available
                      Future.delayed(Duration.zero, () async {
                        await Navigator.pushReplacementNamed(
                          context,
                          Routes.splash,
                        );
                      });
                    } else {
                      HelperUtils.showSnackBarMessage(
                        context,
                        isFloating: true,
                        'noInternetErrorMsg',
                      );
                    }
                  } on Exception catch (_) {
                    log('no internet');
                  }
                },
              );
            },
          ),
        );
      }
    });
  }

  Future<void> checkIsUserAuthenticated() async {
    authenticationState = context.read<AuthenticationCubit>().state;
    if (authenticationState == AuthenticationState.authenticated) {
      ///Only load sensitive details if user is authenticated
      ///This call will load sensitive details with settings
      await context.read<FetchSystemSettingsCubit>().fetchSettings(
        isAnonymous: false,
      );
    } else {
      //This call will hide sensitive details.
      await context.read<FetchSystemSettingsCubit>().fetchSettings(
        isAnonymous: true,
      );
    }
  }

  Future<void> navigateCheck() async {
    ({
      'isSettingsLoaded': isSettingsLoaded,
      'isLanguageLoaded': isLanguageLoaded,
    }).logg;

    if (isSettingsLoaded && isLanguageLoaded) {
      await validateCurrentLanguage();
    }
  }

  Future<void> validateCurrentLanguage() async {
    final currentLanguageCode = HiveUtils.getLanguageCode();

    // Check if current language exists in AppSettings.languages
    final isCurrentLanguageAvailable = AppSettings.languages.any(
      (language) => language.code == currentLanguageCode,
    );

    if (!isCurrentLanguageAvailable && AppSettings.languages.isNotEmpty) {
      // Current language not available, switch to first language
      final firstLanguage = AppSettings.languages.first;

      // Load the first available language
      await context
          .read<FetchLanguageCubit>()
          .getLanguage(firstLanguage.code!)
          .then((_) async {
            final state = context.read<FetchLanguageCubit>().state;
            if (state is FetchLanguageSuccess) {
              final map = state.toMap();
              final data = map['file_name'];
              map['data'] = data;
              map.remove('file_name');

              await HiveUtils.storeLanguage(map).then((_) {
                context.read<LanguageCubit>().emitLanguageLoader(
                  code: state.code,
                  isRtl: state.isRTL,
                );
                navigateToScreen();
              });
            } else {
              // If language loading fails, proceed with navigation
              navigateToScreen();
            }
          })
          .catchError((dynamic error) {
            // Proceed with navigation even if language loading fails
            navigateToScreen();
          });
    } else {
      // Current language is valid or no languages available, proceed normally
      navigateToScreen();
    }
  }

  void navigateToScreen() {
    if (context.read<FetchSystemSettingsCubit>().getSetting(
          SystemSetting.maintenanceMode,
        ) ==
        '1') {
      Future.delayed(Duration.zero, () async {
        await Navigator.of(
          context,
        ).pushReplacementNamed(Routes.maintenanceMode);
      });
    } else if (authenticationState == AuthenticationState.authenticated) {
      Future.delayed(Duration.zero, () async {
        await Navigator.of(
          context,
        ).pushReplacementNamed(Routes.main, arguments: {'from': 'main'});
      });
    } else if (authenticationState == AuthenticationState.unAuthenticated) {
      if (Hive.box<dynamic>(HiveKeys.userDetailsBox).get('isGuest') == true) {
        Future.delayed(Duration.zero, () async {
          await Navigator.of(
            context,
          ).pushReplacementNamed(Routes.main, arguments: {'from': 'splash'});
        });
      } else {
        Future.delayed(Duration.zero, () async {
          await Navigator.of(context).pushReplacementNamed(Routes.login);
        });
      }
    } else if (authenticationState == AuthenticationState.firstTime) {
      Future.delayed(Duration.zero, () async {
        await Navigator.of(context).pushReplacementNamed(Routes.onboarding);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    unawaited(navigateCheck());

    return BlocListener<FetchLanguageCubit, FetchLanguageState>(
      listener: (context, state) {},
      child: BlocListener<FetchSystemSettingsCubit, FetchSystemSettingsState>(
        listener: (context, state) {
          if (state is FetchSystemSettingsFailure) {
            log(
              'FetchSystemSettings Issue while load system settings ${state.errorMessage}',
            );
          }
          if (state is FetchSystemSettingsSuccess) {
            final setting = <dynamic>[];
            if (setting.isNotEmpty) {
              if ((setting[0] as Map).containsKey('package_id')) {
                Constant.subscriptionPackageId = '';
              }
            }

            isSettingsLoaded = true;
            setState(() {});
          }
        },
        child: AnnotatedRegion(
          value: SystemUiOverlayStyle(
            statusBarColor: context.color.tertiaryColor,
            systemNavigationBarColor: context.color.tertiaryColor,
          ),
          child: Scaffold(
            backgroundColor: context.color.tertiaryColor,
            extendBody: true,
            body: Stack(
              children: [
                Center(
                  child: Container(
                    alignment: Alignment.center,
                    child: CustomImage(
                      imageUrl: AppIcons.splashLogo,
                      height: 151.rs(context),
                    ),
                  ),
                ),
                // Padding(
                //   padding: const EdgeInsets.symmetric(vertical: 16),
                //   child: Align(
                //     alignment: Alignment.bottomCenter,
                //     key: const ValueKey('companylogo'),
                //     child: CustomImage(
                //       imageUrl: AppIcons.companyLogo,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<dynamic> getDefaultLanguage({
  required VoidCallback onSuccess,
  required BuildContext context,
}) async {
  try {
    await Hive.openBox<dynamic>(HiveKeys.languageBox);
    await Hive.openBox<dynamic>(HiveKeys.userDetailsBox);
    await Hive.openBox<dynamic>(HiveKeys.authBox);

    if (HiveUtils.getLanguage() == null ||
        HiveUtils.getLanguage()?['data'] == null) {
      final result = await SystemRepository().fetchSystemSettings(
        isAnonymouse: true,
      );

      final code = result['data']?['default_language']?.toString() ?? 'en';
      await context.read<FetchLanguageCubit>().getLanguage(code);
      final state = context.read<FetchLanguageCubit>().state;

      if (state is FetchLanguageSuccess) {
        Widgets.hideLoder(context);
        final map = state.toMap();
        final data = map['file_name'];
        map['data'] = data;

        map.remove('file_name');
        await HiveUtils.storeLanguage(map);
        context.read<LanguageCubit>().emitLanguageLoader(
          code: state.code,
          isRtl: state.isRTL,
        );
      }
      onSuccess.call();
    } else {
      onSuccess.call();
    }
  } on Exception catch (e, st) {
    log('Error while load default language $e\n$st');
    // Fallback: proceed with default template language to avoid blocking splash
    onSuccess.call();
  }
}
