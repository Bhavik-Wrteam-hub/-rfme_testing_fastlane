import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sms_autofill/sms_autofill.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({
    required this.isDeleteAccount,
    required this.isEmailSelected,
    super.key,
    this.phoneNumber,
    this.email,
    this.password,
    this.rePassword,
    this.otpVerificationId,
    this.countryCode,
    this.otpIs,
    this.name,
  });

  final bool isDeleteAccount;

  final bool isEmailSelected;
  final String? phoneNumber;
  final String? email;
  final String? password;
  final String? rePassword;
  final String? otpVerificationId;
  final String? countryCode;
  final String? otpIs;
  final String? name;

  @override
  State<OtpScreen> createState() => _OtpScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments! as Map;
    return CupertinoPageRoute(
      builder: (_) {
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (context) => SendOtpCubit()),
            BlocProvider(create: (context) => VerifyOtpCubit()),
          ],
          child: OtpScreen(
            isDeleteAccount: arguments['isDeleteAccount'] as bool? ?? false,
            phoneNumber: arguments['phoneNumber']?.toString() ?? '',
            email: arguments['email']?.toString() ?? '',
            password: arguments['password']?.toString(),
            rePassword: arguments['rePassword']?.toString(),
            otpVerificationId: arguments['otpVerificationId']?.toString() ?? '',
            countryCode: arguments['countryCode']?.toString() ?? '',
            otpIs: arguments['otpIs']?.toString() ?? '',
            isEmailSelected: arguments['isEmailSelected'] as bool? ?? false,
            name: arguments['name']?.toString(),
          ),
        );
      },
    );
  }
}

class _OtpScreenState extends State<OtpScreen> {
  Timer? timer;
  ValueNotifier<int> otpResendTime = ValueNotifier<int>(
    Constant.otpResendSecond,
  );
  final TextEditingController phoneOtpController = TextEditingController();
  final TextEditingController emailOtpController = TextEditingController();
  int otpLength = 6;
  bool isOtpAutoFilled = false;
  final List<FocusNode> _focusNodes = [];
  int focusIndex = 0;
  String otpIs = '';

  @override
  void initState() {
    otpIs = widget.otpIs ?? '';
    super.initState();

    // Debug: Log what the OTP screen receives on initialization

    if (timer != null) {
      timer!.cancel();
    }
    unawaited(startTimer());
  }

  @override
  void dispose() {
    for (final fNode in _focusNodes) {
      fNode.dispose();
    }
    otpResendTime.dispose();
    phoneOtpController.dispose();
    emailOtpController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<VerifyOtpCubit, VerifyOtpState>(
          listener: (context, state) async {
            if (state is VerifyOtpInProgress) {
              unawaited(Widgets.showLoader(context));
            } else {
              Widgets.hideLoder(context);
            }
            if (state is VerifyOtpFailure) {
              Widgets.hideLoder(context);
              if (state.errorMessage.contains('invalid-verification-code')) {
                HelperUtils.showSnackBarMessage(
                  context,
                  'invalidOtp',
                  messageDuration: 1,
                  type: .error,
                );
              } else {
                HelperUtils.showSnackBarMessage(
                  context,
                  state.errorMessage,
                  type: .error,
                );
              }
            }

            if (state is VerifyOtpSuccess) {
              Widgets.hideLoder(context);

              // Debug logging

              if (widget.isDeleteAccount) {
                await context.read<DeleteAccountCubit>().deleteUserAccount(
                  context,
                );
              } else if (widget.otpIs == 'updatePassword') {
                // Handle password update flow
                await _handlePasswordUpdate(context, state);
              } else if (widget.otpIs == 'forgotPassword') {
                // Handle forgot password flow - show password dialog AFTER OTP verification
                await _handleForgotPassword(context, state);
              } else if (widget.otpIs == 'phoneRegistration') {
                // Handle phone registration flow - call user-register API with firebase_id
                await _handlePhoneRegistration(context, state);
              } else if (widget.otpIs == 'emailRegistration') {
                // Handle email registration flow - call user-register API
                await _handleEmailRegistration(context, state);
              } else if (widget.isEmailSelected) {
                // Email login (not registration)
                await Navigator.of(context).pushReplacementNamed(
                  Routes.login,
                  arguments: {
                    'isDeleteAccount': widget.isDeleteAccount,
                  },
                );
                HelperUtils.showSnackBarMessage(
                  context,
                  'otpVerifiedSuccessfully',
                  type: .success,
                );
              } else if (AppSettings.otpServiceProvider == 'firebase') {
                await context.read<LoginCubit>().login(
                  type: LoginType.phone,
                  phoneNumber:
                      widget.phoneNumber ??
                      state.credential!.user!.phoneNumber?.toString() ??
                      '',
                  uniqueId: state.credential!.user!.uid?.toString() ?? '',
                  countryCode: widget.countryCode ?? '',
                );
              } else if (AppSettings.otpServiceProvider == 'twilio') {
                await context.read<LoginCubit>().login(
                  type: LoginType.phone,
                  phoneNumber: widget.phoneNumber ?? '',
                  uniqueId: state.authId!,
                  countryCode: widget.countryCode ?? '',
                );
              }
            }
          },
        ),
        BlocListener<SendOtpCubit, SendOtpState>(
          listener: (context, state) async {
            if (state is SendOtpInProgress) {
              unawaited(Widgets.showLoader(context));
            } else {
              Widgets.hideLoder(context);
            }

            if (state is SendOtpSuccess) {
              // Show success message
              HelperUtils.showSnackBarMessage(
                context,
                'otpResentSuccessfully',
                type: .success,
              );

              // Restart the timer
              await startTimer();
            }

            if (state is SendOtpFailure) {
              HelperUtils.showSnackBarMessage(
                context,
                state.errorMessage,
                type: .error,
              );
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: context.color.primaryColor,
        appBar: CustomAppBar(
          title: 'enterCodeSend'.translate(context),
        ),
        body: otpScreenContainer(context),
      ),
    );
  }

  Widget otpScreenContainer(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(20),
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisSize: .min,
        children: <Widget>[
          // Header message and contact info
          _buildHeaderSection(context),

          SizedBox(height: 20.rh(context)),

          // OTP input field
          _buildOtpField(context),

          // Login button
          loginButton(context),

          // Timer widget
          SizedBox(child: resendOtpTimerWidget()),

          // Resend button (only show when timer is not active)
          if (!(timer?.isActive ?? false)) _buildResendButton(context),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    final isEmail = widget.isEmailSelected;
    final messageKey = isEmail ? 'weSentCodeOnEmail' : 'weSentCodeOnNumber';
    final contactInfo = _getContactInfo();

    return Column(
      children: [
        CustomText(
          messageKey.translate(context),
          fontSize: context.font.md,
          color: context.color.textColorDark.withValues(alpha: 0.8),
        ),
        CustomText(
          contactInfo,
          fontSize: context.font.md,
          color: context.color.textColorDark.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  String _getContactInfo() {
    if (widget.isEmailSelected) {
      return widget.isDeleteAccount
          ? HiveUtils.getUserDetails().email ?? ''
          : widget.email ?? '';
    } else {
      final countryCode = widget.countryCode;
      final phoneNumber = widget.isDeleteAccount
          ? HiveUtils.getUserDetails().mobile
          : widget.phoneNumber;
      return '+$countryCode $phoneNumber';
    }
  }

  Widget _buildOtpField(BuildContext context) {
    final controller = widget.isEmailSelected
        ? emailOtpController
        : phoneOtpController;

    return PinFieldAutoFill(
      autoFocus: true,
      controller: controller,
      decoration: UnderlineDecoration(
        textStyle: TextStyle(
          color: context.color.textColorDark.withValues(alpha: 0.8),
          fontSize: context.font.xl,
        ),
        lineHeight: 1.5,
        colorBuilder: PinListenColorBuilder(
          context.color.tertiaryColor,
          Colors.grey,
        ),
      ),
      currentCode: demoOTP(),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: Platform.isIOS
          ? const TextInputType.numberWithOptions(signed: true)
          : TextInputType.number,
      onCodeSubmitted: (code) => _handleOtpSubmission(context, code),
      onCodeChanged: (code) {
        if (code?.length == 6) {
          otpIs = code!;
        }
      },
    );
  }

  Future<void> _handleOtpSubmission(BuildContext context, String code) async {
    if (widget.isEmailSelected) {
      await context.read<VerifyOtpCubit>().verifyEmailOTP(
        otp: code,
        email: widget.email ?? '',
      );
    } else {
      await _handlePhoneOtpSubmission(context, code);
    }
  }

  Future<void> _handlePhoneOtpSubmission(
    BuildContext context,
    String code,
  ) async {
    final cubit = context.read<VerifyOtpCubit>();

    switch (AppSettings.otpServiceProvider) {
      case 'firebase':
        final verificationId = widget.isDeleteAccount
            ? verificationID
            : widget.otpVerificationId;
        await cubit.verifyOTP(verificationId: verificationId, otp: code);

      case 'twilio':
        await cubit.verifyOTP(
          otp: widget.otpIs ?? '',
          number: widget.phoneNumber,
          countryCode: widget.countryCode,
        );
    }
  }

  Widget _buildResendButton(BuildContext context) {
    return SizedBox(
      height: 70,
      child: IgnorePointer(
        ignoring: timer?.isActive ?? false,
        child: TextButton(
          onPressed: resendOTP,
          child: CustomText(
            'resendCodeBtnLbl'.translate(context),
            color: (timer?.isActive ?? false)
                ? context.color.textLightColor
                : context.color.tertiaryColor,
            fontWeight: .bold,
          ),
        ),
      ),
    );
  }

  Future<void> startTimer() async {
    timer?.cancel();
    timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (otpResendTime.value == 0) {
          timer.cancel();
          otpResendTime.value = Constant.otpResendSecond;
          setState(() {});
        } else {
          if (mounted) otpResendTime.value--;
        }
      },
    );
    setState(() {});
  }

  String demoOTP() {
    if (Constant.isDemoModeOn &&
        Constant.demoMobileNumber == widget.phoneNumber) {
      return Constant.demoModeOTP; // If true, return the demo mode OTP.
    } else {
      return ''; // If false, return an empty string.
    }
  }

  Widget resendOtpTimerWidget() {
    return ValueListenableBuilder(
      valueListenable: otpResendTime,
      builder: (context, value, child) {
        if (!(timer?.isActive ?? false)) {
          return const SizedBox.shrink();
        }
        String formatSecondsToMinutes(int seconds) {
          final minutes = seconds ~/ 60;
          final remainingSeconds = seconds % 60;
          return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
        }

        return SizedBox(
          height: 70,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text.rich(
              TextSpan(
                text: "${"resendMessage".translate(context)} ",
                style: TextStyle(
                  color: context.color.textColorDark,
                  letterSpacing: 0.5,
                ),
                children: [
                  TextSpan(
                    text: formatSecondsToMinutes(int.parse(value.toString())),
                    style: TextStyle(
                      color: context.color.tertiaryColor,
                      fontWeight: .w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                  TextSpan(
                    text: 'resendMessageDuration'.translate(context),
                    style: TextStyle(
                      color: context.color.tertiaryColor,
                      fontWeight: .w400,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> resendOTP() async {
    if (widget.isEmailSelected) {
      await context.read<SendOtpCubit>().resendEmailOTP(
        email: widget.email ?? '',
        password: widget.password ?? '',
      );
      return;
    }
    if (AppSettings.otpServiceProvider == 'firebase') {
      await context.read<SendOtpCubit>().sendFirebaseOTP(
        countryCode: widget.countryCode ?? '',
        phoneNumber: widget.phoneNumber ?? '',
      );
    } else if (AppSettings.otpServiceProvider == 'twilio') {
      await context.read<SendOtpCubit>().sendTwilioOTP(
        countryCode: widget.countryCode ?? '',
        phoneNumber: widget.phoneNumber ?? '',
      );
    }
  }

  Widget buildButton(
    BuildContext context, {
    required VoidCallback onPressed,
    required String buttonTitle,
    required bool disabled,
    double? height,
    double? width,
  }) {
    return UiUtils.buildButton(
      context,
      height: height ?? 56.rh(context),
      outerPadding: EdgeInsets.only(top: 58.rh(context)),
      disabledColor: context.color.textLightColor,
      onPressed: (!disabled)
          ? () {
              HelperUtils.unfocus();
              onPressed.call();
            }
          : () {},
      buttonTitle: buttonTitle,
    );
  }

  Widget loginButton(BuildContext context) {
    return buildButton(
      context,
      onPressed: onTapLogin,
      disabled: false,
      width: MediaQuery.of(context).size.width,
      buttonTitle: 'comfirmBtnLbl'.translate(context),
    );
  }

  Future<void> onTapLogin() async {
    if (widget.isEmailSelected) {
      try {
        await context.read<VerifyOtpCubit>().verifyEmailOTP(
          otp: emailOtpController.text,
          email: widget.email ?? '',
        );
        if (context.read<VerifyOtpCubit>().state is VerifyOtpSuccess) {
          await Navigator.pushReplacementNamed(
            context,
            Routes.main,
            arguments: {
              'from': 'login',
            },
          );
        }
        return;
      } on Exception catch (e) {
        if (e.toString().contains('invalid-verification-code')) {
          HelperUtils.showSnackBarMessage(
            context,
            'invalidOtp',
            messageDuration: 1,
            type: .error,
          );
          return;
        } else {
          HelperUtils.showSnackBarMessage(
            context,
            e.toString(),
            messageDuration: 1,
            type: .error,
          );
        }
        return;
      }
    }
    try {
      if (phoneOtpController.text.isEmpty) {
        HelperUtils.showSnackBarMessage(
          context,
          'lblEnterOtp',
          messageDuration: 2,
        );
        return;
      }
      if (AppSettings.otpServiceProvider == 'firebase') {
        if (widget.isDeleteAccount) {
          await context.read<VerifyOtpCubit>().verifyOTP(
            verificationId: verificationID,
            otp: phoneOtpController.text,
          );
        } else {
          await context.read<VerifyOtpCubit>().verifyOTP(
            verificationId: widget.otpVerificationId,
            otp: phoneOtpController.text,
            number: widget.phoneNumber,
            countryCode: widget.countryCode,
          );
        }
      } else if (AppSettings.otpServiceProvider == 'twilio') {
        await context.read<VerifyOtpCubit>().verifyOTP(
          otp: phoneOtpController.text,
          number: widget.phoneNumber,
          countryCode: widget.countryCode,
        );
      }
    } on Exception catch (_) {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(
        context,
        'invalidOtp',
      );
    }
  }

  Future<void> _handlePasswordUpdate(
    BuildContext context,
    VerifyOtpSuccess state,
  ) async {
    try {
      Widgets.hideLoder(context);

      // Get Firebase ID from OTP verification
      final firebaseId =
          (AppSettings.otpServiceProvider == 'firebase'
                  ? state.credential!.user!.uid
                  : state.authId!)
              as String;

      // Show password dialog to user
      final passwordData = await _showSetPasswordDialog(context);

      if (passwordData == null) {
        // User cancelled the dialog
        Navigator.of(context).pop();
        return;
      }

      // Show loader while updating password
      unawaited(Widgets.showLoader(context));

      // Remove all spaces and formatting from phone number
      final cleanPhoneNumber = (widget.phoneNumber ?? '').replaceAll(' ', '');

      // Call update password API
      final result = await AuthRepository().updateNumberPassword(
        firebaseId: firebaseId,
        mobile: cleanPhoneNumber,
        countryCode: widget.countryCode ?? '',
        password: passwordData['password']!,
        rePassword: passwordData['rePassword']!,
      );

      Widgets.hideLoder(context);

      if (result['error'] == false) {
        HelperUtils.showSnackBarMessage(
          context,
          result['message']?.toString() ?? 'Password updated successfully',
          type: .success,
        );

        // Now login with the new password
        unawaited(Widgets.showLoader(context));
        await context.read<LoginCubit>().loginWithPhone(
          phone: cleanPhoneNumber,
          password: passwordData['password']!,
          countryCode: widget.countryCode ?? '',
          type: LoginType.phone,
        );

        final loginState = context.read<LoginCubit>().state;
        Widgets.hideLoder(context);

        if (loginState is LoginSuccess) {
          // Navigate to main screen
          await Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.main,
            (route) => false,
            arguments: {'from': 'login'},
          );
        }
      } else {
        HelperUtils.showSnackBarMessage(
          context,
          result['message']?.toString() ?? 'Failed to update password',
          type: .error,
        );
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(
        context,
        e.toString(),
        type: .error,
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleForgotPassword(
    BuildContext context,
    VerifyOtpSuccess state,
  ) async {
    try {
      Widgets.hideLoder(context);

      // Get Firebase ID from OTP verification
      final firebaseId =
          (AppSettings.otpServiceProvider == 'firebase'
                  ? state.credential!.user!.uid
                  : state.authId!)
              as String;

      // Show password dialog to user
      final passwordData = await _showResetPasswordDialog(context);

      if (passwordData == null) {
        // User cancelled the dialog
        Navigator.of(context).pop();
        return;
      }

      // Show loader while updating password
      unawaited(Widgets.showLoader(context));

      // Remove all spaces and formatting from phone number
      final cleanPhoneNumber = (widget.phoneNumber ?? '').replaceAll(' ', '');

      // Call update password API
      final result = await AuthRepository().updateNumberPassword(
        firebaseId: firebaseId,
        mobile: cleanPhoneNumber,
        countryCode: widget.countryCode ?? '',
        password: passwordData['password']!,
        rePassword: passwordData['rePassword']!,
      );

      Widgets.hideLoder(context);

      if (result['error'] == false) {
        HelperUtils.showSnackBarMessage(
          context,
          result['message']?.toString() ?? 'Password reset successfully',
          type: .success,
        );

        // Now login with the new password
        unawaited(Widgets.showLoader(context));
        await context.read<LoginCubit>().loginWithPhone(
          phone: cleanPhoneNumber,
          password: passwordData['password']!,
          countryCode: widget.countryCode ?? '',
          type: LoginType.phone,
        );

        final loginState = context.read<LoginCubit>().state;
        Widgets.hideLoder(context);

        if (loginState is LoginSuccess) {
          // Navigate to main screen
          await Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.main,
            (route) => false,
            arguments: {'from': 'login'},
          );
        }
      } else {
        HelperUtils.showSnackBarMessage(
          context,
          result['message']?.toString() ?? 'Failed to reset password',
          type: .error,
        );
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(
        context,
        e.toString(),
        type: .error,
      );
      Navigator.of(context).pop();
    }
  }

  Future<Map<String, String>?> _showResetPasswordDialog(
    BuildContext context,
  ) async {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    var isNewPasswordVisible = false;
    var isConfirmPasswordVisible = false;

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: context.color.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: CustomText(
                'resetPassword'.translate(context),
                fontWeight: .w600,
                fontSize: context.font.xl,
                color: context.color.textColorDark,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    CustomText(
                      'pleaseEnterYourNewPasswordToResetYourAccountPassword'
                          .translate(context),
                      fontSize: context.font.sm,
                      textAlign: .center,
                    ),
                    SizedBox(height: 16.rh(context)),
                    CustomTextFormField(
                      dense: true,
                      controller: newPasswordController,
                      validator: CustomTextFieldValidator.nullCheck,
                      hintText: 'newPassword'.translate(context),
                      isPassword: !isNewPasswordVisible,
                      textDirection: .ltr,
                      keyboard: TextInputType.visiblePassword,
                      formaters: [
                        FilteringTextInputFormatter.singleLineFormatter,
                      ],
                      prefix: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 12.rw(context),
                          end: 4.rw(context),
                          top: 12.rh(context),
                          bottom: 12.rh(context),
                        ),
                        child: CustomImage(
                          imageUrl: AppIcons.lock,
                          color: context.color.textColorDark.withValues(
                            alpha: 0.5,
                          ),
                          fit: .none,
                        ),
                      ),
                      suffix: Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: 12.rw(context),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isNewPasswordVisible = !isNewPasswordVisible;
                            });
                          },
                          child: CustomImage(
                            imageUrl: isNewPasswordVisible
                                ? AppIcons.eyeSlash
                                : AppIcons.eye,
                            color: context.color.textColorDark.withValues(
                              alpha: 0.5,
                            ),
                            fit: .none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.rh(context)),
                    CustomTextFormField(
                      dense: true,
                      controller: confirmPasswordController,
                      validator: CustomTextFieldValidator.nullCheck,
                      hintText: 'confirmPassword'.translate(context),
                      isPassword: !isConfirmPasswordVisible,
                      textDirection: .ltr,
                      keyboard: TextInputType.visiblePassword,
                      formaters: [
                        FilteringTextInputFormatter.singleLineFormatter,
                      ],
                      prefix: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 12.rw(context),
                          end: 4.rw(context),
                          top: 12.rh(context),
                          bottom: 12.rh(context),
                        ),
                        child: CustomImage(
                          imageUrl: AppIcons.lock,
                          color: context.color.textColorDark.withValues(
                            alpha: 0.5,
                          ),
                          fit: .none,
                        ),
                      ),
                      suffix: Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: 12.rw(context),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible;
                            });
                          },
                          child: CustomImage(
                            imageUrl: isConfirmPasswordVisible
                                ? AppIcons.eyeSlash
                                : AppIcons.eye,
                            color: context.color.textColorDark.withValues(
                              alpha: 0.5,
                            ),
                            fit: .none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: CustomText(
                    'cancelLbl'.translate(context),
                    color: context.color.textColorDark,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (newPasswordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      HelperUtils.showSnackBarMessage(
                        dialogContext,
                        'pleaseFillAllFields'.translate(context),
                        type: .error,
                      );
                      return;
                    }

                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      HelperUtils.showSnackBarMessage(
                        dialogContext,
                        'passwordsDoNotMatch'.translate(context),
                        type: .error,
                      );
                      return;
                    }

                    Navigator.of(dialogContext).pop({
                      'password': newPasswordController.text,
                      'rePassword': confirmPasswordController.text,
                    });
                  },
                  child: CustomText(
                    'resetPassword'.translate(context),
                    color: context.color.tertiaryColor,
                    fontWeight: .w600,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _handlePhoneRegistration(
    BuildContext context,
    VerifyOtpSuccess state,
  ) async {
    try {
      unawaited(Widgets.showLoader(context));

      // Get Firebase ID from OTP verification
      final firebaseId =
          (AppSettings.otpServiceProvider == 'firebase'
                  ? state.credential!.user!.uid
                  : state.authId!)
              as String;

      // Get registration data from widget
      final cleanPhoneNumber = (widget.phoneNumber ?? '').replaceAll(' ', '');
      final password = widget.password ?? '';
      final rePassword = widget.rePassword ?? '';
      final name = widget.name ?? '';

      // Call user-register API
      final result = await AuthRepository().registerUserWithPhone(
        firebaseId: firebaseId,
        mobile: cleanPhoneNumber,
        countryCode: widget.countryCode ?? '',
        password: password,
        rePassword: rePassword,
        name: name,
        email: widget.email ?? '',
      );

      Widgets.hideLoder(context);

      if (result['error'] == false) {
        HelperUtils.showSnackBarMessage(
          context,
          result['message']?.toString() ?? 'Registration successful',
          type: .success,
        );

        // Set up a listener for login state changes
        final loginCompleter = Completer<LoginState>();
        late StreamSubscription<LoginState> subscription;

        subscription = context.read<LoginCubit>().stream.listen((
          loginState,
        ) async {
          if (loginState is LoginSuccess || loginState is LoginFailure) {
            if (!loginCompleter.isCompleted) {
              loginCompleter.complete(loginState);
              await subscription.cancel();
            }
          }
        });

        // Now login with the new credentials
        unawaited(Widgets.showLoader(context));
        await context.read<LoginCubit>().loginWithPhone(
          phone: cleanPhoneNumber,
          password: password,
          countryCode: widget.countryCode ?? '',
          type: LoginType.phone,
        );

        // Wait for login to complete
        final loginState = await loginCompleter.future.timeout(
          const Duration(seconds: 30),
          onTimeout: () async {
            await subscription.cancel();
            return LoginFailure('Login timeout', 'timeout');
          },
        );

        Widgets.hideLoder(context);

        if (loginState is LoginSuccess) {
          // Load user settings
          await HiveUtils.setIsNotGuest();
          await LoadAppSettings().load(initBox: true);
          context.read<UserDetailsCubit>().fill(HiveUtils.getUserDetails());

          await context.read<FetchSystemSettingsCubit>().fetchSettings(
            isAnonymous: false,
            forceRefresh: true,
          );

          await HiveUtils.setUserIsAuthenticated();
          await HiveUtils.setUserIsNotNew();

          // Navigate to main screen
          await Navigator.of(context).pushNamedAndRemoveUntil(
            Routes.main,
            (route) => false,
            arguments: {'from': 'login'},
          );
        } else if (loginState is LoginFailure) {
          HelperUtils.showSnackBarMessage(
            context,
            loginState.errorMessage,
            type: .error,
          );
          Navigator.of(context).pop();
        }
      } else {
        HelperUtils.showSnackBarMessage(
          context,
          result['message']?.toString() ?? 'Registration failed',
          type: .error,
        );
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(
        context,
        e.toString(),
        type: .error,
      );
      Navigator.of(context).pop();
    }
  }

  Future<void> _handleEmailRegistration(
    BuildContext context,
    VerifyOtpSuccess state,
  ) async {
    try {
      // For email registration, the user is already registered via sendEmailOTP
      // We just need to log them in after OTP verification

      HelperUtils.showSnackBarMessage(
        context,
        'Registration successful',
        type: .success,
      );

      // Set up a listener for login state changes
      final loginCompleter = Completer<LoginState>();
      late StreamSubscription<LoginState> subscription;

      subscription = context.read<LoginCubit>().stream.listen((
        loginState,
      ) async {
        if (loginState is LoginSuccess || loginState is LoginFailure) {
          if (!loginCompleter.isCompleted) {
            loginCompleter.complete(loginState);
            await subscription.cancel();
          }
        }
      });

      // Login with the new credentials
      unawaited(Widgets.showLoader(context));
      await context.read<LoginCubit>().loginWithEmail(
        email: widget.email ?? '',
        password: widget.password ?? '',
        type: LoginType.email,
      );

      // Wait for login to complete
      final loginState = await loginCompleter.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () async {
          await subscription.cancel();
          return LoginFailure('Login timeout', 'timeout');
        },
      );

      Widgets.hideLoder(context);

      if (loginState is LoginSuccess) {
        // Load user settings
        await HiveUtils.setIsNotGuest();
        await LoadAppSettings().load(initBox: true);
        context.read<UserDetailsCubit>().fill(HiveUtils.getUserDetails());

        await context.read<FetchSystemSettingsCubit>().fetchSettings(
          isAnonymous: false,
          forceRefresh: true,
        );

        await HiveUtils.setUserIsAuthenticated();
        await HiveUtils.setUserIsNotNew();

        // Navigate to main screen
        await Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.main,
          (route) => false,
          arguments: {'from': 'login'},
        );
      } else if (loginState is LoginFailure) {
        HelperUtils.showSnackBarMessage(
          context,
          loginState.errorMessage,
          type: .error,
        );
        Navigator.of(context).pop();
      }
    } on Exception catch (e) {
      Widgets.hideLoder(context);
      HelperUtils.showSnackBarMessage(
        context,
        e.toString(),
        type: .error,
      );
      Navigator.of(context).pop();
    }
  }

  Future<Map<String, String>?> _showSetPasswordDialog(
    BuildContext context,
  ) async {
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    var isNewPasswordVisible = false;
    var isConfirmPasswordVisible = false;

    return showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: context.color.secondaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: CustomText(
                'setPassword'.translate(context),
                fontWeight: .w600,
                fontSize: context.font.xl,
                color: context.color.textColorDark,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: .min,
                  children: [
                    CustomText(
                      'accountExistsPasswordNotSet'.translate(context),
                      fontSize: context.font.sm,
                      textAlign: .center,
                    ),
                    SizedBox(height: 16.rh(context)),
                    CustomTextFormField(
                      dense: true,
                      controller: newPasswordController,
                      validator: CustomTextFieldValidator.nullCheck,
                      hintText: 'newPassword'.translate(context),
                      isPassword: !isNewPasswordVisible,
                      textDirection: .ltr,
                      keyboard: TextInputType.visiblePassword,
                      formaters: [
                        FilteringTextInputFormatter.singleLineFormatter,
                      ],
                      prefix: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 12.rw(context),
                          end: 4.rw(context),
                          top: 12.rh(context),
                          bottom: 12.rh(context),
                        ),
                        child: CustomImage(
                          imageUrl: AppIcons.lock,
                          color: context.color.textColorDark.withValues(
                            alpha: 0.5,
                          ),
                          fit: .none,
                        ),
                      ),
                      suffix: Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: 12.rw(context),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isNewPasswordVisible = !isNewPasswordVisible;
                            });
                          },
                          child: CustomImage(
                            imageUrl: isNewPasswordVisible
                                ? AppIcons.eyeSlash
                                : AppIcons.eye,
                            color: context.color.textColorDark.withValues(
                              alpha: 0.5,
                            ),
                            fit: .none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.rh(context)),
                    CustomTextFormField(
                      dense: true,
                      controller: confirmPasswordController,
                      validator: CustomTextFieldValidator.nullCheck,
                      hintText: 'confirmPassword'.translate(context),
                      isPassword: !isConfirmPasswordVisible,
                      textDirection: .ltr,
                      keyboard: TextInputType.visiblePassword,
                      formaters: [
                        FilteringTextInputFormatter.singleLineFormatter,
                      ],
                      prefix: Padding(
                        padding: EdgeInsetsDirectional.only(
                          start: 12.rw(context),
                          end: 4.rw(context),
                          top: 12.rh(context),
                          bottom: 12.rh(context),
                        ),
                        child: CustomImage(
                          imageUrl: AppIcons.lock,
                          color: context.color.textColorDark.withValues(
                            alpha: 0.5,
                          ),
                          fit: .none,
                        ),
                      ),
                      suffix: Padding(
                        padding: EdgeInsetsDirectional.only(
                          end: 12.rw(context),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              isConfirmPasswordVisible =
                                  !isConfirmPasswordVisible;
                            });
                          },
                          child: CustomImage(
                            imageUrl: isConfirmPasswordVisible
                                ? AppIcons.eyeSlash
                                : AppIcons.eye,
                            color: context.color.textColorDark.withValues(
                              alpha: 0.5,
                            ),
                            fit: .none,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: CustomText(
                    'cancelLbl'.translate(context),
                    color: context.color.textColorDark,
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    if (newPasswordController.text.isEmpty ||
                        confirmPasswordController.text.isEmpty) {
                      await Fluttertoast.showToast(
                        msg: 'pleaseFillAllFields'.translate(context),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                      return;
                    }

                    if (newPasswordController.text !=
                        confirmPasswordController.text) {
                      await Fluttertoast.showToast(
                        msg: 'passwordsDoNotMatch'.translate(context),
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                      return;
                    }

                    Navigator.of(dialogContext).pop({
                      'password': newPasswordController.text,
                      'rePassword': confirmPasswordController.text,
                    });
                  },
                  child: CustomText(
                    'setPassword'.translate(context),
                    color: context.color.tertiaryColor,
                    fontWeight: .w600,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
