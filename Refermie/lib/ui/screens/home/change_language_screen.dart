import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';

class LanguagesListScreen extends StatefulWidget {
  const LanguagesListScreen({super.key});
  static Route<dynamic> route(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (context) => const LanguagesListScreen(),
    );
  }

  @override
  State<LanguagesListScreen> createState() => _LanguagesListScreenState();
}

class _LanguagesListScreenState extends State<LanguagesListScreen> {
  String? _initialLanguageCode;
  bool _hasSyncedLanguageChange = false;

  @override
  void initState() {
    super.initState();
    // Store the initial language code when the screen is first built
    _initialLanguageCode =
        (context.read<LanguageCubit>().state as LanguageLoader).languageCode
            .toString();
  }

  @override
  Widget build(BuildContext context) {
    final setting =
        context.watch<FetchSystemSettingsCubit>().getSetting(
              SystemSetting.languageType,
            )
            as List;

    final languageState = context.watch<LanguageCubit>().state;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final currentLanguageCode =
            (context.read<LanguageCubit>().state as LanguageLoader).languageCode
                .toString();
        // Only update if language has changed
        if (currentLanguageCode != _initialLanguageCode) {
          if (!_hasSyncedLanguageChange) {
            await _syncLanguageChange(context, currentLanguageCode);
          }
        }
        Navigator.pop(context);
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: CustomAppBar(
          title: 'chooseLanguage'.translate(context),
          onTapBackButton: () async {
            final currentLanguageCode =
                (context.read<LanguageCubit>().state as LanguageLoader)
                    .languageCode
                    .toString();
            // Only update if language has changed
            if (currentLanguageCode != _initialLanguageCode) {
              if (!_hasSyncedLanguageChange) {
                await _syncLanguageChange(context, currentLanguageCode);
              }
            }
          },
        ),
        body:
            context.watch<FetchSystemSettingsCubit>().getSetting(
                  SystemSetting.languageType,
                ) ==
                null
            ? Center(child: UiUtils.progress())
            : MultiBlocListener(
                listeners: [
                  BlocListener<FetchLanguageCubit, FetchLanguageState>(
                    listener: (context, state) async {
                      if (state is FetchLanguageInProgress) {
                        unawaited(Widgets.showLoader(context));
                      }
                      if (state is FetchLanguageFailure) {
                        Widgets.hideLoder(context);
                        HelperUtils.showSnackBarMessage(
                          context,
                          state.errorMessage,
                        );
                      }
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
                        await _syncLanguageChange(context, state.code);
                      }
                    },
                  ),
                  BlocListener<UpdateLanguageCubit, UpdateLanguageState>(
                    listener: (context, state) async {
                      if (state is UpdateLanguageInProgress) {
                        unawaited(Widgets.showLoader(context));
                      } else if (state is UpdateLanguageFailure) {
                        Widgets.hideLoder(context);
                        HelperUtils.showSnackBarMessage(
                          context,
                          state.errorMessage,
                        );
                      } else if (state is UpdateLanguageSuccess ||
                          state is UpdateLanguageSkipped) {
                        Widgets.hideLoder(context);
                      }
                    },
                  ),
                ],
                child: ListView.separated(
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 8),
                  physics: Constant.scrollPhysics,
                  padding: const EdgeInsets.all(18),
                  itemCount: setting.length,
                  itemBuilder: (context, index) {
                    final languageLoader = languageState as LanguageLoader;
                    final currentLanguageCode = languageLoader.languageCode
                        .toString();
                    final color =
                        languageLoader.languageCode == setting[index]['code']
                        ? context.color.tertiaryColor
                        : context.color.textLightColor.withValues(alpha: 0.03);

                    return GestureDetector(
                      onTap: () async {
                        final selectedCode =
                            setting[index]['code']?.toString() ?? '';
                        final currentCode = currentLanguageCode;

                        if (selectedCode == currentCode) {
                          return;
                        }
                        _hasSyncedLanguageChange = false;
                        await context.read<FetchLanguageCubit>().getLanguage(
                          selectedCode,
                        );
                      },
                      child: Container(
                        height: 48.rh(context),
                        alignment: AlignmentDirectional.centerStart,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.all(12),
                        child: CustomText(
                          setting[index]['name']?.toString() ?? '',
                          fontWeight: .bold,
                          fontSize: context.font.md,
                          color:
                              languageLoader.languageCode ==
                                  setting[index]['code']
                              ? context.color.buttonColor
                              : context.color.textColorDark,
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }

  Future<void> _syncLanguageChange(
    BuildContext context,
    String languageCode,
  ) async {
    await context.read<UpdateLanguageCubit>().updateLanguage(
      languageCode: languageCode,
    );
    LanguageChangeHelper.refreshAppData(context);
    _hasSyncedLanguageChange = true;
  }
}
