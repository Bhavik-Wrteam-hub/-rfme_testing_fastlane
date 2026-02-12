import 'package:country_picker/country_picker.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/auth/country_picker.dart';
import 'package:ebroker/utils/login/apple_login/apple_login.dart';
import 'package:ebroker/utils/login/google_login/google_login.dart';
import 'package:ebroker/utils/login/login_status.dart';
import 'package:ebroker/utils/login/login_system.dart';
import 'package:flutter/material.dart';
import 'package:sms_autofill/sms_autofill.dart';

// Form validator to encapsulate form validation logic
class FormValidator {
  static bool validateEmailForm(
    GlobalKey<FormState> formKey,
    BuildContext context,
  ) {
    if (!formKey.currentState!.validate()) {
      HelperUtils.showSnackBarMessage(
        context,
        'enterValidEmailPassword',
        messageDuration: 1,
        type: .error,
        isFloating: true,
      );
      return false;
    }
    return true;
  }

  static bool validatePhoneForm(
    GlobalKey<FormState> formKey,
    BuildContext context,
    String phoneNumber,
    String password,
  ) {
    if (!formKey.currentState!.validate() ||
        phoneNumber.isEmpty ||
        password.isEmpty) {
      HelperUtils.showSnackBarMessage(
        context,
        'enterValidNumber',
        messageDuration: 1,
        type: .error,
        isFloating: true,
      );
      return false;
    }
    return true;
  }
}

enum LoginMode {
  phoneOnly,
  emailOnly,
  phoneAndEmail,
  socialOnly,
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.isDeleteAccount});

  final bool? isDeleteAccount;

  @override
  State<LoginScreen> createState() => LoginScreenState();

  static CupertinoPageRoute<dynamic> route(RouteSettings routeSettings) {
    final args = routeSettings.arguments as Map?;
    return CupertinoPageRoute(
      builder: (_) => MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SendOtpCubit()),
          BlocProvider(create: (context) => VerifyOtpCubit()),
        ],
        child: LoginScreen(
          isDeleteAccount: args?['isDeleteAccount'] as bool? ?? false,
        ),
      ),
    );
  }
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController mobileNumController = TextEditingController(
    text: Constant.isDemoModeOn ? Constant.demoMobileNumber : '',
  );

  final TextEditingController emailAddressController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  List<Widget> list = [];
  String otpVerificationId = '';
  final _formKey = GlobalKey<FormState>();
  bool isOtpSent = false; //to swap between login & OTP screen
  String? otp;
  String? countryCode;
  String? countryName;
  String? flagEmoji;
  late bool isTablet = MediaQuery.sizeOf(context).width > 600;
  bool showRegisterOptions = false;
  int backPressedTimes = 0;
  late Size size;

  TextEditingController otpController = TextEditingController();
  bool isLoginButtonDisabled = false;
  String otpIs = '';
  bool isPhoneLoginEnabled = false;
  bool isSocialLoginEnabled = false;
  bool isEmailLoginEnabled = false;
  bool isEmailSelected = false;
  bool isResendOtpButtonVisible = false;
  bool isForgotPasswordVisible = false;
  bool isPasswordVisible = false;
  bool showPasswordField =
      false; // Track if password field should be shown for phone login

  LoginMode get currentLoginMode {
    if (isSocialLoginEnabled && !isPhoneLoginEnabled && !isEmailLoginEnabled) {
      return LoginMode.socialOnly;
    } else if (!isSocialLoginEnabled &&
        isPhoneLoginEnabled &&
        !isEmailLoginEnabled) {
      return LoginMode.phoneOnly;
    } else if (!isSocialLoginEnabled &&
        !isPhoneLoginEnabled &&
        isEmailLoginEnabled) {
      return LoginMode.emailOnly;
    } else if ((isPhoneLoginEnabled || isEmailLoginEnabled) &&
        isSocialLoginEnabled) {
      return LoginMode.phoneAndEmail;
    }
    // Default fallback
    return LoginMode.phoneAndEmail;
  }

  MMultiAuthentication loginSystem = MMultiAuthentication({
    'google': GoogleLogin(),
    'apple': AppleLogin(),
  });

  // Text change listener

  @override
  void initState() {
    super.initState();

    loginSystem
      ..init()
      ..setContext(context)
      ..listen((MLoginState state) async {
        if (state is MProgress) {
          unawaited(Widgets.showLoader(context));
        }

        if (state is MSuccess) {
          Widgets.hideLoder(context);
          if (widget.isDeleteAccount ?? false) {
            await context.read<DeleteAccountCubit>().deleteUserAccount(
              context,
            );
          } else {
            await context.read<LoginCubit>().login(
              type: LoginType.values.firstWhere(
                (element) => element.name == state.type,
              ),
              name:
                  state.credentials.user?.displayName ??
                  state.credentials.user?.providerData.first.displayName,
              email: state.credentials.user?.providerData.first.email,
              phoneNumber:
                  state.credentials.user?.providerData.first.phoneNumber ?? '',
              uniqueId: state.credentials.user!.uid,
              countryCode: countryCode ?? '',
            );
          }
        }

        if (state is MFail) {
          Widgets.hideLoder(context);
          if (state.error.toString() != 'google-terminated') {
            HelperUtils.showSnackBarMessage(
              context,
              state.error.toString(),
              type: .error,
            );
            Widgets.hideLoder(context);
          }
        }
      });
    context.read<FetchSystemSettingsCubit>();
    isPhoneLoginEnabled =
        context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.numberWithOtpLogin)
            ?.toString() ==
        '1';
    isSocialLoginEnabled =
        context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.socialLogin)
            ?.toString() ==
        '1';
    isEmailLoginEnabled =
        context
            .read<FetchSystemSettingsCubit>()
            .getSetting(SystemSetting.emailPasswordLogin)
            ?.toString() ==
        '1';

    // When only social login is enabled, show login section directly
    if (isSocialLoginEnabled && !isPhoneLoginEnabled && !isEmailLoginEnabled) {
      showRegisterOptions = false;
    }
    mobileNumController.addListener(
      () {
        if (mobileNumController.text.isEmpty &&
            Constant.isDemoModeOn &&
            Constant.demoMobileNumber.isNotEmpty) {
          isLoginButtonDisabled = true;
          setState(() {});
        } else {
          isLoginButtonDisabled = false;
          setState(() {});
        }
      },
    );

    unawaited(
      HelperUtils.getSimCountry().then((value) {
        countryCode = value.phoneCode;
        flagEmoji = value.flagEmoji;
        setState(() {});
      }),
    );
  }

  @override
  void dispose() {
    isResendOtpButtonVisible = false;

    mobileNumController.dispose();
    if (isOtpSent) {
      unawaited(SmsAutoFill().unregisterListener());
    }
    super.dispose();
  }

  Future<void> _onGoogleTap() async {
    final hasInternet = await HelperUtils.checkInternet();
    if (!hasInternet) {
      return HelperUtils.showSnackBarMessage(
        context,
        'noInternet',
        type: .error,
      );
    }
    try {
      // No loader is shown here to prevent app crashes
      await loginSystem.setActive('google');
      await loginSystem.login();
    } on Exception catch (_) {
      HelperUtils.showSnackBarMessage(
        context,
        'googleLoginFailed',
        type: .error,
      );
    }
  }

  Future<void> _onTapAppleLogin() async {
    final hasInternet = await HelperUtils.checkInternet();
    if (!hasInternet) {
      return HelperUtils.showSnackBarMessage(
        context,
        'noInternet',
        type: .error,
      );
    }
    try {
      // No loader is shown here to prevent app crashes
      await loginSystem.setActive('apple');
      await loginSystem.login();
    } on Exception catch (_) {
      HelperUtils.showSnackBarMessage(
        context,
        'appleLoginFailed',
        type: .error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    if (context.watch<FetchSystemSettingsCubit>().state
        is FetchSystemSettingsSuccess) {
      Constant.isDemoModeOn =
          context.watch<FetchSystemSettingsCubit>().getSetting(
                SystemSetting.demoMode,
              )
              as bool? ??
          false;
    }

    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: _buildMainContent(),
    );
  }

  Widget _buildMainContent() {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: _handleBackPress,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          // floatingActionButton: _buildFloatingActionButton(),
          resizeToAvoidBottomInset: false,
          backgroundColor: context.color.secondaryColor,
          appBar: _buildAppBar(),
          body: buildLoginFields(context),
        ),
      ),
    );
  }

  // Widget _buildFloatingActionButton() {
  //   return FloatingActionButton(
  //     mini: true,
  //     onPressed: () async {
  //       await context.read<FetchSystemSettingsCubit>().fetchSettings(
  //         isAnonymous: false,
  //         forceRefresh: true,
  //       );
  //     },
  //     child: const Icon(Icons.settings),
  //   );
  // }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      isTransparent: true,
      showBackButton: false,
      actions: [_buildSkipButton()],
    );
  }

  Widget _buildSkipButton() {
    return MaterialButton(
      color: context.color.secondaryColor.withValues(alpha: 0.7),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: context.color.borderColor,
        ),
      ),
      elevation: 0,
      onPressed: () async {
        GuestChecker.set('login_screen', isGuest: true);
        await HiveUtils.setIsGuest();
        await HiveUtils.setUserIsNotNew();
        await HiveUtils.setUserIsNotAuthenticated();
        await Navigator.pushReplacementNamed(
          context,
          Routes.main,
          arguments: {
            'from': 'login',
            'isSkipped': true,
          },
        );
      },
      child: CustomText('skip'.translate(context)),
    );
  }

  Future<bool> _handleBackPress(bool didPop, _) async {
    if (didPop) return false;
    if (widget.isDeleteAccount ?? false) {
      Navigator.pop(context);
    } else if (isOtpSent) {
      setState(() {
        isOtpSent = false;
      });
    } else {
      Future.delayed(Duration.zero, () async {
        await SystemChannels.platform.invokeMethod('SystemNavigator.pop');
      });
    }
    return Future.value(false);
  }

  Widget buildLoginFields(BuildContext context) {
    return BlocConsumer<DeleteAccountCubit, DeleteAccountState>(
      listener: _handleDeleteAccountState,
      builder: (context, state) {
        return BlocListener<LoginCubit, LoginState>(
          listener: _handleLoginState,
          child: BlocListener<DeleteAccountCubit, DeleteAccountState>(
            listener: _handleDeleteAccountProgress,
            child: BlocListener<SendOtpCubit, SendOtpState>(
              listener: _handleSendOtpState,
              child: Form(
                key: _formKey,
                onChanged: () {
                  setState(() {});
                },
                child: buildLoginScreen(context),
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleDeleteAccountState(
    BuildContext context,
    DeleteAccountState state,
  ) {
    if (state is AccountDeleted) {
      context.read<UserDetailsCubit>().clear();
      Future.delayed(const Duration(milliseconds: 500), () async {
        await Navigator.pushReplacementNamed(context, Routes.login);
      });
    }
  }

  Future<void> _handleLoginState(BuildContext context, LoginState state) async {
    if (state is LoginInProgress) {
      unawaited(Widgets.showLoader(context));
    } else {
      if (widget.isDeleteAccount ?? false) {
      } else {
        Widgets.hideLoder(context);
      }
    }
    if (state is LoginFailure) {
      HelperUtils.showSnackBarMessage(
        context,
        state.errorMessage,
        type: .error,
      );
    }
    if (state is LoginSuccess) {
      await _handleLoginSuccess(context, state);
    }
  }

  Future<void> _handleLoginSuccess(
    BuildContext context,
    LoginSuccess state,
  ) async {
    if (!mounted) {
      return;
    }
    try {
      GuestChecker.set('login_screen', isGuest: false);
      await HiveUtils.setIsNotGuest();
      await LoadAppSettings().load(initBox: true);
      if (!mounted) {
        return;
      }
      context.read<UserDetailsCubit>().fill(HiveUtils.getUserDetails());

      await context.read<FetchSystemSettingsCubit>().fetchSettings(
        isAnonymous: false,
        forceRefresh: true,
      );
      if (!mounted) {
        return;
      }
      final settings = context.read<FetchSystemSettingsCubit>();

      if (!const bool.fromEnvironment(
        'force-disable-demo-mode',
      )) {
        Constant.isDemoModeOn =
            settings.getSetting(SystemSetting.demoMode) as bool? ?? false;
      }
      if (state.isProfileCompleted) {
        if (!mounted) {
          return;
        }
        await _handleCompletedProfile(context);
      }
    } on Exception catch (_) {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(
        context,
        'somethingWentWrong',
        type: .error,
      );
    }
  }

  Future<void> _handleCompletedProfile(BuildContext context) async {
    await HiveUtils.setUserIsAuthenticated();
    await HiveUtils.setUserIsNotNew();
    if (!mounted) {
      return;
    }
    Widgets.hideLoder(context);
    if (!mounted) {
      return;
    }
    await Navigator.pushReplacementNamed(
      context,
      Routes.main,
      arguments: {'from': 'login'},
    );
  }

  void _handleDeleteAccountProgress(
    BuildContext context,
    DeleteAccountState state,
  ) {
    if (state is DeleteAccountProgress) {
      Widgets.hideLoder(context);
      unawaited(Widgets.showLoader(context));
    }
    if (state is AccountDeleted) {
      Widgets.hideLoder(context);
    }
  }

  Future<void> _handleSendOtpState(
    BuildContext context,
    SendOtpState state,
  ) async {
    {
      if (widget.isDeleteAccount ?? false) {
        // Skip hiding loader for delete account flow
      } else {
        Widgets.hideLoder(context);
      }
    }
    if (state is SendOtpInProgress) {
      unawaited(Widgets.showLoader(context));
    }

    if (state is SendOtpSuccess) {
      Widgets.hideLoder(context);
      await _handleSendOtpSuccess(context, state);
    }
    if (state is SendOtpFailure) {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(
        context,
        state.errorMessage,
        type: .error,
      );
    }
  }

  Future<void> _handleSendOtpSuccess(
    BuildContext context,
    SendOtpSuccess state,
  ) async {
    isOtpSent = true;

    // Check if this is forgot password flow for phone (needs OTP verification)
    final isForgotPasswordPhoneFlow = otpIs == 'forgotPassword';

    if (isForgotPasswordVisible && !isForgotPasswordPhoneFlow) {
      // Email forgot password - just show success message
      HelperUtils.showSnackBarMessage(
        context,
        state.message ?? 'forgotPasswordSuccess',
        type: .success,
      );
    } else {
      HelperUtils.showSnackBarMessage(
        context,
        'optsentsuccessflly',
        type: .success,
      );
    }
    otpVerificationId = state.verificationId ?? '';
    setState(() {});

    // Navigate to OTP screen for: regular login, registration, password update, or phone forgot password
    if (!isForgotPasswordVisible || isForgotPasswordPhoneFlow) {
      // Clean phone number before passing to OTP screen
      final cleanPhoneNumber = mobileNumController.text.trim().replaceAll(
        ' ',
        '',
      );

      // Prepare arguments
      final arguments = <String, dynamic>{
        'isDeleteAccount': widget.isDeleteAccount ?? false,
        'phoneNumber': cleanPhoneNumber,
        'email': emailAddressController.text,
        'otpVerificationId': otpVerificationId,
        'countryCode': countryCode ?? '',
        'otpIs': otpIs,
        'isEmailSelected': isEmailSelected,
      };

      // Navigate to OTP screen
      await Navigator.pushNamed(
        context,
        Routes.otpScreen,
        arguments: arguments,
      );
    }
  }

  String demoOTP() {
    if (Constant.isDemoModeOn &&
        Constant.demoMobileNumber == mobileNumController.text) {
      return Constant.demoModeOTP; // If true, return the demo mode OTP.
    } else {
      return ''; // If false, return an empty string.
    }
  }

  Widget buildLoginScreen(BuildContext context) {
    return BlocConsumer<FetchSystemSettingsCubit, FetchSystemSettingsState>(
      listener: (context, state) {
        if (state is FetchSystemSettingsInProgress) {
          unawaited(Widgets.showLoader(context));
        }
        if (state is FetchSystemSettingsSuccess) {
          Widgets.hideLoder(context);
          // Update the flags when settings are successfully loaded
          _updateLoginFlags(context);
          setState(() {}); // Trigger rebuild to reflect updated flags
        }
      },
      builder: (context, state) {
        if (state is FetchSystemSettingsSuccess) {
          return Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: _buildLoginImageContainer(),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: _buildLoginContent(),
              ),
            ],
          );
        } else if (state is FetchSystemSettingsFailure) {
          return Center(
            child: SomethingWentWrong(
              errorMessage: state.errorMessage,
            ),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  void _updateLoginFlags(BuildContext context) {
    final settingsCubit = context.read<FetchSystemSettingsCubit>();
    isPhoneLoginEnabled =
        settingsCubit
            .getSetting(SystemSetting.numberWithOtpLogin)
            ?.toString() ==
        '1';
    isSocialLoginEnabled =
        settingsCubit.getSetting(SystemSetting.socialLogin)?.toString() == '1';
    isEmailLoginEnabled =
        settingsCubit
            .getSetting(SystemSetting.emailPasswordLogin)
            ?.toString() ==
        '1';

    // When only social login is enabled, show login section directly
    if (isSocialLoginEnabled && !isPhoneLoginEnabled && !isEmailLoginEnabled) {
      showRegisterOptions = false;
    }
  }

  Widget _buildLoginImageContainer() {
    return Stack(
      children: [
        Positioned(
          top: 0,
          child: CustomImage(
            imageUrl: AppSettings.loginBackground,
            height: isTablet ? context.screenHeight : 485,
            width: MediaQuery.of(context).size.width,
            fit: .fill,
            color: context.color.tertiaryColor.withValues(alpha: 0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginContent() {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final onlyEmailLoginEnabled =
        !isSocialLoginEnabled && isEmailLoginEnabled && !isPhoneLoginEnabled;
    final allLoginEnabled =
        isSocialLoginEnabled && isPhoneLoginEnabled && isEmailLoginEnabled;

    final ratioOfKeyboardHeight = onlyEmailLoginEnabled
        ? 0.55
        : allLoginEnabled
        ? 0.25
        : 0.45;
    final liftAmount = keyboardHeight * ratioOfKeyboardHeight;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      padding: EdgeInsets.only(bottom: liftAmount),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        constraints: BoxConstraints(
          minHeight: 400.rh(context),
        ),
        curve: Curves.easeOutBack,
        width: isTablet ? context.screenWidth * 0.7 : context.screenWidth,
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.rw(context)),
            topRight: Radius.circular(16.rw(context)),
          ),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: 18.rw(context),
        ),
        child: showRegisterOptions
            ? Column(
                mainAxisSize: .min,
                children: [
                  SizedBox(height: 32.rh(context)),
                  CustomText(
                    'registerOptions'.translate(context),
                    fontWeight: .w700,
                    fontSize: context.font.xxl,
                    color: context.color.textColorDark,
                  ),
                  SizedBox(height: 20.rh(context)),
                  UiUtils.getDivider(context),
                  SizedBox(height: 20.rh(context)),
                  CustomText(
                    'selectRegistrationMethod'.translate(context),
                    fontWeight: .w500,
                    fontSize: context.font.md,
                    color: context.color.textColorDark,
                    textAlign: .center,
                  ),
                  SizedBox(height: 4.rh(context)),
                  CustomText(
                    'pickPreferredSignUpOption'.translate(context),
                    fontWeight: .w500,
                    fontSize: context.font.sm,
                    color: context.color.textLightColor,
                    textAlign: .center,
                  ),
                  SizedBox(height: 20.rh(context)),

                  if (isPhoneLoginEnabled)
                    _buildSocialButton(
                      text: 'registerWithPhoneNumber'.translate(context),
                      icon: AppIcons.call,
                      iconColor: context.color.textColorDark,
                      onTap: () async {
                        final hasInternet = await HelperUtils.checkInternet();
                        if (!hasInternet) {
                          return HelperUtils.showSnackBarMessage(
                            context,
                            'noInternet',
                            type: .error,
                          );
                        }
                        await Navigator.pushNamed(
                          context,
                          Routes.phoneRegistrationForm,
                          arguments: {
                            'phoneNumber': mobileNumController.text,
                            'countryCode': countryCode ?? '',
                          },
                        );
                      },
                    ),

                  if (isEmailLoginEnabled)
                    _buildSocialButton(
                      text: 'registerWithEmailAddress'.translate(context),
                      icon: AppIcons.email,
                      iconColor: context.color.textColorDark,
                      onTap: () async {
                        final hasInternet = await HelperUtils.checkInternet();
                        if (!hasInternet) {
                          return HelperUtils.showSnackBarMessage(
                            context,
                            'noInternet',
                            type: .error,
                          );
                        }
                        await Navigator.pushNamed(
                          context,
                          Routes.emailRegistrationForm,
                          arguments: {
                            'email': emailAddressController.text,
                          },
                        );
                      },
                    ),

                  if (isSocialLoginEnabled) ...[
                    if (Platform.isIOS)
                      _buildSocialButton(
                        text: 'continueWithApple'.translate(context),
                        icon: AppIcons.apple,
                        onTap: () async {
                          await _onTapAppleLogin();
                        },
                      ),
                    _buildSocialButton(
                      text: 'continueWithGoogle'.translate(context),
                      icon: AppIcons.google,
                      onTap: () async {
                        await _onGoogleTap();
                      },
                    ),
                  ],
                  SizedBox(height: 8.rh(context)),
                  Wrap(
                    alignment: .center,
                    crossAxisAlignment: .center,
                    children: [
                      CustomText(
                        'alreadyHaveAnAccount'.translate(context),
                        fontSize: context.font.sm,
                      ),
                      SizedBox(width: 4.rw(context)),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showRegisterOptions = false;
                          });
                        },
                        child: CustomText(
                          'signIn'.translate(context),
                          fontWeight: .w600,
                          fontSize: context.font.sm,
                          color: context.color.tertiaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.rh(context)),
                  buildTermsAndPrivacyWidget(
                    context: context,
                    isTablet: isTablet,
                  ),
                ],
              )
            : Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  const SizedBox(height: 32),
                  _buildTitle(),
                  _buildLoginFormSection(),
                  SizedBox(height: 16.rh(context)),
                  buildTermsAndPrivacyWidget(
                    context: context,
                    isTablet: isTablet,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoginFormSection() {
    switch (currentLoginMode) {
      case LoginMode.socialOnly:
        return _buildSocialOnlySection();

      case LoginMode.emailOnly:
        return buildEmailOnly();

      case LoginMode.phoneOnly:
        return _buildPhoneOnlySection();

      case LoginMode.phoneAndEmail:
        // If email is NOT enabled, use phone-only flow even if social is enabled
        if (!isEmailLoginEnabled && isPhoneLoginEnabled) {
          return _buildPhoneOnlySection();
        }
        return isSocialLoginEnabled
            ? _buildPhoneEmailWithSocialSection()
            : buildMobileEmailField();
    }
  }

  Widget _buildTitle() => Center(
    child: Column(
      children: [
        CustomText(
          'loginNow'.translate(context),
          fontWeight: .w700,
          fontSize: context.font.xxl,
          color: context.color.textColorDark,
        ),
        SizedBox(height: 8.rh(context)),
        CustomText(
          'loginToYourAccount'.translate(context),
          fontWeight: .w500,
          fontSize: context.font.sm,
          color: context.color.textColorDark,
        ),
        SizedBox(height: 20.rh(context)),
      ],
    ),
  );

  Widget _buildSocialOnlySection() {
    return Column(
      children: [
        if (Platform.isIOS) ...[
          _buildSocialButton(
            text: 'signInWithApple'.translate(context),
            icon: AppIcons.apple,
            onTap: _onTapAppleLogin,
          ),
        ],
        _buildSocialButton(
          text: 'signInWithGoogle'.translate(context),
          icon: AppIcons.google,
          onTap: _onGoogleTap,
        ),
      ],
    );
  }

  Widget _buildPhoneOnlySection() {
    return Column(
      children: [
        // Phone number field
        _buildMobileField(),

        const SizedBox(height: 12),

        // Password field - only show after phone verification and not in forgot password mode
        if (showPasswordField && !isForgotPasswordVisible) ...[
          _buildPasswordField(),
        ],

        // Forgot password toggle - show when password field is visible or in forgot password mode
        if (showPasswordField || isForgotPasswordVisible)
          _buildPhoneForgotPasswordToggle(),

        // Action button (Continue, Login, or Submit for forgot password)
        if (isForgotPasswordVisible) ...[
          // Forgot password flow
          _buildPhoneForgotPasswordButton(),
        ] else if (!showPasswordField) ...[
          // Show Continue button when password field is not visible
          UiUtils.buildButton(
            context,
            disabled: mobileNumController.text.isEmpty,
            disabledColor: Colors.grey,
            height: 48.rh(context),
            onPressed: checkPhoneNumberExists,
            buttonTitle: 'continue'.translate(context),
            border: BorderSide(
              color: context.color.borderColor,
            ),
            radius: 4,
          ),
        ] else ...[
          // Show Login button when password field is visible
          UiUtils.buildButton(
            context,
            disabled: passwordController.text.isEmpty,
            disabledColor: Colors.grey,
            height: 48.rh(context),
            onPressed: sendPhoneLogin,
            buttonTitle: 'login'.translate(context),
            border: BorderSide(
              color: context.color.borderColor,
            ),
            radius: 4,
          ),
        ],

        SizedBox(height: 16.rh(context)),

        // Sign up section - only show when not in forgot password mode
        if (!isForgotPasswordVisible) _buildPhoneSignUpSection(),

        // Social login section - show when social login is enabled and not in forgot password mode
        if (isSocialLoginEnabled && !isForgotPasswordVisible) ...[
          SizedBox(height: 8.rh(context)),
          _buildOrDivider(),
          SizedBox(height: 10.rh(context)),

          // Social login buttons
          if (Platform.isIOS) ...[
            _buildSocialButton(
              text: 'signInWithApple'.translate(context),
              icon: AppIcons.apple,
              onTap: _onTapAppleLogin,
            ),
          ],
          _buildSocialButton(
            text: 'signInWithGoogle'.translate(context),
            icon: AppIcons.google,
            onTap: _onGoogleTap,
          ),
        ],
      ],
    );
  }

  Widget _buildPhoneEmailWithSocialSection() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        buildMobileEmailField(),
        SizedBox(height: 8.rh(context)),
        _buildOrDivider(),
        SizedBox(height: 10.rh(context)),

        // Toggle button for phone/email when both are enabled
        if (isEmailLoginEnabled && isPhoneLoginEnabled) ...[
          _buildToggleButton(),
          SizedBox(width: 10.rw(context)),
        ],

        // Social login buttons
        if (Platform.isIOS) ...[
          _buildSocialButton(
            text: 'signInWithApple'.translate(context),
            icon: AppIcons.apple,
            onTap: _onTapAppleLogin,
          ),
        ],
        _buildSocialButton(
          text: 'signInWithGoogle'.translate(context),
          icon: AppIcons.google,
          onTap: _onGoogleTap,
        ),
      ],
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        Expanded(child: UiUtils.getDivider(context)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: CustomText('or'.translate(context)),
        ),
        Expanded(child: UiUtils.getDivider(context)),
      ],
    );
  }

  Widget _buildToggleButton() {
    return _buildSocialButton(
      text: isEmailSelected
          ? 'signInWithPhone'.translate(context)
          : 'signInWithEmail'.translate(context),
      icon: isEmailSelected ? AppIcons.phone : AppIcons.email,
      iconColor: context.color.textColorDark,
      onTap: () {
        setState(() {
          isEmailSelected = !isEmailSelected;
          isForgotPasswordVisible = false;
          isResendOtpButtonVisible = false;
          showPasswordField =
              false; // Reset password field visibility when switching
          passwordController.clear(); // Clear password when switching
        });
      },
    );
  }

  Widget _buildSocialButton({
    required String icon,
    required VoidCallback onTap,
    required String text,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: () {
        HelperUtils.unfocus();
        onTap();
      },
      child: Container(
        alignment: Alignment.center,
        margin: EdgeInsets.only(bottom: 12.rh(context)),
        height: 48.rh(context),
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: showRegisterOptions
                ? context.color.textColorDark
                : context.color.borderColor,
          ),
        ),
        child: Row(
          mainAxisAlignment: .center,
          children: [
            Container(
              alignment: Alignment.center,
              child: CustomImage(
                imageUrl: icon,
                color: iconColor,
                height: 24.rh(context),
                width: 24.rw(context),
              ),
            ),
            SizedBox(width: 8.rw(context)),
            CustomText(text),
          ],
        ),
      ),
    );
  }

  // Optimized version with shared components

  // Shared email field widget
  Widget _buildEmailField() {
    return CustomTextFormField(
      dense: true,
      controller: emailAddressController,
      validator: CustomTextFieldValidator.email,
      hintText: 'email'.translate(context),
      textDirection: .ltr,
      keyboard: TextInputType.emailAddress,
      formaters: [FilteringTextInputFormatter.singleLineFormatter],
      prefix: Padding(
        padding: EdgeInsetsDirectional.only(
          start: 12.rw(context),
          end: 4.rw(context),
          top: 12.rh(context),
          bottom: 12.rh(context),
        ),
        child: CustomImage(
          imageUrl: AppIcons.email,
          color: context.color.textColorDark.withValues(alpha: 0.5),
          fit: .none,
        ),
      ),
      onChange: (value) {
        setState(() {});
        isResendOtpButtonVisible = false;
      },
    );
  }

  // Shared password field widget
  Widget _buildPasswordField() {
    return CustomTextFormField(
      dense: true,
      controller: passwordController,
      validator: CustomTextFieldValidator.nullCheck,
      hintText: 'password'.translate(context),
      isPassword: !isPasswordVisible,
      textDirection: .ltr,
      keyboard: TextInputType.visiblePassword,
      formaters: [FilteringTextInputFormatter.singleLineFormatter],
      prefix: Padding(
        padding: EdgeInsetsDirectional.only(
          start: 12.rw(context),
          end: 4.rw(context),
          top: 12.rh(context),
          bottom: 12.rh(context),
        ),
        child: CustomImage(
          imageUrl: AppIcons.lock,
          color: context.color.textColorDark.withValues(alpha: 0.5),
          fit: .none,
        ),
      ),
      suffix: Padding(
        padding: EdgeInsetsDirectional.only(end: 12.rw(context)),
        child: GestureDetector(
          onTap: () {
            setState(() {
              isPasswordVisible = !isPasswordVisible;
            });
          },
          child: CustomImage(
            imageUrl: isPasswordVisible ? AppIcons.eyeSlash : AppIcons.eye,
            color: context.color.textColorDark.withValues(alpha: 0.5),
            fit: .none,
          ),
        ),
      ),
      onChange: (value) {
        setState(() {});
      },
    );
  }

  // Shared mobile field widget
  Widget _buildMobileField() {
    // Phone field without arrow button (registration and forgot password use separate flows)
    return CustomTextFormField(
      dense: true,
      controller: mobileNumController,
      validator: CustomTextFieldValidator.phoneNumber,
      isReadOnly:
          showPasswordField, // Make read-only once password field is shown
      maxLine: 1,
      hintText: '0000000000',
      hintTextSize: context.font.md,
      keyboard: TextInputType.phone,
      maxLength: HelperUtils.getMaxPhoneLength(countryCode ?? ''),
      formaters: [FilteringTextInputFormatter.digitsOnly],
      prefix: CountryPickerWidget(
        flagEmoji: flagEmoji,
        onTap: showPasswordField
            ? () {}
            : showCountryCode, // Disable country picker when password field is shown
        countryCode: countryCode,
      ),
      suffix: showPasswordField
          ? Padding(
              padding: EdgeInsetsDirectional.only(end: 12.rw(context)),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    showPasswordField = false;
                    passwordController.clear();
                  });
                },
                child: Icon(
                  Icons.edit,
                  color: context.color.tertiaryColor,
                  size: 20,
                ),
              ),
            )
          : null,
      onChange: (value) {
        if (!showPasswordField) {
          setState(() {
            mobileNumController.text = HelperUtils.formatPhoneNumber(
              mobileNumController.text,
              countryCode!,
            );
          });
        }
      },
    );
  }

  // Shared forgot password toggle widget
  Widget _buildForgotPasswordToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isForgotPasswordVisible = !isForgotPasswordVisible;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.rh(context)),
        alignment: AlignmentDirectional.centerEnd,
        child: CustomText(
          isForgotPasswordVisible
              ? 'goBackToLogin'.translate(context)
              : 'forgotPassword'.translate(context), // Assuming this exists
          fontSize: context.font.sm,
          color: context.color.tertiaryColor,
        ),
      ),
    );
  }

  // Shared sign up section widget
  Widget _buildSignUpSection() {
    return Wrap(
      alignment: .center,
      crossAxisAlignment: .center,
      runAlignment: .center,
      children: [
        CustomText(
          'registerWith'.translate(context),
          fontSize: context.font.sm,
        ),
        SizedBox(width: 4.rw(context)),
        CustomText(
          'appName'.translate(context),
          fontSize: context.font.sm,
        ),
        SizedBox(width: 4.rw(context)),
        GestureDetector(
          onTap: () async {
            // Don't allow toggling to registration options in social-only mode
            if (currentLoginMode == LoginMode.socialOnly) {
              return;
            }
            setState(() {
              showRegisterOptions = true;
            });
          },
          child: CustomText(
            'signUp'.translate(context),
            fontWeight: .w600,
            fontSize: context.font.sm,
            color: context.color.tertiaryColor,
          ),
        ),
      ],
    );
  }

  // Phone sign up section widget
  Widget _buildPhoneSignUpSection() {
    return Wrap(
      alignment: .center,
      crossAxisAlignment: .center,
      runAlignment: .center,
      children: [
        CustomText(
          'registerWith'.translate(context),
          fontSize: context.font.sm,
        ),
        SizedBox(width: 4.rw(context)),
        CustomText(
          'appName'.translate(context),
          fontSize: context.font.sm,
        ),
        SizedBox(width: 4.rw(context)),
        GestureDetector(
          onTap: () async {
            // Don't allow toggling to registration options in social-only mode
            if (currentLoginMode == LoginMode.socialOnly) {
              return;
            }
            setState(() {
              showRegisterOptions = true;
            });
          },
          child: CustomText(
            'signUp'.translate(context),
            fontWeight: .w600,
            fontSize: context.font.sm,
            color: context.color.tertiaryColor,
          ),
        ),
      ],
    );
  }

  // Phone forgot password toggle widget
  Widget _buildPhoneForgotPasswordToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          isForgotPasswordVisible = !isForgotPasswordVisible;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.rh(context)),
        alignment: AlignmentDirectional.centerEnd,
        child: CustomText(
          isForgotPasswordVisible
              ? 'goBackToLogin'.translate(context)
              : 'forgotPassword'.translate(context),
          fontSize: context.font.sm,
          color: context.color.tertiaryColor,
        ),
      ),
    );
  }

  // Phone forgot password button widget
  Widget _buildPhoneForgotPasswordButton() {
    return UiUtils.buildButton(
      context,
      onPressed: () async {
        final hasInternet = await HelperUtils.checkInternet();
        if (!hasInternet) {
          return HelperUtils.showSnackBarMessage(
            context,
            'noInternet',
            type: .error,
          );
        }

        if (mobileNumController.text.trim().isEmpty) {
          return HelperUtils.showSnackBarMessage(
            context,
            'enterValidNumber',
            type: .error,
          );
        }

        // Set flag for forgot password flow, then send OTP
        setState(() {
          otpIs = 'forgotPassword';
        });

        // Clean phone number
        final cleanPhoneNumber = mobileNumController.text.trim().replaceAll(
          ' ',
          '',
        );

        // Send OTP for verification
        if (AppSettings.otpServiceProvider == 'twilio') {
          await context.read<SendOtpCubit>().sendTwilioOTP(
            phoneNumber: cleanPhoneNumber,
            countryCode: countryCode!,
          );
        } else if (AppSettings.otpServiceProvider == 'firebase') {
          await context.read<SendOtpCubit>().sendFirebaseOTP(
            phoneNumber: cleanPhoneNumber,
            countryCode: countryCode!,
          );
        }
        // Navigation to OTP screen will be handled by BlocListener in _handleSendOtpSuccess
      },
      disabled: mobileNumController.text.trim().isEmpty,
      disabledColor: Colors.grey,
      height: 48.rh(context),
      border: BorderSide(
        color: context.color.borderColor,
      ),
      buttonTitle: 'submit'.translate(context),
    );
  }

  // Shared action button widget
  Widget _buildActionButton() {
    if (isForgotPasswordVisible) {
      if (isEmailSelected && isEmailLoginEnabled) {
        return buildSubmitButton();
      } else if (!isEmailSelected && isPhoneLoginEnabled) {
        return _buildPhoneForgotPasswordButton();
      }
    } else if (isResendOtpButtonVisible) {
      return buildResendOtpButton();
    } else {
      return buildNextButton();
    }
    return const SizedBox.shrink();
  }

  // Optimized buildMobileEmailField
  Widget buildMobileEmailField() {
    if (isForgotPasswordVisible) {
      return _buildForgotPasswordFields();
    }
    return _buildLoginFields();
  }

  Widget _buildLoginFields() {
    return Column(
      children: [
        // Input field (email or phone based on selection)
        _buildCurrentInputField(),
        const SizedBox(height: 12),
        // Password field - only show for email or if phone number is verified
        if (isEmailSelected ||
            (!isEmailSelected && showPasswordField) ||
            (isEmailLoginEnabled && !isPhoneLoginEnabled)) ...[
          _buildPasswordField(),
          // Forgot password toggle
          _buildCurrentForgotPasswordToggle(),
        ],

        // Action button
        _buildActionButton(),
        // Toggle button when both phone and email are enabled but social login is disabled
        if (_shouldShowToggleButton()) ...[
          SizedBox(height: 8.rh(context)),
          _buildInputTypeToggleButton(),
        ],
        SizedBox(height: 8.rh(context)),

        // Sign up section
        _buildCurrentSignUpSection(),
      ],
    );
  }

  Widget _buildForgotPasswordFields() {
    return Column(
      children: [
        // Input field (email or phone based on selection)
        _buildCurrentInputField(),

        // Forgot password toggle (to go back)
        _buildCurrentForgotPasswordToggle(),

        // Action button
        _buildActionButton(),

        SizedBox(height: 8.rh(context)),

        // Sign up section
        _buildCurrentSignUpSection(),
      ],
    );
  }

  Widget _buildCurrentInputField() {
    if (isEmailSelected && isEmailLoginEnabled) {
      return _buildEmailField();
    } else if (isPhoneLoginEnabled && !isEmailSelected) {
      return _buildMobileField();
    } else if (isEmailLoginEnabled && !isPhoneLoginEnabled) {
      // When phone is disabled but email is enabled, show email field
      return _buildEmailField();
    }
    return const SizedBox.shrink();
  }

  Widget _buildCurrentForgotPasswordToggle() {
    if (isEmailSelected && isEmailLoginEnabled) {
      return _buildForgotPasswordToggle();
    } else if (!isEmailSelected && isPhoneLoginEnabled) {
      return _buildPhoneForgotPasswordToggle();
    } else if (isEmailLoginEnabled && !isPhoneLoginEnabled) {
      // When phone is disabled but email is enabled, show email forgot password toggle
      return _buildForgotPasswordToggle();
    }
    return const SizedBox.shrink();
  }

  Widget _buildCurrentSignUpSection() {
    if (isEmailSelected && isEmailLoginEnabled) {
      return _buildSignUpSection();
    } else if (!isEmailSelected && isPhoneLoginEnabled) {
      return _buildPhoneSignUpSection();
    } else if (isEmailLoginEnabled && !isPhoneLoginEnabled) {
      // When phone is disabled but email is enabled, show email sign up section
      return _buildSignUpSection();
    }
    return const SizedBox.shrink();
  }

  bool _shouldShowToggleButton() {
    return !isSocialLoginEnabled &&
        isPhoneLoginEnabled &&
        isEmailLoginEnabled &&
        !isForgotPasswordVisible;
  }

  Widget _buildInputTypeToggleButton() {
    return _buildSocialButton(
      text: isEmailSelected
          ? 'signInWithPhone'.translate(context)
          : 'signInWithEmail'.translate(context),
      icon: isEmailSelected ? AppIcons.phone : AppIcons.email,
      iconColor: context.color.textColorDark,
      onTap: () {
        setState(() {
          isEmailSelected = !isEmailSelected;
          isForgotPasswordVisible = false;
          isResendOtpButtonVisible = false;
          showPasswordField =
              false; // Reset password field visibility when switching
          passwordController.clear(); // Clear password when switching
        });
      },
    );
  }

  // Optimized buildEmailOnly
  Widget buildEmailOnly() {
    return Column(
      children: [
        // Email field
        _buildEmailField(),

        // Password field (only when not in forgot password mode)
        if (!isForgotPasswordVisible) ...[
          SizedBox(height: 8.rh(context)),
          _buildPasswordField(),
        ],

        SizedBox(height: 8.rh(context)),

        // Forgot password toggle
        _buildForgotPasswordToggle(),

        SizedBox(height: 8.rh(context)),

        // Action button
        _buildActionButton(),

        SizedBox(height: 8.rh(context)),

        // Sign up section
        _buildSignUpSection(),

        SizedBox(height: 8.rh(context)),

        // Divider for social login section
        _buildOrDivider(),
        SizedBox(height: 8.rh(context)),
      ],
    );
  }

  void showCountryCode() {
    showCountryPicker(
      context: context,
      showPhoneCode: true,
      countryListTheme: CountryListThemeData(
        borderRadius: BorderRadius.circular(8),
        backgroundColor: context.color.backgroundColor,
        textStyle: TextStyle(color: context.color.textColorDark),
        inputDecoration: InputDecoration(
          hintStyle: TextStyle(color: context.color.textColorDark),
          helperStyle: TextStyle(color: context.color.textColorDark),
          prefixIcon: const Icon(Icons.search),
          iconColor: context.color.tertiaryColor,
          prefixIconColor: context.color.tertiaryColor,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: context.color.tertiaryColor),
          ),
          floatingLabelStyle: TextStyle(color: context.color.tertiaryColor),
          labelText: 'search'.translate(context),
          border: const OutlineInputBorder(),
          labelStyle: TextStyle(color: context.color.textColorDark),
        ),
      ),
      onSelect: (Country value) {
        flagEmoji = value.flagEmoji;
        countryCode = value.phoneCode;
        setState(() {});
      },
    );
  }

  Widget buildForgotPasswordText() {
    return GestureDetector(
      onTap: () {
        isForgotPasswordVisible = true;
        setState(() {});
      },
      child: Container(
        alignment: AlignmentDirectional.centerEnd,
        padding: const EdgeInsetsDirectional.only(end: 18, bottom: 10),
        child: CustomText(
          'forgotPassword'.translate(context),
          fontSize: context.font.sm,
          color: context.color.tertiaryColor,
        ),
      ),
    );
  }

  Widget buildSubmitButton() {
    return UiUtils.buildButton(
      context,
      onPressed: () async {
        final hasInternet = await HelperUtils.checkInternet();
        if (!hasInternet) {
          return HelperUtils.showSnackBarMessage(
            context,
            'noInternet',
            type: .error,
          );
        }
        await context.read<SendOtpCubit>().sendForgotPasswordEmail(
          email: emailAddressController.text.trim(),
        );
      },
      disabled: emailAddressController.text.trim().isEmpty,
      disabledColor: Colors.grey,
      height: 48.rh(context),
      border: BorderSide(
        color: context.color.borderColor,
      ),
      buttonTitle: 'submit'.translate(context),
    );
  }

  Widget buildResendOtpButton() {
    return UiUtils.buildButton(
      context,
      onPressed: () async {
        await context.read<SendOtpCubit>().resendEmailOTP(
          email: emailAddressController.text.trim(),
          password: passwordController.text.trim(),
        );
      },
      buttonTitle: 'resendOtpBtnLbl'.translate(context),
    );
  }

  Widget buildNextButton() {
    if (!isEmailSelected && isPhoneLoginEnabled) {
      // For phone login, first check if user exists, then show password field
      if (!showPasswordField) {
        return UiUtils.buildButton(
          context,
          disabled: mobileNumController.text.isEmpty,
          disabledColor: Colors.grey,
          height: 48.rh(context),
          onPressed: checkPhoneNumberExists,
          buttonTitle: 'continue'.translate(context),
          border: BorderSide(
            color: context.color.borderColor,
          ),
          radius: 4,
        );
      } else {
        // Password field is shown, now allow login
        return UiUtils.buildButton(
          context,
          disabled: passwordController.text.isEmpty,
          disabledColor: Colors.grey,
          height: 48.rh(context),
          onPressed: sendPhoneLogin,
          buttonTitle: 'login'.translate(context),
          border: BorderSide(
            color: context.color.borderColor,
          ),
          radius: 4,
        );
      }
    }
    if (isEmailSelected && !isEmailLoginEnabled) return const SizedBox.shrink();
    return UiUtils.buildButton(
      context,
      disabled:
          emailAddressController.text.isEmpty ||
          passwordController.text.isEmpty,
      disabledColor: Colors.grey,
      height: 48.rh(context),
      onPressed: sendEmailVerificationCode,
      buttonTitle: 'continue'.translate(context),
      border: BorderSide(
        color: context.color.borderColor,
      ),
      radius: 4,
    );
  }

  Future<void> sendEmailVerificationCode() async {
    final hasInternet = await HelperUtils.checkInternet();
    if (!hasInternet) {
      return HelperUtils.showSnackBarMessage(
        context,
        'noInternet',
        type: .error,
      );
    }
    if (FormValidator.validateEmailForm(_formKey, context)) {
      unawaited(Widgets.showLoader(context));
      await context.read<LoginCubit>().loginWithEmail(
        email: emailAddressController.text.trim(),
        password: passwordController.text.trim(),
        type: LoginType.email,
      );

      final state = context.read<LoginCubit>().state;
      if (state is LoginFailure && state.key == 'emailNotVerified') {
        Widgets.hideLoder(context);
        isResendOtpButtonVisible = true;
        setState(() {});
      } else if (state is LoginSuccess) {
        Widgets.hideLoder(context);
      } else {
        Widgets.hideLoder(context);
      }
    }
  }

  Future<void> checkPhoneNumberExists() async {
    final hasInternet = await HelperUtils.checkInternet();
    if (!hasInternet) {
      return HelperUtils.showSnackBarMessage(
        context,
        'noInternet',
        type: .error,
      );
    }

    if (mobileNumController.text.isEmpty) {
      return HelperUtils.showSnackBarMessage(
        context,
        'enterValidNumber',
        type: .error,
      );
    }

    unawaited(Widgets.showLoader(context));

    try {
      // Remove all spaces and formatting from phone number
      final cleanPhoneNumber = mobileNumController.text.trim().replaceAll(
        ' ',
        '',
      );

      final checkResult = await AuthRepository().checkNumberPasswordExists(
        mobile: cleanPhoneNumber,
        countryCode: countryCode ?? '',
      );

      Widgets.hideLoder(context);

      // Debug: Print entire response

      // Check if data exists (API may return error: true when password doesn't exist)
      final data = checkResult['data'] as Map<String, dynamic>?;

      if (data != null) {
        final userExists = data['user_exists'] as bool? ?? false;
        final passwordExists = data['password_exists'] as bool? ?? false;

        // Debug: Print values to check

        if (userExists && passwordExists) {
          // User exists with password, show password field
          setState(() {
            showPasswordField = true;
          });
        } else if (userExists && !passwordExists) {
          // User exists but no password, need to set password after OTP verification
          setState(() {
            otpIs = 'updatePassword';
          });

          // Send OTP for verification
          if (AppSettings.otpServiceProvider == 'twilio') {
            await context.read<SendOtpCubit>().sendTwilioOTP(
              phoneNumber: cleanPhoneNumber,
              countryCode: countryCode!,
            );
          } else if (AppSettings.otpServiceProvider == 'firebase') {
            await context.read<SendOtpCubit>().sendFirebaseOTP(
              phoneNumber: cleanPhoneNumber,
              countryCode: countryCode!,
            );
          }
        } else {
          // User doesn't exist, redirect to registration
          HelperUtils.showSnackBarMessage(
            context,
            'userNotFoundPleaseRegister'.translate(context),
            type: .error,
          );
        }
      } else {
        HelperUtils.showSnackBarMessage(
          context,
          checkResult['message']?.toString() ??
              'errorCheckingUserStatus'.translate(context),
          type: .error,
        );
      }
    } on Exception catch (e) {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(
        context,
        e.toString(),
        type: .error,
      );
    }
  }

  Future<void> sendPhoneLogin() async {
    final hasInternet = await HelperUtils.checkInternet();
    if (!hasInternet) {
      return HelperUtils.showSnackBarMessage(
        context,
        'noInternet',
        type: .error,
      );
    }

    if (passwordController.text.isEmpty) {
      return HelperUtils.showSnackBarMessage(
        context,
        'enterValidEmailPassword',
        type: .error,
      );
    }

    unawaited(Widgets.showLoader(context));

    try {
      // Remove all spaces and formatting from phone number
      final cleanPhoneNumber = mobileNumController.text.trim().replaceAll(
        ' ',
        '',
      );

      // Proceed with login
      await context.read<LoginCubit>().loginWithPhone(
        phone: cleanPhoneNumber,
        password: passwordController.text.trim(),
        countryCode: countryCode ?? '',
        type: LoginType.phone,
      );

      final state = context.read<LoginCubit>().state;
      if (state is LoginSuccess) {
        Widgets.hideLoder(context);
      } else {
        Widgets.hideLoder(context);
      }
    } on Exception catch (e) {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(
        context,
        e.toString(),
        type: .error,
      );
    }
  }

  // This function builds the UI with Row and CustomText widgets with tap events
  Widget buildTermsAndPrivacyWidget({
    required BuildContext context,
    required bool isTablet, // Pass `isTablet` as a parameter
  }) {
    return Container(
      width: isTablet ? context.screenWidth * 0.7 : context.screenWidth,
      color: context.color.secondaryColor,
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ), // Added for better spacing
      margin: EdgeInsets.only(bottom: 8.rh(context)),
      child: Column(
        children: [
          // Policy agreement statement
          CustomText(
            'policyAggreementStatement'.translate(context),
            fontSize: context.font.xxs,
            color: context.color.textColorDark,
            textAlign: .center,
          ),
          const SizedBox(height: 4),
          // Terms and Privacy row
          Row(
            mainAxisAlignment: .center,
            children: [
              // Terms and Conditions
              GestureDetector(
                onTap: () async {
                  await _handleTermsAndConditionsTap(context);
                },
                child: CustomText(
                  'termsConditions'.translate(context),
                  fontSize: context.font.xxs,
                  color: context.color.tertiaryColor,
                  fontWeight: .w600,
                  showUnderline: true,
                  underlineOrLineColor: context.color.tertiaryColor,
                ),
              ),
              // "and" text
              CustomText(
                ' ${'and'.translate(context)} ',
                fontSize: context.font.xxs,
                color: context.color.textColorDark,
              ),
              // Privacy Policy
              GestureDetector(
                onTap: () async {
                  await _handlePrivacyPolicyTap(context);
                },
                child: CustomText(
                  'privacyPolicy'.translate(context),
                  fontSize: context.font.xxs,
                  color: context.color.tertiaryColor,
                  fontWeight: .w600,
                  showUnderline: true,
                  underlineOrLineColor: context.color.tertiaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Handle Terms and Conditions tap
  Future<void> _handleTermsAndConditionsTap(BuildContext context) async {
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
  }

  // Handle Privacy Policy tap
  Future<void> _handlePrivacyPolicyTap(BuildContext context) async {
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
  }
}
