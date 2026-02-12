import 'dart:async';

import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/cubits/system/fetch_language_cubit.dart';
import 'package:ebroker/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:ebroker/data/cubits/system/language_cubit.dart';
import 'package:ebroker/data/cubits/system/update_language_cubit.dart';
import 'package:ebroker/data/helper/widgets.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/language_change_helper.dart';
import 'package:ebroker/utils/lottie/lottie_editor.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int currentPageIndex = 0;
  int previousePageIndex = 0;
  double changedOnPageScroll = 0.5;
  double currentSwipe = 0;
  late int totalPages;

  final LottieEditor _onBoardingOne = LottieEditor();
  final LottieEditor _onBoardingTwo = LottieEditor();
  final LottieEditor _onBoardingThree = LottieEditor();

  dynamic onBoardingOneData;
  dynamic onBoardingTwoData;
  dynamic onBoardingThreeData;

  @override
  void initState() {
    unawaited(_onBoardingOne.openAndLoad('assets/lottie/onbo_a.json'));
    unawaited(_onBoardingTwo.openAndLoad('assets/lottie/onbo_b.json'));
    unawaited(_onBoardingThree.openAndLoad('assets/lottie/onbo_c.json'));

    Future.delayed(
      Duration.zero,
      () {
        _onBoardingOne.changeWholeLottieFileColor(context.color.tertiaryColor);
        _onBoardingTwo.changeWholeLottieFileColor(context.color.tertiaryColor);
        _onBoardingThree.changeWholeLottieFileColor(
          context.color.tertiaryColor,
        );

        onBoardingOneData = _onBoardingOne.convertToUint8List();
        onBoardingTwoData = _onBoardingTwo.convertToUint8List();
        onBoardingThreeData = _onBoardingThree.convertToUint8List();
        setState(() {});
      },
    );

    Future.delayed(Duration.zero, () {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final slidersList = [
      {
        'lottie': onBoardingOneData,
        'title': 'onboarding_1_title'.translate(context),
        'description': 'onboarding_1_description'.translate(context),
        'button': 'next_button.svg',
      },
      {
        'lottie': onBoardingTwoData,
        'title': 'onboarding_2_title'.translate(context),
        'description': 'onboarding_2_description'.translate(context),
      },
      {
        'lottie': onBoardingThreeData,
        'title': 'onboarding_3_title'.translate(context),
        'description': 'onboarding_3_description'.translate(context),
      },
    ];

    totalPages = slidersList.length;
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        body: Stack(
          children: <Widget>[
            Container(
              color: context.color.tertiaryColor.withValues(alpha: 0.1),
            ),
            PositionedDirectional(
              bottom: 282.rh(context),
              child: SizedBox(
                height: 400.rh(context),
                width: context.screenWidth,
                child: (slidersList[currentPageIndex]['lottie'] != null)
                    ? Lottie.memory(
                        width: 350.rw(context),
                        height: 350.rh(context),
                        fit: .contain,
                        Uint8List.fromList(
                          slidersList[currentPageIndex]['lottie']
                                  as List<int>? ??
                              [],
                        ),
                        delegates: const LottieDelegates(
                          values: [],
                        ),
                        errorBuilder: (context, error, stackTrace) {
                          return Container();
                        },
                      )
                    : Container(),
              ),
            ),
            PositionedDirectional(
              top: kPagingTouchSlop + 16.rh(context),
              start: 16,
              child: MultiBlocListener(
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
                        // Update all data after language change
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
                child: _buildLanguageDropdown(),
              ),
            ),
            PositionedDirectional(
              top: kPagingTouchSlop + 16.rh(context),
              end: 16.rw(context),
              child: GestureDetector(
                onTap: () async {
                  await Navigator.pushReplacementNamed(context, Routes.login);
                },
                child: CustomText(
                  'skip'.translate(context),
                  color: context.color.textColorDark,
                  fontSize: context.font.md,
                  fontWeight: .w600,
                ),
              ),
            ),
            PositionedDirectional(
              bottom: 0,
              child: GestureDetector(
                onHorizontalDragUpdate: (DragUpdateDetails details) {
                  currentSwipe = details.localPosition.direction;
                  setState(() {});
                },
                onHorizontalDragEnd: (details) {
                  if (currentSwipe < 0.5) {
                    if (changedOnPageScroll == 1 ||
                        changedOnPageScroll == 0.5) {
                      if (currentPageIndex > 0) {
                        currentPageIndex--;
                        changedOnPageScroll = 0;
                      }
                    }
                    setState(() {});
                  } else {
                    if (currentPageIndex < totalPages) {
                      if (changedOnPageScroll == 0 ||
                          changedOnPageScroll == 0.5) {
                        if (currentPageIndex < slidersList.length - 1) {
                          currentPageIndex++;
                        }
                        setState(() {});
                      }
                    }
                  }

                  changedOnPageScroll = 0.5;
                  setState(() {});
                },
                child: Container(
                  height: 282.rh(context),
                  width: context.screenWidth,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(48),
                      topRight: Radius.circular(48),
                    ),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: CustomText(
                          slidersList[currentPageIndex]['title']?.toString() ??
                              '',
                          key: const Key('onboarding_title'),
                          fontWeight: .w500,
                          fontSize: context.font.xxl,
                          color: context.color.tertiaryColor,
                          textAlign: .center,
                        ),
                      ),
                      CustomText(
                        slidersList[currentPageIndex]['description']
                                ?.toString() ??
                            '',
                        maxLines: 3,
                        textAlign: .center,
                        fontSize: context.font.md,
                        color: context.color.textColorDark,
                        fontWeight: .w600,
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Row(
                            children: [
                              for (var i = 0; i < slidersList.length; i++) ...[
                                buildIndicator(
                                  context,
                                  selected: i == currentPageIndex,
                                ),
                              ],
                            ],
                          ),
                          const Spacer(),
                          GestureDetector(
                            key: const ValueKey('next_screen'),
                            onTap: () async {
                              if (currentPageIndex < slidersList.length - 1) {
                                currentPageIndex++;
                                setState(() {});
                              } else {
                                await Navigator.of(
                                  context,
                                ).pushNamedAndRemoveUntil(
                                  Routes.login,
                                  (route) => false,
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              width: 48.rw(context),
                              height: 48.rh(context),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: context.color.tertiaryColor,
                                shape: .circle,
                              ),
                              child: CustomImage(
                                matchTextDirection: true,
                                imageUrl: AppIcons.arrowRight,
                                fit: .contain,
                                color: context.color.backgroundColor,
                                width: 24.rw(context),
                                height: 24.rh(context),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildIndicator(BuildContext context, {required bool selected}) {
    if (selected) {
      return Container(
        margin: const EdgeInsetsDirectional.only(end: 10),
        width: 28.rw(context),
        height: 8.rh(context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(7),
          color: context.color.tertiaryColor,
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsetsDirectional.only(end: 10),
        width: 8.rw(context),
        height: 8.rh(context),
        decoration: BoxDecoration(
          shape: .circle,
          border: Border.all(
            color: context.color.textColorDark,
          ),
        ),
      );
    }
  }

  Widget _buildLanguageDropdown() {
    final languageSettings =
        context.watch<FetchSystemSettingsCubit>().getSetting(
              SystemSetting.languageType,
            )
            as List?;

    if (languageSettings == null || languageSettings.isEmpty) {
      return Container();
    }

    final languageState = context.watch<LanguageCubit>().state;
    var currentLanguageCode = '';
    var currentLanguageName = '';

    if (languageState is LanguageLoader) {
      currentLanguageCode = languageState.languageCode.toString();
      // Find the current language name
      final currentLang = languageSettings.firstWhere(
        (lang) => lang['code'].toString() == currentLanguageCode,
        orElse: () => languageSettings.first,
      );
      currentLanguageName = currentLang['name'].toString().firstUpperCase();
    }

    return PopupMenuButton<String>(
      color: context.color.secondaryColor,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      offset: const Offset(0, 40),
      onSelected: (String newLanguageCode) async {
        if (newLanguageCode != currentLanguageCode) {
          await context.read<FetchLanguageCubit>().getLanguage(newLanguageCode);
        }
      },
      itemBuilder: (BuildContext context) {
        return languageSettings.map<PopupMenuEntry<String>>((language) {
          final languageCode = language['code'].toString();
          final isSelected = languageCode == currentLanguageCode;

          return PopupMenuItem<String>(
            value: languageCode,
            child: Row(
              children: [
                CustomText(
                  language['name'].toString().firstUpperCase(),
                  color: isSelected
                      ? context.color.tertiaryColor
                      : context.color.textColorDark,
                  fontSize: context.font.md,
                  fontWeight: isSelected ? .bold : .w600,
                ),
                if (isSelected) ...[
                  const Spacer(),
                  Icon(
                    Icons.check,
                    color: context.color.tertiaryColor,
                    size: 20,
                  ),
                ],
              ],
            ),
          );
        }).toList();
      },
      child: Row(
        mainAxisSize: .min,
        children: [
          CustomText(
            currentLanguageName,
            color: context.color.textColorDark,
            fontSize: context.font.md,
            fontWeight: .w600,
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.keyboard_arrow_down_outlined,
            color: context.color.textColorDark,
            size: 24,
          ),
        ],
      ),
    );
  }

  Future<void> _syncLanguageChange(
    BuildContext context,
    String languageCode,
  ) async {
    await context
        .read<UpdateLanguageCubit>()
        .updateLanguage(languageCode: languageCode);
    LanguageChangeHelper.refreshAppData(context);
  }
}
