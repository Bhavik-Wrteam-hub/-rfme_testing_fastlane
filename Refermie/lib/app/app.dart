import 'package:ebroker/data/repositories/favourites_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/firebase_options.dart';
import 'package:flutter/material.dart';

PersonalizedInterestSettings personalizedInterestSettings =
    PersonalizedInterestSettings.empty();
AppSettingsDataModel appSettings = fallbackSettingAppSettings;

Future<void> initApp() async {
  ///Note: this file's code is very necessary and sensitive if you change it,
  ///This might affect whole app , So change it carefully.
  ///This is must, do not remove this line
  await HiveUtils.initBoxes();
  Api.initInterceptors();
  Api.initCurlLoggerInterceptor();

  ///This is the widget to show uncaught runtime error in this custom widget so
  ///that user can know in that screen something is wrong instead of grey screen
  SomethingWentWrong.asGlobalErrorBuilder();

  if (Firebase.apps.isNotEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  await SystemChrome.setPreferredOrientations([
    .portraitUp,
  ]).then((_) async {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
    );
    await LoadAppSettings().load(initBox: false);
    runApp(const EntryPoint());
  });
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  void initState() {
    context.read<LanguageCubit>().loadCurrentLanguage();

    ///THIS WILL be CALLED WHEN USER WILL LOGIN FROM ANONYMOUS USER.
    context.read<LikedPropertiesCubit>().clear();

    unawaited(
      loadInitialData(
        context,
        loadWithoutDelay: true,
      ),
    );

    UiUtils.setContext(context);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await DeepLinkManager.initDeepLinks(context);
    });
    super.initState();
  }

  @override
  void dispose() {
    DeepLinkManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GetApiKeysCubit, GetApiKeysState>(
      listener: (context, state) {
        context.read<GetApiKeysCubit>().setAPIKeys();
      },
      child: BlocBuilder<LanguageCubit, LanguageState>(
        builder: (context, languageState) {
          return BlocBuilder<AppThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp(
                initialRoute: Routes.splash,
                navigatorKey: Constant.navigatorKey,
                title: Constant.appName,
                debugShowCheckedModeBanner: false,
                onGenerateRoute: Routes.onGenerateRouted,
                themeMode: themeMode,
                theme: appThemeData[Brightness.light],
                darkTheme: appThemeData[Brightness.dark],
                builder: (context, child) {
                  ErrorFilter.setContext(context);
                  TextDirection direction;

                  // Set text direction based on language
                  if (languageState is LanguageLoader) {
                    direction = languageState.isRTL ? .rtl : .ltr;
                  } else {
                    direction = .ltr;
                  }

                  return MediaQuery(
                    data: MediaQuery.of(context).copyWith(
                      textScaler: TextScaler.noScaling,
                    ),
                    child: Directionality(
                      textDirection: direction,
                      child: child!,
                    ),
                  );
                },
                localizationsDelegates: const [
                  AppLocalization.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                locale: loadLocalLanguageIfFail(languageState),
              );
            },
          );
        },
      ),
    );
  }

  Locale loadLocalLanguageIfFail(LanguageState state) {
    if (state is LanguageLoader) {
      return Locale(state.languageCode.toString());
    } else {
      return const Locale('en');
    }
  }
}

Future<void> loadInitialData(
  BuildContext context, {
  bool? loadWithoutDelay,
  bool? forceRefresh,
}) async {
  if (!HiveUtils.isGuest()) {
    final favoritesData = await FavoriteRepository().fechFavorites(offset: 0);
    final favoriteIds = favoritesData.modelList
        .map((property) => property.id!)
        .toList();
    context.read<LikedPropertiesCubit>().setFavorites(favoriteIds);
  }
  if (context.read<FetchCategoryCubit>().state is! FetchCategorySuccess) {
    await context.read<FetchCategoryCubit>().fetchCategories(
      loadWithoutDelay: loadWithoutDelay,
      forceRefresh: forceRefresh,
    );
  }
  await context.read<FetchNearbyPropertiesCubit>().fetch(
    loadWithoutDelay: loadWithoutDelay,
    forceRefresh: forceRefresh,
  );

  if (context.read<AuthenticationCubit>().isAuthenticated()) {
    await context.read<GetChatListCubit>().setContext(context);
    await context.read<GetChatListCubit>().fetch(
      forceRefresh: forceRefresh ?? false,
    );
    await context.read<FetchPersonalizedPropertyList>().fetch(
      loadWithoutDelay: loadWithoutDelay,
      forceRefresh: forceRefresh,
    );

    await PersonalizedFeedRepository().getUserPersonalizedSettings().then((
      value,
    ) {
      personalizedInterestSettings = value;
    });
  }

  GuestChecker.listen().addListener(() async {
    if (!GuestChecker.value) {
      await PersonalizedFeedRepository().getUserPersonalizedSettings().then((
        value,
      ) {
        personalizedInterestSettings = value;
      });
    }
  });
}
