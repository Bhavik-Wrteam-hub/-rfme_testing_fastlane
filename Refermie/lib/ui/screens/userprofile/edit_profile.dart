import 'dart:developer';

import 'package:country_picker/country_picker.dart';
import 'package:ebroker/data/cubits/auth/get_user_data_cubit.dart';
import 'package:ebroker/data/model/user_model.dart';
import 'package:ebroker/data/repositories/auth_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/auth/country_picker.dart';
import 'package:ebroker/ui/screens/widgets/image_cropper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({
    required this.from,
    super.key,
    this.navigateToHome,
    this.phoneNumber,
  });
  final String from;
  final bool? navigateToHome;
  final String? phoneNumber;
  @override
  State<EditProfileScreen> createState() => EditProfileScreenState();

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments! as Map?;
    return CupertinoPageRoute(
      builder: (_) => EditProfileScreen(
        from: arguments?['from'] as String,
        navigateToHome: arguments?['navigateToHome'] as bool?,
        phoneNumber: arguments?['phoneNumber'] as String?,
      ),
    );
  }
}

class EditProfileScreenState extends State<EditProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController instagramController = TextEditingController();
  final TextEditingController facebookController = TextEditingController();
  final TextEditingController youtubeController = TextEditingController();
  final TextEditingController twitterController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  dynamic size;
  dynamic cityEdit;
  dynamic stateEdit;
  dynamic countryEdit;
  dynamic placeid;
  String? name;
  String? email;
  Placemark? place;
  String? address;
  File? fileUserimg;
  bool isNotificationsEnabled = true;
  String? latitude;
  String? longitude;
  String? flagEmoji;
  late LoginType loginType;
  String? selectedCountryCode = HiveUtils.getUserDetails().countryCode ?? '';
  List<Country> countryList = CountryService().getAll();

  @override
  void initState() {
    super.initState();
    unawaited(context.read<GetUserDataCubit>().getUserData(context));
    loginType = HiveUtils.getUserLoginType();
    if (widget.from == 'login') {
      GuestChecker.set('profile_screen', isGuest: false);
    }
    unawaited(
      HelperUtils.getSimCountry().then((value) {
        selectedCountryCode = value.phoneCode;
        flagEmoji = value.flagEmoji;
        setState(() {});
      }),
    );
    cityEdit = HiveUtils.getUserCityName();
    stateEdit = HiveUtils.getUserStateName();
    countryEdit = HiveUtils.getUserCountryName();
    placeid = HiveUtils.getUserCityPlaceId() ?? '';
    latitude = HiveUtils.getUserLatitude()?.toString();
    longitude = HiveUtils.getUserLongitude()?.toString();

    placeid = HiveUtils.getUserCityPlaceId() ?? '';
    phoneController.text =
        HiveUtils.getUserDetails().mobile ?? widget.phoneNumber ?? '';
    final firebaseDisplayName = FirebaseAuth.instance.currentUser?.displayName;
    final firebaseProviderData =
        FirebaseAuth.instance.currentUser?.providerData.first.displayName;
    final userName = firebaseDisplayName ?? firebaseProviderData ?? '';
    nameController.text = HiveUtils.getUserDetails().name ?? userName;
    emailController.text = HiveUtils.getUserDetails().email ?? '';
    addressController.text = HiveUtils.getUserDetails().address ?? '';
    instagramController.text = HiveUtils.getUserDetails().instagram ?? '';
    facebookController.text = HiveUtils.getUserDetails().facebook ?? '';
    youtubeController.text = HiveUtils.getUserDetails().youtube ?? '';
    twitterController.text = HiveUtils.getUserDetails().twitter ?? '';
    isNotificationsEnabled = true;
  }

  @override
  void dispose() {
    phoneController.dispose();
    nameController.dispose();
    emailController.dispose();
    addressController.dispose();
    instagramController.dispose();
    facebookController.dispose();
    youtubeController.dispose();
    twitterController.dispose();
    super.dispose();
  }

  Future<void> _onTapChangeLocation() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final placeMark =
        await Navigator.pushNamed(
              context,
              Routes.chooseLocaitonMap,
              arguments: {
                'from': 'edit_profile',
              },
            )
            as Map?;
    try {
      setState(() async {
        final latlng = placeMark?['latlng'] as LatLng? ?? const LatLng(0, 0);
        place = placeMark?['place'] as Placemark? ?? const Placemark();
        latitude = latlng.latitude.toString();
        longitude = latlng.longitude.toString();
        cityEdit = place?.locality;
        stateEdit = place?.administrativeArea;
        countryEdit = place?.country;
        placeid = place?.postalCode;

        await HiveUtils.setLocation(
          city: place?.locality ?? '',
          state: place?.administrativeArea ?? '',
          latitude: latlng.latitude.toString(),
          longitude: latlng.longitude.toString(),
          country: place?.country ?? '',
          placeId: place?.postalCode ?? '',
        );
      });
    } on Exception catch (e, st) {
      log(e.toString() + st.toString());
    }
  }

  void showCountryCode() {
    if (loginType == LoginType.phone) {
      return;
    }
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
        selectedCountryCode = value.phoneCode;
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: safeAreaCondition(
        child: Scaffold(
          backgroundColor: context.color.primaryColor,
          appBar: widget.from == 'login'
              ? null
              : CustomAppBar(
                  title: 'editProfile'.translate(context),
                ),
          body: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: BlocBuilder<GetUserDataCubit, GetUserDataState>(
              builder: (context, state) {
                if (state is GetUserDataInProgress) {
                  return buildShimmer();
                }
                if (state is GetUserDataFailure) {
                  return SomethingWentWrong(
                    errorMessage: state.errorMessage,
                  );
                }
                if (state is GetUserDataSuccess) {
                  return SingleChildScrollView(
                    physics: Constant.scrollPhysics,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: .start,
                        children: <Widget>[
                          Align(child: buildProfilePicture()),
                          buildTextField(
                            context,
                            title: 'fullName',
                            controller: nameController,
                            validator: CustomTextFieldValidator.nullCheck,
                          ),
                          buildTextField(
                            context,
                            title: 'email',
                            controller: emailController,
                            validator: CustomTextFieldValidator.email,
                            readOnly: loginType != LoginType.phone,
                          ),
                          buildTextField(
                            context,
                            textDirection: Directionality.of(context),
                            title: 'phoneNumber',
                            keyboard: TextInputType.phone,
                            maxLength: HelperUtils.getMaxPhoneLength(
                              selectedCountryCode!,
                            ),
                            onChange: (value) {
                              setState(() {
                                phoneController.text =
                                    HelperUtils.formatPhoneNumber(
                                      phoneController.text,
                                      selectedCountryCode!,
                                    );
                              });
                            },
                            prefix: CountryPickerWidget(
                              flagEmoji: flagEmoji,
                              onTap: showCountryCode,
                              countryCode: selectedCountryCode,
                            ),
                            controller: phoneController,
                            formaters: [FilteringTextInputFormatter.digitsOnly],
                            validator: Constant.isDemoModeOn
                                ? CustomTextFieldValidator.nullCheck
                                : CustomTextFieldValidator.phoneNumber,
                            readOnly: loginType == LoginType.phone,
                          ),
                          buildAddressTextField(
                            context,
                            title: 'addressLbl',
                            controller: addressController,
                            validator: CustomTextFieldValidator.nullCheck,
                          ),
                          const SizedBox(height: 10),
                          CustomText(
                            'enablesNewSection'.translate(context),
                            fontWeight: .w300,
                            fontSize: context.font.xs,
                            color: context.color.textColorDark.withValues(
                              alpha: 0.8,
                            ),
                          ),
                          buildTextField(
                            context,
                            title: 'instagram',
                            controller: instagramController,
                            validator: CustomTextFieldValidator.link,
                          ),
                          buildTextField(
                            context,
                            title: 'facebook',
                            controller: facebookController,
                            validator: CustomTextFieldValidator.link,
                          ),
                          buildTextField(
                            context,
                            title: 'youtube',
                            controller: youtubeController,
                            validator: CustomTextFieldValidator.link,
                          ),
                          buildTextField(
                            context,
                            title: 'twitter',
                            controller: twitterController,
                            validator: CustomTextFieldValidator.link,
                          ),
                          SizedBox(height: 45.rh(context)),
                          UiUtils.buildButton(
                            context,
                            outerPadding: const EdgeInsets.only(bottom: 16),
                            onPressed: () async {
                              if (cityEdit != null && cityEdit != '') {
                              } else {
                                await HiveUtils.clearLocation();
                              }
                              await validateData();
                            },
                            height: 48.rh(context),
                            buttonTitle: 'updateProfile'.translate(context),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget buildShimmer() {
    return ListView.separated(
      itemBuilder: (context, index) => index == 0
          ? Shimmer.fromColors(
              period: const Duration(milliseconds: 1000),
              baseColor: Theme.of(
                context,
              ).colorScheme.shimmerBaseColor,
              highlightColor: Theme.of(
                context,
              ).colorScheme.shimmerHighlightColor,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.shimmerContentColor,
                  shape: .circle,
                ),
              ),
            )
          : CustomShimmer(
              height: 50.rh(context),
            ),
      separatorBuilder: (context, index) =>
          SizedBox(height: index == 0 ? 24 : 16),
      itemCount: 10,
    );
  }

  Widget locationWidget(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48.rh(context),
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: context.color.borderColor,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.only(start: 12),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: (cityEdit != '' && cityEdit != null)
                            ? CustomText(
                                '$cityEdit,$stateEdit,$countryEdit',
                                maxLines: 1,
                              )
                            : CustomText(
                                'selectLocationOptional'.translate(context),
                              ),
                      ),
                    ),
                  ),
                  if (cityEdit != '' && cityEdit != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.only(end: 12),
                      child: GestureDetector(
                        onTap: () async {
                          cityEdit = '';
                          stateEdit = '';
                          countryEdit = '';
                          await HiveUtils.clearLocation();
                          setState(() {});
                        },
                        child: Icon(
                          Icons.close,
                          color: context.color.textColorDark,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () async {
              await _onTapChangeLocation();
            },
            child: Container(
              height: 48.rh(context),
              width: 48.rw(context),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: context.color.borderColor,
                ),
              ),
              child: CustomImage(
                height: 24.rh(context),
                width: 24.rw(context),
                imageUrl: AppIcons.location,
                color: context.color.textColorDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget safeAreaCondition({required Widget child}) {
    if (widget.from == 'login') {
      return SafeArea(child: child);
    }
    return child;
  }

  Widget buildNotificationEnableDisableSwitch(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: context.color.borderColor,
        ),
        borderRadius: BorderRadius.circular(10),
        color: context.color.textLightColor.withValues(alpha: 00.01),
      ),
      height: 55.rh(context),
      width: double.infinity,
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomText(
              (isNotificationsEnabled ? 'enabled' : 'disabled').translate(
                context,
              ),
              fontSize: context.font.md,
            ),
          ),
          CupertinoSwitch(
            activeTrackColor: context.color.tertiaryColor,
            value: isNotificationsEnabled,
            onChanged: (value) {
              isNotificationsEnabled = value;
              setState(() {});
            },
          ),
        ],
      ),
    );
  }

  Widget buildTextField(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    List<TextInputFormatter>? formaters,
    TextInputType? keyboard,
    Widget? prefix,
    Widget? suffix,
    CustomTextFieldValidator? validator,
    bool? readOnly,
    TextDirection? textDirection,
    dynamic Function(dynamic value)? onChange,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        SizedBox(
          height: 8.rh(context),
        ),
        CustomText(
          title.translate(context),
          fontSize: context.font.sm,
          fontWeight: .w600,
        ),
        SizedBox(
          height: 8.rh(context),
        ),
        CustomTextFormField(
          maxLength: maxLength,
          textDirection: textDirection,
          controller: controller,
          keyboard: keyboard,
          isReadOnly: readOnly,
          validator: validator,
          onChange: onChange,

          prefix: prefix,
          suffix: suffix,
          formaters: formaters, //
          fillColor: context.color.secondaryColor,
        ),
      ],
    );
  }

  Widget buildAddressTextField(
    BuildContext context, {
    required String title,
    required TextEditingController controller,
    CustomTextFieldValidator? validator,
    bool? readOnly,
  }) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        SizedBox(height: 8.rh(context)),
        CustomText(
          title.translate(context),
          fontSize: context.font.sm,
          fontWeight: .w600,
        ),
        SizedBox(height: 8.rh(context)),
        CustomTextFormField(
          controller: controller,
          maxLine: 5,
          action: .newline,
          isReadOnly: readOnly,
          validator: validator,
          fillColor: context.color.secondaryColor,
        ),
        const SizedBox(width: 8),
        locationWidget(context),
      ],
    );
  }

  Widget getProfileImage() {
    if (fileUserimg != null) {
      return Image.file(
        fileUserimg!,
        fit: .contain,
      );
    } else {
      if (widget.from == 'login') {
        if (HiveUtils.getUserDetails().profile != '' &&
            HiveUtils.getUserDetails().profile != null) {
          return CustomImage(
            imageUrl: HiveUtils.getUserDetails().profile!,
          );
        }

        return CustomImage(
          imageUrl: AppIcons.defaultPersonLogo,
          color: context.color.tertiaryColor,
        );
      } else {
        if ((HiveUtils.getUserDetails().profile ?? '').isEmpty) {
          return CustomImage(
            imageUrl: AppIcons.defaultPersonLogo,
            color: context.color.tertiaryColor,
          );
        } else {
          return CustomImage(
            imageUrl: HiveUtils.getUserDetails().profile!,
          );
        }
      }
    }
  }

  Widget buildProfilePicture() {
    return Stack(
      children: [
        Container(
          height: 124.rh(context),
          width: 124.rw(context),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: .circle,
            border: Border.all(color: context.color.tertiaryColor, width: 2),
          ),
          child: Container(
            alignment: Alignment.center,
            clipBehavior: .antiAlias,
            decoration: BoxDecoration(
              color: context.color.tertiaryColor.withValues(alpha: 0.2),
              shape: .circle,
            ),
            width: 106.rw(context),
            height: 106.rh(context),
            child: getProfileImage(),
          ),
        ),
        PositionedDirectional(
          bottom: 0,
          end: 0,
          child: GestureDetector(
            onTap: showPicker,
            child: Container(
              height: 37.rh(context),
              width: 37.rw(context),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: context.color.buttonColor,
                  width: 2,
                ),
                shape: .circle,
                color: context.color.tertiaryColor,
              ),
              child: CustomImage(
                imageUrl: AppIcons.edit,
                height: 18.rh(context),
                width: 18.rw(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> validateData() async {
    if (_formKey.currentState!.validate()) {
      final checkinternet = await HelperUtils.checkInternet();
      if (!checkinternet) {
        Future.delayed(
          Duration.zero,
          () {
            HelperUtils.showSnackBarMessage(
              context,
              'lblchecknetwork',
            );
          },
        );
        return;
      }
      if (selectedCountryCode == null || selectedCountryCode == '') {
        HelperUtils.showSnackBarMessage(
          context,
          'pleaseSelectCountry'.translate(context),
        );
        return;
      }
      await process();
    }
  }

  Future<void> process() async {
    try {
      unawaited(Widgets.showLoader(context));
      final response = await context.read<AuthCubit>().updateUserData(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        fileUserimg: fileUserimg,
        phone: phoneController.text,
        latitude: latitude,
        longitude: longitude,
        city: cityEdit?.toString() ?? '',
        state: stateEdit?.toString() ?? '',
        country: countryEdit?.toString() ?? '',
        countryCode: selectedCountryCode,
        address: addressController.text,
        notification: isNotificationsEnabled ? '1' : '0',
        instagram: instagramController.text,
        facebook: facebookController.text,
        youtube: youtubeController.text,
        twitter: twitterController.text,
      );

      Future.delayed(Duration.zero, () async {
        final data = response['data'];
        data['country_code'] = selectedCountryCode;

        await HiveUtils.setUserData(data as Map<dynamic, dynamic>? ?? {});
        if (cityEdit != null && cityEdit != '') {
          await HiveUtils.setLocation(
            city: cityEdit?.toString() ?? '',
            state: stateEdit?.toString() ?? '',
            latitude: latitude,
            longitude: longitude,
            country: countryEdit?.toString() ?? '',
            placeId: placeid?.toString() ?? '',
          );
        }

        context.read<UserDetailsCubit>().copy(
          UserModel.fromJson(
            response['data'] as Map<String, dynamic>? ?? {},
          ),
        );
      });

      Future.delayed(
        Duration.zero,
        () {
          Widgets.hideLoder(context);
          HelperUtils.showSnackBarMessage(
            context,
            'profileupdated',
          );

          Navigator.pop(context);
          if (widget.navigateToHome ?? false) {
            Future.delayed(Duration.zero, () async {
              await HelperUtils.killPreviousPages(
                context,
                Routes.main,
                {'from': 'login'},
              );
            });
          }
        },
      );

      Widgets.hideLoder(context);
    } on ApiException catch (e) {
      Widgets.hideLoder(context);
      var errorMessage = e.toString();

      if (Constant.isDemoModeOn &&
          (HiveUtils.getUserDetails().isDemoUser ?? false)) {
        errorMessage = 'thisActionNotValidDemo'.translate(context);
      }
      HelperUtils.showSnackBarMessage(
        context,
        errorMessage,
        messageDuration: 1,
      );
    }
  }

  Future<void> showPicker() async {
    await showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.color.secondaryColor,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: CustomText('gallery'.translate(context)),
                onTap: () async {
                  await _imgFromGallery(ImageSource.gallery);
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: CustomText('camera'.translate(context)),
                onTap: () async {
                  await _imgFromGallery(ImageSource.camera);
                  Navigator.of(context).pop();
                },
              ),
              if (fileUserimg != null && widget.from == 'login')
                ListTile(
                  leading: const Icon(Icons.clear_rounded),
                  title: CustomText('lblremove'.translate(context)),
                  onTap: () {
                    fileUserimg = null;

                    Navigator.of(context).pop();
                    setState(() {});
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _imgFromGallery(ImageSource imageSource) async {
    CropImage.init(context);

    final pickedFile = await ImagePicker().pickImage(source: imageSource);

    if (pickedFile != null) {
      CroppedFile? croppedFile;
      croppedFile = await CropImage.crop(filePath: pickedFile.path);
      if (croppedFile == null) {
        fileUserimg = null;
      } else {
        fileUserimg = File(croppedFile.path);
      }
    } else {
      fileUserimg = null;
    }
    setState(() {});
  }
}
