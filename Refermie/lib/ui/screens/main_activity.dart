import 'dart:math' hide log;

import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/chat/chat_list_screen.dart';
import 'package:ebroker/ui/screens/home/home_screen.dart';
import 'package:ebroker/ui/screens/proprties/my_properties_screen.dart';
import 'package:ebroker/ui/screens/userprofile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

List<PropertyModel> myPropertylist = [];
Map<String, dynamic> searchbody = {};
String selectedcategoryId = '0';
String selectedcategoryName = '';
dynamic selectedCategory;
bool isFirstTime = true;

//this will set when i will visit in any category
dynamic currentVisitingCategoryId = '';
dynamic currentVisitingCategory = '';

List<int> navigationStack = [0];

ScrollController homeScreenController = ScrollController();
ScrollController chatScreenController = ScrollController();
ScrollController sellScreenController = ScrollController();
ScrollController rentScreenController = ScrollController();
ScrollController soldScreenController = ScrollController();
ScrollController rentedScreenController = ScrollController();
ScrollController profileScreenController = ScrollController();
ScrollController agentsListScreenController = ScrollController();
ScrollController faqsListScreenController = ScrollController();
ScrollController cityScreenController = ScrollController();

List<ScrollController> controllerList = [
  faqsListScreenController,
  agentsListScreenController,
  homeScreenController,
  chatScreenController,
  if (propertyScreenCurrentPage == 0) ...[
    sellScreenController,
  ] else if (propertyScreenCurrentPage == 1) ...[
    rentScreenController,
  ] else if (propertyScreenCurrentPage == 2) ...[
    soldScreenController,
  ] else if (propertyScreenCurrentPage == 3) ...[
    rentedScreenController,
  ],
  profileScreenController,
];

//
class MainActivity extends StatefulWidget {
  const MainActivity({required this.from, super.key});

  final String from;

  @override
  State<MainActivity> createState() => MainActivityState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map? ?? {};
    return CupertinoPageRoute(
      builder: (_) =>
          MainActivity(from: arguments['from'] as String? ?? 'main'),
    );
  }
}

class MainActivityState extends State<MainActivity>
    with TickerProviderStateMixin {
  int currtab = 0;
  static final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final List<dynamic> _pageHistory = [];
  late PageController pageController;
  DateTime? currentBackPressTime;

  // Artboard? artboard;
  bool isReverse = true;

  // StateMachineController? _controller;
  bool isAddMenuOpen = false;
  int rotateAnimationDurationMs = 2000;
  bool showSellRentButton = false;

  ///Animation for sell and rent button
  ///
  late AnimationController plusAnimationController = AnimationController(
    duration: const Duration(milliseconds: 400),
    vsync: this,
  );
  late final AnimationController _forProjectAnimationController =
      AnimationController(
        vsync: this,
        duration: const Duration(
          milliseconds: 400,
        ),
        reverseDuration: const Duration(
          milliseconds: 400,
        ),
      );
  late final AnimationController _forPropertyController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
    reverseDuration: const Duration(milliseconds: 300),
  );

  ///END: Animation for sell and rent button
  late final Animation<double> _projectTween =
      Tween<double>(begin: -60.rh(context), end: 80.rh(context)).animate(
        CurvedAnimation(
          parent: _forProjectAnimationController,
          curve: Curves.easeIn,
        ),
      );
  late final Animation<double> _propertyTween =
      Tween<double>(begin: -60.rh(context), end: 30.rh(context)).animate(
        CurvedAnimation(parent: _forPropertyController, curve: Curves.easeIn),
      );

  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    plusAnimationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    if (appSettings.isUserActive == false) {
      Future.delayed(
        Duration.zero,
        () async {
          await HiveUtils.logoutUser(context, onLogout: () {});
        },
      );
    }

    GuestChecker.setContext(context);
    GuestChecker.set('main_activity', isGuest: HiveUtils.isGuest());
    final settings = context.read<FetchSystemSettingsCubit>();
    if (!const bool.fromEnvironment(
      'force-disable-demo-mode',
    )) {
      Constant.isDemoModeOn =
          settings.getSetting(SystemSetting.demoMode) as bool? ?? false;
    }
    final numberWithSuffix = settings.getSetting(
      SystemSetting.numberWithSuffix,
    );
    if (numberWithSuffix == '1') {
      Constant.isNumberWithSuffix = true;
    } else {
      Constant.isNumberWithSuffix = false;
    }

    ///This will check for update
    unawaited(versionCheck(settings));

    //This will init page controller
    initPageController();
  }

  void addHistory(int index) {
    final stack = navigationStack;

    if (stack.last != index) {
      if (index == 1 || index == 3) {
        if (!GuestChecker.value) {
          stack.add(index);
          navigationStack = stack;
        }
      } else {
        stack.add(index);
        navigationStack = stack;
      }
    }

    setState(() {});
  }

  void initPageController() {
    pageController = PageController()
      ..addListener(() {
        _pageHistory.insert(0, pageController.page);
      });
  }

  Future<void> versionCheck(dynamic settings) async {
    var remoteVersion = settings.getSetting(
      Platform.isIOS ? SystemSetting.iosVersion : SystemSetting.androidVersion,
    );
    final remote = remoteVersion;

    final forceUpdate = settings.getSetting(SystemSetting.forceUpdate);

    final packageInfo = await PackageInfo.fromPlatform();

    final current = packageInfo.version;

    final currentVersion = HelperUtils.comparableVersion(packageInfo.version);
    if (remoteVersion == null) {
      return;
    }
    remoteVersion = HelperUtils.comparableVersion(
      remoteVersion?.toString() ?? '',
    );

    if ((remoteVersion > currentVersion) as bool? ?? false) {
      Constant.isUpdateAvailable = true;
      Constant.newVersionNumber =
          settings
              .getSetting(
                Platform.isIOS
                    ? SystemSetting.iosVersion
                    : SystemSetting.androidVersion,
              )
              ?.toString() ??
          '';

      Future.delayed(
        Duration.zero,
        () async {
          if (forceUpdate == '1') {
            ///This is force update
            await UiUtils.showBlurredDialoge(
              context,
              dialog: BlurredDialogBox(
                onAccept: () async {
                  if (Platform.isAndroid) {
                    await launchUrl(
                      Uri.parse(
                        Constant.playstoreURLAndroid,
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    await launchUrl(
                      Uri.parse(
                        Constant.appstoreURLios,
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                backAllowedButton: false,
                svgImagePath: AppIcons.update,
                isAcceptContainesPush: true,
                svgImageColor: context.color.tertiaryColor,
                showCancleButton: false,
                title: 'updateAvailable'.translate(context),
                acceptTextColor: context.color.buttonColor,
                content: Column(
                  mainAxisSize: .min,
                  children: [
                    CustomText('$current>$remote'),
                    CustomText(
                      'newVersionAvailableForce'.translate(context),
                      textAlign: .center,
                    ),
                  ],
                ),
              ),
            );
          } else {
            await UiUtils.showBlurredDialoge(
              context,
              dialog: BlurredDialogBox(
                onAccept: () async {
                  if (Platform.isAndroid) {
                    await launchUrl(
                      Uri.parse(
                        Constant.playstoreURLAndroid,
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  } else {
                    await launchUrl(
                      Uri.parse(
                        Constant.appstoreURLios,
                      ),
                      mode: LaunchMode.externalApplication,
                    );
                  }
                },
                svgImagePath: AppIcons.update,
                svgImageColor: context.color.tertiaryColor,
                showCancleButton: true,
                title: 'updateAvailable'.translate(context),
                content: CustomText(
                  'newVersionAvailable'.translate(context),
                ),
              ),
            );
          }
        },
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  late List<Widget> pages = [
    HomeScreen(from: widget.from),
    const ChatListScreen(),
    const CustomText(''),
    const PropertiesScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;

        if (navigationStack.last == 0) {
          final now = DateTime.now();
          if (currentBackPressTime == null ||
              now.difference(currentBackPressTime!) >
                  const Duration(seconds: 2)) {
            currentBackPressTime = now;
            await Fluttertoast.showToast(
              msg: 'pressAgainToExit'.translate(context),
            );
            return Future.value(false);
          }
        } else {
          final length = navigationStack.length;
          //This will put our page on previous page.
          final secondLast = navigationStack[length - 2];
          navigationStack.removeLast();
          pageController.jumpToPage(secondLast);
          setState(() {});
          return Future.value(false);
        }

        Future.delayed(Duration.zero, () async {
          await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        });
      },
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        bottomNavigationBar: Constant.maintenanceMode == '1'
            ? null
            : bottomBar(),
        body: Stack(
          children: <Widget>[
            PageView(
              physics: const NeverScrollableScrollPhysics(),
              controller: pageController,
              onPageChanged: onItemSwipe,
              children: pages,
            ),
            if (Constant.maintenanceMode == '1')
              Container(
                color: Theme.of(context).colorScheme.primaryColor,
              ),
            SizedBox.expand(
              child: Stack(
                children: [
                  if (!isReverse)
                    GestureDetector(
                      onTap: () {
                        unawaited(plusAnimationController.reverse());
                        showSellRentButton = false;
                        isReverse = true;
                        unawaited(_forPropertyController.reverse());
                        unawaited(_forProjectAnimationController.reverse());
                        setState(() {});
                      },
                      child: Container(
                        height: double.infinity,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  _buildAnimatedAddButton(
                    controller: _forPropertyController,
                    tween: _propertyTween,
                    leftOffset: 90.rw(context),
                    width: 180.rw(context),
                    icon: AppIcons.propertiesIcon,
                    label: 'property'.translate(context),
                    packageType: PackageType.propertyList,
                    subscriptionPackageType:
                        SubscriptionPackageType.propertyList,
                    propertyAddType: PropertyAddType.property,
                  ),
                  _buildAnimatedAddButton(
                    controller: _forProjectAnimationController,
                    tween: _projectTween,
                    leftOffset: 64.rw(context),
                    width: 128.rw(context),
                    icon: AppIcons.upcomingProject,
                    label: 'project'.translate(context),
                    packageType: PackageType.projectList,
                    subscriptionPackageType:
                        SubscriptionPackageType.projectList,
                    propertyAddType: PropertyAddType.project,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> onItemTapped(int index) async {
    addHistory(index);

    if (index == currtab) {
      var xIndex = index;

      if (xIndex == 3) {
        xIndex = 2;
      } else if (xIndex == 4) {
        xIndex = 3;
      }
      if (controllerList[xIndex].hasClients) {
        unawaited(
          controllerList[xIndex].animateTo(
            0,
            duration: const Duration(milliseconds: 200),
            curve: Curves.bounceOut,
          ),
        );
      }
    }
    FocusManager.instance.primaryFocus?.unfocus();
    isReverse = true;
    unawaited(plusAnimationController.reverse());
    unawaited(_forProjectAnimationController.reverse());
    unawaited(_forPropertyController.reverse());

    if (index != 1) {
      context.read<SearchPropertyCubit>().clearSearch();

      // SearchScreenState.searchController.text = '';
    }
    searchbody = {};
    if (index == 1 || index == 3) {
      await GuestChecker.check(
        onNotGuest: () {
          currtab = index;
          pageController.jumpToPage(currtab);
          setState(
            () {},
          );
        },
      );
    } else {
      currtab = index;
      pageController.jumpToPage(currtab);
      setState(() {});
    }
  }

  double degreesToQuarterTurns(double degrees) {
    return degrees / 90;
  }

  void onItemSwipe(int index) {
    addHistory(index);

    FocusManager.instance.primaryFocus?.unfocus();
    isReverse = true;
    unawaited(plusAnimationController.reverse());
    unawaited(_forProjectAnimationController.reverse());
    unawaited(_forPropertyController.reverse());

    if (index != 1) {
      context.read<SearchPropertyCubit>().clearSearch();

      // SearchScreenState.searchController.text = '';
    }
    searchbody = {};
    setState(() {
      currtab = index;
    });
    pageController.jumpToPage(currtab);
  }

  Widget bottomBar() {
    return Container(
      height: 76.rh(context),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        boxShadow: [
          BoxShadow(
            color: context.color.textColorDark.withValues(alpha: 0.2),
            offset: const Offset(0, -1),
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: .spaceAround,
        children: <Widget>[
          buildBottomNavigationbarItem(
            0,
            AppIcons.home,
            AppIcons.homeActive,
            'homeTab'.translate(context),
          ),
          buildBottomNavigationbarItem(
            1,
            AppIcons.chat,
            AppIcons.chatActive,
            'chat'.translate(context),
          ),
          // FAB with optimized tap area - using SizedBox to ensure proper spacing
          Transform.translate(
            offset: Offset(0, -30.rh(context)),
            child: GestureDetector(
              behavior: .opaque,
              onTap: () {
                if (isReverse) {
                  unawaited(plusAnimationController.forward());
                  isReverse = false;
                  showSellRentButton = true;
                  unawaited(_forPropertyController.forward());
                  unawaited(_forProjectAnimationController.forward());
                } else {
                  unawaited(plusAnimationController.reverse());
                  showSellRentButton = false;
                  isReverse = true;
                  unawaited(_forPropertyController.reverse());
                  unawaited(_forProjectAnimationController.reverse());
                }
                setState(() {});
              },
              child: SizedBox(
                width: 56.rw(context),
                height: 56.rh(context),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: .none,
                  children: [
                    if (context.color.brightness == .light)
                      Container(
                        height: 48.rh(context),
                        width: 46.rw(context),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(99999),
                          boxShadow: [
                            BoxShadow(
                              color: context.color.textColorDark.withValues(
                                alpha: 0.5,
                              ),
                              offset: const Offset(0, -1.5),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    AnimatedScale(
                      scale: isReverse ? 1 : 1.15,
                      duration: const Duration(milliseconds: 200),
                      child: AnimatedRotation(
                        turns: isReverse ? 0 : 1 / 3,
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          alignment: Alignment.center,
                          child: CustomImage(
                            imageUrl: AppIcons.addButtonShape,
                            color: context.color.tertiaryColor,
                            height: 56.rh(context),
                            width: 56.rw(context),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      height: 56.rh(context),
                      width: 56.rw(context),
                      alignment: Alignment.center,
                      child: AnimatedBuilder(
                        animation: plusAnimationController,
                        builder: (context, child) {
                          return Transform.rotate(
                            angle:
                                plusAnimationController.value *
                                (135 * (pi / 180)), // Rotate 135 degrees
                            child: child,
                          );
                        },
                        child: CustomImage(
                          imageUrl: AppIcons.plusButtonIcon,
                          color: context.color.buttonColor,
                          height: 18.rh(context),
                          width: 18.rw(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          buildBottomNavigationbarItem(
            3,
            AppIcons.properties,
            AppIcons.propertiesActive,
            'properties'.translate(context),
          ),
          buildBottomNavigationbarItem(
            4,
            AppIcons.profileOutlined,
            AppIcons.profileActive,
            'profileTab'.translate(context),
          ),
        ],
      ),
    );
  }

  Widget buildBottomNavigationbarItem(
    int index,
    String svgImage,
    String selectedSvgImage,
    String title,
  ) {
    return Expanded(
      child: GestureDetector(
        behavior: .opaque,
        onTap: () => onItemTapped(index),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 8.rw(context),
            vertical: 4.rh(context),
          ),
          child: Column(
            mainAxisAlignment: .center,
            children: <Widget>[
              AnimatedScale(
                scale: currtab == index ? 1.3 : 1,
                duration: const Duration(milliseconds: 200),
                child: Container(
                  alignment: Alignment.center,
                  child: CustomImage(
                    imageUrl: currtab == index ? selectedSvgImage : svgImage,
                    height: 24.rh(context),
                    width: 24.rw(context),
                    color: currtab == index
                        ? context.color.tertiaryColor
                        : context.color.textColorDark.withValues(alpha: .5),
                  ),
                ),
              ),
              SizedBox(height: 4.rh(context)),
              CustomText(
                title,
                maxLines: 1,
                textAlign: .center,
                fontSize: context.font.xs,
                color: currtab == index
                    ? context.color.tertiaryColor
                    : context.color.textColorDark.withValues(alpha: .5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds an animated button for adding property or project
  Widget _buildAnimatedAddButton({
    required AnimationController controller,
    required Animation<double> tween,
    required double leftOffset,
    required double width,
    required String icon,
    required String label,
    required PackageType packageType,
    required SubscriptionPackageType subscriptionPackageType,
    required PropertyAddType propertyAddType,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, c) {
        return Positioned(
          bottom: tween.value,
          left: (context.screenWidth / 2) - leftOffset,
          child: GestureDetector(
            onTap: () => _handleAddButtonTap(
              packageType: packageType,
              subscriptionPackageType: subscriptionPackageType,
              propertyAddType: propertyAddType,
            ),
            child: Container(
              width: width,
              height: 44.rh(context),
              decoration: BoxDecoration(
                color: context.color.tertiaryColor,
                borderRadius: BorderRadius.circular(22.rw(context)),
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisAlignment: .center,
                children: [
                  CustomImage(
                    imageUrl: icon,
                    color: context.color.buttonColor,
                    width: 20.rw(context),
                    height: 20.rh(context),
                  ),
                  SizedBox(width: 7.rw(context)),
                  CustomText(
                    label,
                    fontSize: context.font.xs,
                    fontWeight: .w500,
                    color: context.color.buttonColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Handles the tap event for add property/project buttons
  Future<void> _handleAddButtonTap({
    required PackageType packageType,
    required SubscriptionPackageType subscriptionPackageType,
    required PropertyAddType propertyAddType,
  }) async {
    final hasInternet = await HelperUtils.checkInternet();
    if (!hasInternet) {
      return HelperUtils.showSnackBarMessage(
        context,
        'noInternet',
        type: .error,
      );
    }
    await GuestChecker.check(
      onNotGuest: () async {
        unawaited(Widgets.showLoader(context));
        final checkPackage = CheckPackage();

        final packageAvailable = await checkPackage.checkPackageAvailable(
          packageType: packageType,
        );

        if (packageAvailable) {
          try {
            final isProfileCompleted =
                HiveUtils.getUserDetails().email != '' &&
                HiveUtils.getUserDetails().email != null &&
                (HiveUtils.getUserDetails().email?.isNotEmpty ?? false) &&
                HiveUtils.getUserDetails().mobile != '' &&
                HiveUtils.getUserDetails().mobile != null &&
                (HiveUtils.getUserDetails().mobile?.isNotEmpty ?? false) &&
                HiveUtils.getUserDetails().name != '' &&
                HiveUtils.getUserDetails().name != null &&
                (HiveUtils.getUserDetails().name?.isNotEmpty ?? false) &&
                HiveUtils.getUserDetails().address != '' &&
                (HiveUtils.getUserDetails().address?.isNotEmpty ?? false) &&
                HiveUtils.getUserDetails().address != null &&
                HiveUtils.getUserDetails().profile != '' &&
                (HiveUtils.getUserDetails().profile?.isNotEmpty ?? false) &&
                HiveUtils.getUserDetails().profile != null;

            if (!isProfileCompleted) {
              Widgets.hideLoder(context);
              await _showCompleteProfileDialog();
            } else if (AppSettings.isVerificationRequired &&
                context.read<FetchSystemSettingsCubit>().getSetting(
                      SystemSetting.verificationStatus,
                    ) !=
                    'success') {
              Widgets.hideLoder(context);
              await _showVerificationRequiredDialog();
            } else {
              Widgets.hideLoder(context);
              await _navigateToAddScreen(propertyAddType);
            }
          } on Exception catch (e) {
            Widgets.hideLoder(context);
            HelperUtils.showSnackBarMessage(
              context,
              e.toString(),
              type: .error,
            );
          }
        } else {
          Widgets.hideLoder(context);
          await UiUtils.showBlurredDialoge(
            context,
            dialog: BlurredSubscriptionDialogBox(
              packageType: subscriptionPackageType,
              isAcceptContainesPush: true,
            ),
          );
        }
      },
    );
  }

  /// Shows dialog to complete profile
  Future<void> _showCompleteProfileDialog() async {
    await UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        title: 'completeProfile'.translate(context),
        isAcceptContainesPush: true,
        onAccept: () async {
          await Navigator.popAndPushNamed(
            context,
            Routes.editProfile,
            arguments: {
              'from': 'home',
              'navigateToHome': true,
            },
          );
        },
        content:
            HiveUtils.getUserDetails().profile == '' &&
                (HiveUtils.getUserDetails().name != '' &&
                    HiveUtils.getUserDetails().email != '' &&
                    HiveUtils.getUserDetails().address != '')
            ? CustomText('uploadProfilePicture'.translate(context))
            : CustomText('completeProfileFirst'.translate(context)),
      ),
    );
  }

  /// Shows dialog for agent verification requirement
  Future<void> _showVerificationRequiredDialog() async {
    await UiUtils.showBlurredDialoge(
      context,
      dialog: BlurredDialogBox(
        content: CustomText(
          'completeAgentVerificationToContinue'.translate(context),
        ),
        title: 'agentVerificationRequired'.translate(context),
        isAcceptContainesPush: true,
        onAccept: () async {
          await HelperUtils.goToNextPage(
            Routes.agentVerificationForm,
            context,
            false,
          );
        },
      ),
    );
  }

  /// Navigates to add property/project screen
  Future<void> _navigateToAddScreen(PropertyAddType propertyAddType) async {
    if (context.read<FetchCategoryCubit>().state is! FetchCategorySuccess) {
      await context.read<FetchCategoryCubit>().fetchCategories(
        loadWithoutDelay: true,
        forceRefresh: false,
      );
    }
    Widgets.hideLoder(context);

    await Navigator.pushNamed(
      context,
      Routes.selectPropertyTypeScreen,
      arguments: {'type': propertyAddType},
    );

    Widgets.hideLoder(context);
  }
}
