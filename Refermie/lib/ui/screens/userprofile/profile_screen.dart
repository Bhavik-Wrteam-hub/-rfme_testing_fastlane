import 'dart:developer';

import 'package:ebroker/data/cubits/appointment/get/fetch_agent_previous_appointments_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_agent_time_schedules_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_agent_upcoming_appointments_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_booking_preferences_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_user_previous_appointments_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_user_upcoming_appointments_cubit.dart';
import 'package:ebroker/data/cubits/auth/get_user_data_cubit.dart';
import 'package:ebroker/data/cubits/property/report/property_report_cubit.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/data/repositories/system_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/widgets/custom_refresh_indicator.dart';
import 'package:ebroker/ui/screens/userprofile/appointment_dropdown_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with AutomaticKeepAliveClientMixin<ProfileScreen> {
  String verificationStatus = '';
  bool isGuest = false;
  @override
  void initState() {
    final settings = context.read<FetchSystemSettingsCubit>();

    isGuest = GuestChecker.value;
    GuestChecker.listen().addListener(() {
      isGuest = GuestChecker.value;
      if (mounted) setState(() {});
    });
    if (!const bool.fromEnvironment(
      'force-disable-demo-mode',
    )) {
      Constant.isDemoModeOn =
          settings.getSetting(SystemSetting.demoMode) as bool? ?? false;
    }

    // Ensure latest user data is fetched so agent flags update UI
    unawaited(
      Future.microtask(() async {
        if (!GuestChecker.value) {
          await context.read<GetUserDataCubit>().getUserData(context);
        }
      }),
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  bool get wantKeepAlive => true;
  int? a;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final settings = context.watch<FetchSystemSettingsCubit>();
    verificationStatus =
        settings.getSetting(SystemSetting.verificationStatus)?.toString() ?? '';
    if (!const bool.fromEnvironment(
      'force-disable-demo-mode',
    )) {
      Constant.isDemoModeOn =
          settings.getSetting(SystemSetting.demoMode) as bool? ?? false;
    }
    var username = 'anonymous'.translate(context);
    var email = 'notLoggedIn'.translate(context);
    if (!isGuest) {
      final user = context.watch<UserDetailsCubit>().state.user;
      username = user?.name!.firstUpperCase() ?? 'anonymous'.translate(context);
      email = user?.email ?? 'notLoggedIn'.translate(context);
    }
    final systemSettingsState = context.read<FetchSystemSettingsCubit>().state;

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: CustomAppBar(
          title: 'myProfile'.translate(context),
          isFromHome: true,
          showBackButton: false,
        ),
        body: BlocListener<DeleteAccountCubit, DeleteAccountState>(
          listener: (context, state) async {
            if (state is DeleteAccountProgress) {
              unawaited(Widgets.showLoader(context));
            }
            if (state is DeleteAccountFailure) {
              Widgets.hideLoder(context);
            }
            if (state is AccountDeleted) {
              Widgets.hideLoder(context);
              context.read<UserDetailsCubit>().clear();
              await Navigator.pushReplacementNamed(context, Routes.login);
            }
          },
          child: CustomRefreshIndicator(
            onRefresh: () async {
              await context.read<FetchSystemSettingsCubit>().fetchSettings(
                isAnonymous: GuestChecker.value,
              );
              await context.read<GetApiKeysCubit>().fetch();
              if (!GuestChecker.value) {
                await context.read<GetUserDataCubit>().getUserData(context);
              }
            },
            child: systemSettingsState is FetchSystemSettingsInProgress
                ? buildProfileLoadingShimmer()
                : SingleChildScrollView(
                    physics: Constant.scrollPhysics,
                    controller: profileScreenController,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: <Widget>[
                          // Profile Image and Name
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: context.color.borderColor,
                              ),
                              color: context.color.secondaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: profileImgWidget(),
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: .start,
                                    children: <Widget>[
                                      CustomText(
                                        username,
                                        color: context.color.inverseSurface,
                                        fontSize: context.font.md,
                                        fontWeight: .w700,
                                        maxLines: 2,
                                      ),
                                      CustomText(
                                        email,
                                        color: context.color.textColorDark,
                                        fontSize: context.font.xs,
                                        maxLines: 1,
                                      ),
                                      if (!isGuest &&
                                          (HiveUtils.getUserDetails().isAgent ??
                                              false)) ...[
                                        const SizedBox(height: 8),
                                        _buildVerificationUI(
                                          context,
                                          verificationStatus,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                if (isGuest)
                                  Container(
                                    margin: EdgeInsetsDirectional.only(
                                      end: 16.rw(context),
                                    ),
                                    child: UiUtils.buildButton(
                                      context,
                                      height: 32.rh(context),
                                      fontSize: context.font.xs,
                                      showElevation: false,
                                      buttonTitle: 'login'.translate(context),
                                      buttonColor: context.color.secondaryColor,
                                      textColor: context.color.textLightColor,
                                      autoWidth: true,
                                      border: BorderSide(
                                        color: context.color.borderColor,
                                      ),
                                      onPressed: () async {
                                        await Navigator.pushReplacementNamed(
                                          context,
                                          Routes.login,
                                        );
                                      },
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          // Profile Settings
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: context.color.borderColor,
                              ),
                              color: context.color.secondaryColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                if (!isGuest)
                                  customTile(
                                    context,
                                    title: 'editProfile'.translate(context),
                                    svgImagePath: AppIcons.profile,
                                    onTap: () async {
                                      await HelperUtils.goToNextPage(
                                        Routes.editProfile,
                                        context,
                                        false,
                                        args: {'from': 'profile'},
                                      );
                                    },
                                  ),
                                if (!isGuest) dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'myProjects'.translate(context),
                                  svgImagePath: AppIcons.myProjects,
                                  onTap: () async {
                                    await GuestChecker.check(
                                      onNotGuest: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          Routes.myProjects,
                                        );
                                      },
                                    );
                                  },
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'myAds'.translate(context),
                                  svgImagePath: AppIcons.promoted,
                                  onTap: () async {
                                    await GuestChecker.check(
                                      onNotGuest: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          Routes.myAdvertisment,
                                        );
                                      },
                                    );
                                  },
                                ),
                                dividerWithSpacing(),
                                appointmentDropdownTile(),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'subscription'.translate(context),
                                  svgImagePath: AppIcons.subscription,
                                  onTap: () async {
                                    await GuestChecker.check(
                                      onNotGuest: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          Routes.subscriptionPackageListRoute,
                                        );
                                      },
                                    );
                                  },
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'transactionHistory'.translate(
                                    context,
                                  ),
                                  svgImagePath: AppIcons.transaction,
                                  onTap: () async {
                                    await GuestChecker.check(
                                      onNotGuest: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          Routes.transactionHistory,
                                        );
                                      },
                                    );
                                  },
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'personalized'.translate(context),
                                  svgImagePath: AppIcons.magic,
                                  onTap: () async {
                                    await GuestChecker.check(
                                      onNotGuest: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          Routes.personalizedPropertyScreen,
                                          arguments: {
                                            'type':
                                                PersonalizedVisitType.normal,
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'faqScreen'.translate(context),
                                  svgImagePath: AppIcons.faqs,
                                  onTap: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      Routes.faqsScreen,
                                    );
                                  },
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'language'.translate(context),
                                  svgImagePath: AppIcons.language,
                                  onTap: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      Routes.languageListScreenRoute,
                                    );
                                  },
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'darkTheme'.translate(context),
                                  svgImagePath: AppIcons.darkTheme,
                                  isSwitchBox: true,
                                  onTap: () {},
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'notifications'.translate(context),
                                  svgImagePath: AppIcons.notification,
                                  onTap: () async {
                                    await GuestChecker.check(
                                      onNotGuest: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          Routes.notificationPage,
                                        );
                                      },
                                    );
                                  },
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'articles'.translate(context),
                                  svgImagePath: AppIcons.articles,
                                  onTap: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      Routes.articlesScreenRoute,
                                    );
                                  },
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'favorites'.translate(context),
                                  svgImagePath: AppIcons.heartFilled,
                                  onTap: () async {
                                    await GuestChecker.check(
                                      onNotGuest: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          Routes.favoritesScreen,
                                        );
                                      },
                                    );
                                  },
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'areaConvertor'.translate(context),
                                  svgImagePath: AppIcons.areaConvertor,
                                  onTap: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      Routes.areaConvertorScreen,
                                    );
                                  },
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'shareApp'.translate(context),
                                  svgImagePath: AppIcons.shareApp,
                                  onTap: shareApp,
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'rateUs'.translate(context),
                                  svgImagePath: AppIcons.rateUs,
                                  onTap: rateUs,
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'contactUs'.translate(context),
                                  svgImagePath: AppIcons.contactUs,
                                  onTap: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      Routes.contactUs,
                                    );
                                  },
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'aboutUs'.translate(context),
                                  svgImagePath: AppIcons.aboutUs,
                                  onTap: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      Routes.profileSettings,
                                      arguments: {
                                        'title': 'aboutUs'.translate(context),
                                        'param': Api.aboutApp,
                                      },
                                    );
                                  },
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'termsConditions'.translate(context),
                                  svgImagePath: AppIcons.terms,
                                  onTap: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      Routes.profileSettings,
                                      arguments: {
                                        'title': 'termsConditions'.translate(
                                          context,
                                        ),
                                        'param': Api.termsAndConditions,
                                      },
                                    );
                                  },
                                ),
                                dividerWithSpacing(),
                                customTile(
                                  context,
                                  title: 'privacyPolicy'.translate(context),
                                  svgImagePath: AppIcons.privacy,
                                  onTap: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      Routes.profileSettings,
                                      arguments: {
                                        'title': 'privacyPolicy'.translate(
                                          context,
                                        ),
                                        'param': Api.privacyPolicy,
                                      },
                                    );
                                  },
                                ),
                                if (Constant.isUpdateAvailable) ...[
                                  dividerWithSpacing(),
                                  updateTile(
                                    context,
                                    isUpdateAvailable:
                                        Constant.isUpdateAvailable,
                                    title: 'update'.translate(context),
                                    newVersion: Constant.newVersionNumber,
                                    svgImagePath: AppIcons.update,
                                    onTap: () async {
                                      if (Platform.isIOS) {
                                        await launchUrl(
                                          Uri.parse(Constant.appstoreURLios),
                                        );
                                      } else if (Platform.isAndroid) {
                                        await launchUrl(
                                          Uri.parse(
                                            Constant.playstoreURLAndroid,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                                if (!isGuest) ...[
                                  dividerWithSpacing(),
                                  customTile(
                                    context,
                                    title: 'deleteAccount'.translate(context),
                                    svgImagePath: AppIcons.delete,
                                    onTap: () async {
                                      if (Constant.isDemoModeOn &&
                                          (HiveUtils.getUserDetails()
                                                  .isDemoUser ??
                                              false)) {
                                        HelperUtils.showSnackBarMessage(
                                          context,
                                          'thisActionNotValidDemo',
                                        );
                                        return;
                                      }

                                      await deleteConfirmWidget(
                                        'deleteProfileMessageTitle'.translate(
                                          context,
                                        ),
                                        'deleteProfileMessageContent'.translate(
                                          context,
                                        ),
                                        true,
                                      );
                                    },
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          if (!isGuest) ...[
                            UiUtils.buildButton(
                              context,
                              onPressed: logOutConfirmWidget,
                              height: 52.rh(context),
                              prefixWidget: Padding(
                                padding: const EdgeInsetsDirectional.only(
                                  end: 16,
                                ),
                                child: FittedBox(
                                  fit: .none,
                                  child: CustomImage(
                                    imageUrl: AppIcons.logout,
                                    width: 24.rw(context),
                                    height: 24.rh(context),
                                    color: context.color.buttonColor,
                                  ),
                                ),
                              ),
                              buttonTitle: 'logout'.translate(context),
                            ),
                            const SizedBox(
                              height: 18,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget buildProfileLoadingShimmer() {
    return SingleChildScrollView(
      physics: Constant.scrollPhysics,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomShimmer(height: MediaQuery.of(context).size.height * 0.13),
            const SizedBox(
              height: 16,
            ),
            CustomShimmer(
              height: MediaQuery.of(context).size.height,
            ),
            const SizedBox(
              height: 16,
            ),
            CustomShimmer(height: MediaQuery.of(context).size.height * 0.07),
          ],
        ),
      ),
    );
  }

  Padding dividerWithSpacing() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Container(
        height: 1,
        color: context.color.borderColor,
      ),
    );
  }

  Widget updateTile(
    BuildContext context, {
    required String title,
    required String newVersion,
    required bool isUpdateAvailable,
    required String svgImagePath,
    required VoidCallback onTap,
    dynamic Function(dynamic value)? onTapSwitch,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: GestureDetector(
        onTap: () {
          if (isUpdateAvailable) {
            onTap.call();
          }
        },
        child: Row(
          children: [
            Container(
              width: 40.rw(context),
              height: 40.rh(context),
              decoration: BoxDecoration(
                color: context.color.tertiaryColor.withValues(
                  alpha: 0.1,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: FittedBox(
                fit: .none,
                child: !isUpdateAvailable
                    ? const Icon(Icons.done)
                    : CustomImage(
                        imageUrl: svgImagePath,
                        color: context.color.tertiaryColor,
                      ),
              ),
            ),
            SizedBox(
              width: 25.rw(context),
            ),
            Column(
              crossAxisAlignment: .start,
              children: [
                CustomText(
                  !isUpdateAvailable ? 'uptoDate'.translate(context) : title,
                  fontWeight: .w700,
                  color: context.color.textColorDark,
                ),
                if (isUpdateAvailable)
                  CustomText(
                    'v$newVersion',
                    fontWeight: .w300,
                    fontStyle: .italic,
                    color: context.color.textColorDark,
                    fontSize: context.font.xs,
                  ),
              ],
            ),
            if (isUpdateAvailable) ...[
              const Spacer(),
              Container(
                width: 32.rw(context),
                height: 32.rh(context),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.color.borderColor,
                    width: 1.5,
                  ),
                  color: context.color.secondaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: FittedBox(
                  fit: .none,
                  child: CustomImage(
                    imageUrl: AppIcons.arrowRight,
                    matchTextDirection: true,
                    color: context.color.textColorDark,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget customTile(
    BuildContext context, {
    required String title,
    required String svgImagePath,
    required VoidCallback onTap,
    bool? isSwitchBox,
  }) {
    return GestureDetector(
      onTap: () async {
        final hasInternet = await HelperUtils.checkInternet();
        if (!hasInternet) {
          return HelperUtils.showSnackBarMessage(
            context,
            'noInternet',
            type: .error,
          );
        }
        onTap.call();
      },
      child: AbsorbPointer(
        absorbing: !(isSwitchBox ?? false),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.color.textColorDark.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: FittedBox(
                fit: .none,
                child: CustomImage(
                  imageUrl: svgImagePath,
                  height: 24.rh(context),
                  width: 24.rw(context),
                  color: context.color.textColorDark,
                ),
              ),
            ),
            SizedBox(
              width: 8.rw(context),
            ),
            Expanded(
              child: CustomText(
                title,
                fontSize: context.font.md,
                fontWeight: .w700,
                color: context.color.textColorDark,
              ),
            ),
            if (isSwitchBox ?? false) ...[
              BlocBuilder<AppThemeCubit, ThemeMode>(
                builder: (context, themeMode) {
                  final isDark = context.read<AppThemeCubit>().isDarkMode;
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: Switch(
                      thumbColor: const WidgetStatePropertyAll(Colors.white),
                      trackOutlineColor: const WidgetStatePropertyAll(
                        Colors.transparent,
                      ),
                      thumbIcon: const WidgetStatePropertyAll(
                        Icon(Icons.circle, color: Colors.white),
                      ),
                      inactiveThumbColor: Colors.white,
                      inactiveTrackColor: Colors.grey,
                      activeTrackColor: context.color.tertiaryColor,
                      value: isDark,
                      onChanged: (val) async {
                        // Toggle between light and dark, keeping system theme as a separate option
                        final newTheme = isDark
                            ? ThemeMode.light
                            : ThemeMode.dark;
                        await context.read<AppThemeCubit>().changeTheme(
                          newTheme,
                        );
                      },
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget appointmentDropdownTile() {
    // Not const to ensure it rebuilds when user details change
    return const AppointmentDropdownTile();
  }

  Future<void> deleteConfirmWidget(
    String title,
    String desc,
    dynamic callDel,
  ) async {
    await UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        title: title,
        content: CustomText(
          desc,
          textAlign: .center,
        ),
        acceptButtonName: 'deleteBtnLbl'.translate(context),
        acceptTextColor: context.color.buttonColor,
        cancelTextColor: context.color.textColorDark,
        svgImagePath: AppIcons.deleteIllustration,
        isAcceptContainesPush: true,
        onAccept: () async {
          final L = HiveUtils.getUserLoginType();
          Navigator.of(context).pop();
          if (callDel as bool? ?? false) {
            Future.delayed(
              const Duration(microseconds: 100),
              () async {
                unawaited(Widgets.showLoader(context));
                try {
                  reportedProperties.clear();
                  // Appointment cubits
                  clearAppointmentCubits();

                  // throw FirebaseAuthException(code: "requires-recent-login");
                  if (L == LoginType.phone &&
                      AppSettings.otpServiceProvider == 'firebase') {
                    await FirebaseAuth.instance.currentUser?.delete();
                  }
                  if (L == LoginType.apple || L == LoginType.google) {
                    await FirebaseAuth.instance.currentUser?.delete();
                  }

                  await context.read<DeleteAccountCubit>().deleteAccount(
                    context,
                  );
                  if (L == LoginType.email) {
                    Constant.interestedPropertyIds.clear();
                    context.read<LoadChatMessagesCubit>().clear();
                    context.read<GetChatListCubit>().clear();
                    context.read<FetchMyPropertiesCubit>().clear();

                    context.read<LikedPropertiesCubit>().clear();
                  }
                  Widgets.hideLoder(context);
                  context.read<UserDetailsCubit>().clear();
                  await Navigator.pushReplacementNamed(context, Routes.login);
                } on Exception catch (e) {
                  Widgets.hideLoder(context);
                  if (e is FirebaseAuthException) {
                    if (e.code == 'requires-recent-login') {
                      await UiUtils.showBlurredDialoge(
                        context,
                        dialog: BlurredDialogBox(
                          title: 'Recent login required'.translate(context),
                          acceptTextColor: context.color.buttonColor,
                          showCancleButton: false,
                          content: CustomText(
                            'logoutAndLoginAgain'.translate(context),
                            textAlign: .center,
                          ),
                        ),
                      );
                    }
                  } else {
                    await UiUtils.showBlurredDialoge(
                      context,
                      dialog: BlurredDialogBox(
                        title: 'somethingWentWrng'.translate(context),
                        acceptTextColor: context.color.buttonColor,
                        showCancleButton: false,
                        content: CustomText(e.toString()),
                      ),
                    );
                  }
                }
              },
            );
          } else {
            await HiveUtils.logoutUser(
              context,
              onLogout: () {},
            );
          }
        },
      ),
    );
  }

  Widget profileImgWidget() {
    return GestureDetector(
      onTap: () async {
        await UiUtils.showFullScreenImage(
          context,
          provider: NetworkImage(
            context.read<UserDetailsCubit>().state.user?.profile ?? '',
          ),
        );
      },
      child:
          (context.watch<UserDetailsCubit>().state.user?.profile ?? '')
              .trim()
              .isEmpty
          ? buildDefaultPersonSVG(context)
          : CustomImage(
              imageUrl:
                  context.watch<UserDetailsCubit>().state.user?.profile ?? '',
              width: 80.rw(context),
              height: 80.rh(context),
            ),
    );
  }

  Widget buildDefaultPersonSVG(BuildContext context) {
    return Container(
      width: 80.rw(context),
      height: 80.rh(context),
      color: context.color.tertiaryColor.withValues(alpha: 0.1),
      child: FittedBox(
        fit: .none,
        child: CustomImage(
          imageUrl: AppIcons.defaultPersonLogo,
          color: context.color.tertiaryColor,
          width: 32.rw(context),
          height: 32.rh(context),
        ),
      ),
    );
  }

  Future<void> shareApp() async {
    try {
      if (Platform.isAndroid) {
        await SharePlus.instance.share(
          ShareParams(
            text:
                '${Constant.appName}\n${Constant.playstoreURLAndroid}\n${'shareApp'.translate(context)}',
            subject: Constant.appName,
          ),
        );
      } else if (Platform.isIOS) {
        await SharePlus.instance.share(
          ShareParams(
            text:
                '${Constant.appName}\n${Constant.appstoreURLios}\n${'shareApp'.translate(context)}',
            subject: Constant.appName,
          ),
        );
      }
    } on Exception catch (e) {
      HelperUtils.showSnackBarMessage(context, e.toString());
    }
  }

  Future<void> rateUs() async {
    final inAppReview = InAppReview.instance;
    if (await inAppReview.isAvailable()) {
      await inAppReview.openStoreListing();
    }
  }

  Future<void> logOutConfirmWidget() async {
    final hasInternet = await HelperUtils.checkInternet();
    if (!hasInternet) {
      return HelperUtils.showSnackBarMessage(
        context,
        'noInternet',
        type: .error,
      );
    }
    await UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        title: 'confirmLogoutTitle'.translate(context),
        onAccept: () async {
          try {
            reportedProperties.clear();
            final L = HiveUtils.getUserLoginType();
            if (L == LoginType.email) {
              Future.delayed(
                Duration.zero,
                () async {
                  Constant.interestedPropertyIds.clear();
                  context.read<UserDetailsCubit>().clear();
                  context.read<LikedPropertiesCubit>().clear();
                  context.read<LoadChatMessagesCubit>().clear();
                  context.read<GetChatListCubit>().clear();
                  context.read<FetchMyPropertiesCubit>().clear();
                  // Appointment cubits
                  clearAppointmentCubits();

                  await HiveUtils.logoutUser(context, onLogout: () {});
                },
              );
            }
            if (L == LoginType.phone &&
                AppSettings.otpServiceProvider == 'twilio') {
              Future.delayed(
                Duration.zero,
                () async {
                  Constant.interestedPropertyIds.clear();
                  context.read<UserDetailsCubit>().clear();
                  context.read<LikedPropertiesCubit>().clear();
                  context.read<LoadChatMessagesCubit>().clear();
                  context.read<GetChatListCubit>().clear();
                  context.read<FetchMyPropertiesCubit>().clear();
                  // Appointment cubits
                  clearAppointmentCubits();

                  await HiveUtils.logoutUser(context, onLogout: () {});
                },
              );
            }
            if (L == LoginType.phone &&
                AppSettings.otpServiceProvider == 'firebase') {
              Future.delayed(
                Duration.zero,
                () async {
                  Constant.interestedPropertyIds.clear();
                  context.read<UserDetailsCubit>().clear();
                  context.read<LikedPropertiesCubit>().clear();
                  context.read<LoadChatMessagesCubit>().clear();
                  context.read<GetChatListCubit>().clear();
                  context.read<FetchMyPropertiesCubit>().clear();
                  // Appointment cubits
                  clearAppointmentCubits();

                  await HiveUtils.logoutUser(context, onLogout: () {});
                },
              );
            }
            if (L == LoginType.google || L == LoginType.apple) {
              Future.delayed(
                Duration.zero,
                () async {
                  Constant.interestedPropertyIds.clear();
                  context.read<UserDetailsCubit>().clear();
                  context.read<LikedPropertiesCubit>().clear();
                  context.read<LoadChatMessagesCubit>().clear();
                  context.read<GetChatListCubit>().clear();
                  context.read<FetchMyPropertiesCubit>().clear();
                  // Appointment cubits
                  clearAppointmentCubits();

                  await HiveUtils.logoutUser(context, onLogout: () {});
                },
              );
              await GoogleSignIn.instance.signOut();
            }
          } on Exception catch (e) {
            log('Issue while logout is $e');
          }
        },
        cancelTextColor: context.color.textColorDark,
        svgImagePath: AppIcons.logoutIllustration,
        acceptTextColor: context.color.buttonColor,
        content: CustomText(
          'confirmLogOutMsg'.translate(context),
          textAlign: .center,
        ),
      ),
    );
  }

  void clearAppointmentCubits() {
    context.read<FetchBookingPreferencesCubit>().clear();
    context.read<FetchAgentUpcomingAppointmentsCubit>().clear();
    context.read<FetchAgentPreviousAppointmentsCubit>().clear();
    context.read<FetchUserUpcomingAppointmentsCubit>().clear();
    context.read<FetchUserPreviousAppointmentsCubit>().clear();
    context.read<FetchAgentTimeSchedulesCubit>().clear();
  }

  Widget _buildVerificationUI(BuildContext context, String status) {
    const verifyButtonPadding = EdgeInsetsDirectional.only(
      start: 4,
      end: 8,
      top: 2,
      bottom: 2,
    );

    // Cache context-dependent values
    final colorScheme = context.color;

    switch (status) {
      case 'initial':
        return _buildVerificationButton(
          onTap: () => _handleVerificationTap(context, 'initial'),
          padding: verifyButtonPadding,
          backgroundColor: colorScheme.tertiaryColor,
          child: _buildVerificationContent(
            icon: _buildAgentBadgeIcon(colorScheme.buttonColor),
            text: 'verifyNow'.translate(context),
            textColor: colorScheme.buttonColor,
          ),
        );

      case 'pending':
        return _buildVerificationContainer(
          padding: verifyButtonPadding,
          backgroundColor: Colors.orangeAccent.withValues(alpha: 0.1),
          child: _buildVerificationContent(
            icon: Icon(
              Icons.access_time_filled_rounded,
              color: Colors.orangeAccent,
              size: 16.rh(context),
            ),
            text: 'verificationPending'.translate(context),
            textColor: Colors.orangeAccent,
            spacing: 2,
            leadingSpacing: 4,
          ),
        );

      case 'success':
        return _buildVerificationContainer(
          padding: verifyButtonPadding,
          backgroundColor: colorScheme.tertiaryColor.withValues(alpha: 0.1),
          child: _buildVerificationContent(
            icon: _buildAgentBadgeIcon(colorScheme.tertiaryColor),
            text: 'verified'.translate(context),
            textColor: colorScheme.tertiaryColor,
            spacing: 2,
          ),
        );

      case 'failed':
        return _buildVerificationButton(
          onTap: () => _handleVerificationTap(context, 'failed'),
          padding: verifyButtonPadding,
          backgroundColor: colorScheme.error.withValues(alpha: 0.1),
          child: _buildVerificationContent(
            icon: Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Icon(
                Icons.cancel_rounded,
                color: colorScheme.error,
                size: 16.rh(context),
              ),
            ),
            text: 'formRejected'.translate(context),
            textColor: colorScheme.error,
            spacing: 2,
          ),
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // Helper method for tappable verification buttons
  Widget _buildVerificationButton({
    required VoidCallback onTap,
    required EdgeInsetsDirectional padding,
    required Color backgroundColor,
    required Widget child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: _buildVerificationContainer(
        padding: padding,
        backgroundColor: backgroundColor,
        child: child,
      ),
    );
  }

  // Helper method for verification container styling
  Widget _buildVerificationContainer({
    required EdgeInsetsDirectional padding,
    required Color backgroundColor,
    required Widget child,
  }) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: child,
    );
  }

  // Helper method for verification content layout
  Widget _buildVerificationContent({
    required Widget icon,
    required String text,
    required Color textColor,
    double spacing = 0,
    double leadingSpacing = 0,
  }) {
    return Row(
      mainAxisSize: .min,
      children: [
        if (leadingSpacing > 0) SizedBox(width: leadingSpacing),
        icon,
        if (spacing > 0) SizedBox(width: spacing),
        CustomText(
          text,
          fontWeight: .bold,
          fontSize: context.font.xs,
          color: textColor,
        ),
      ],
    );
  }

  // Helper method for agent badge icon
  Widget _buildAgentBadgeIcon(Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: FittedBox(
        fit: .none,
        child: CustomImage(
          imageUrl: AppIcons.agentBadge,
          height: 16.rh(context),
          width: 16.rw(context),
          color: color,
        ),
      ),
    );
  }

  // Extracted and optimized verification tap handler
  Future<void> _handleVerificationTap(
    BuildContext context,
    String expectedStatus,
  ) async {
    try {
      final systemRepository = SystemRepository();
      final fetchSystemSettings = await systemRepository.fetchSystemSettings(
        isAnonymouse: false,
      );

      final currentStatus = fetchSystemSettings['data']['verification_status'];

      if (currentStatus == expectedStatus) {
        await HelperUtils.goToNextPage(
          Routes.agentVerificationForm,
          context,
          false,
        );
      } else {
        HelperUtils.showSnackBarMessage(
          context,
          'formAlreadySubmitted',
        );
      }
    } on Exception catch (_) {
      // Handle potential errors gracefully
      HelperUtils.showSnackBarMessage(
        context,
        'errorOccurred',
      );
    }
  }
}
