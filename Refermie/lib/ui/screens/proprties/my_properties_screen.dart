import 'dart:async';

import 'package:ebroker/app/routes.dart';
import 'package:ebroker/data/cubits/category/fetch_category_cubit.dart';
import 'package:ebroker/data/cubits/favorite/add_to_favorite_cubit.dart';
import 'package:ebroker/data/cubits/property/fetch_my_properties_cubit.dart';
import 'package:ebroker/data/cubits/system/fetch_system_settings_cubit.dart';
import 'package:ebroker/data/helper/widgets.dart';
import 'package:ebroker/data/model/system_settings_model.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/ui/screens/home/widgets/custom_refresh_indicator.dart';
import 'package:ebroker/ui/screens/home/widgets/property_horizontal_card.dart';
import 'package:ebroker/ui/screens/proprties/add_propery_screens/select_type_of_property.dart';
import 'package:ebroker/ui/screens/widgets/blurred_dialoge_box.dart';
import 'package:ebroker/ui/screens/widgets/errors/no_data_found.dart';
import 'package:ebroker/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/custom_appbar.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/guest_checker.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

int propertyScreenCurrentPage = 0;
ValueNotifier<Map<String, dynamic>> emptyCheckNotifier = ValueNotifier({
  'isSellEmpty': false,
  'isRentEmpty': false,
});

class PropertiesScreen extends StatefulWidget {
  const PropertiesScreen({super.key});

  @override
  State<PropertiesScreen> createState() => MyPropertyState();
}

enum FilterType { status, propertyType }

class MyPropertyState extends State<PropertiesScreen>
    with TickerProviderStateMixin {
  int offset = 0;
  int total = 0;
  bool isSellEmpty = false;
  bool isRentEmpty = false;
  final controller = ScrollController();
  String selectedType = '';
  String selectedStatus = '';
  // Track temporary filter selections
  late String tempSelectedType;
  late String tempSelectedStatus;

  @override
  void initState() {
    tempSelectedType = selectedType;
    tempSelectedStatus = selectedStatus;
    if (context.read<FetchMyPropertiesCubit>().state
        is! FetchMyPropertiesSuccess) {
      unawaited(fetchMyProperties());
    }

    addScrollListener();
    super.initState();
  }

  void addScrollListener() {
    controller.addListener(() async {
      if (controller.position.pixels == controller.position.maxScrollExtent) {
        if (context.read<FetchMyPropertiesCubit>().hasMoreData()) {
          await context.read<FetchMyPropertiesCubit>().fetchMoreProperties(
            type: selectedType.toLowerCase(),
            status: selectedStatus.toLowerCase(),
          );
        }
      }
    });
  }

  Future<void> fetchMyProperties() async {
    await context.read<FetchMyPropertiesCubit>().fetchMyProperties(
      type: selectedType.toLowerCase(),
      status: selectedStatus.toLowerCase(),
    );
  }

  String statusText(String text) {
    if (text == '1') {
      return 'active'.translate(context);
    } else if (text == '0') {
      return 'inactive'.translate(context);
    } else if (text == 'rejected') {
      return 'rejected'.translate(context);
    } else if (text == 'pending') {
      return 'pending'.translate(context);
    }
    return '';
  }

  Color statusColor(String text) {
    if (text == '1') {
      return Colors.green;
    } else if (text == '0') {
      return Colors.orangeAccent;
    } else if (text == 'rejected') {
      return Colors.redAccent;
    } else if (text == 'pending') {
      return Colors.blue;
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.backgroundColor,
        appBar: CustomAppBar(
          title: 'myProperty'.translate(context),
          isFromHome: true,
          showBackButton: false,
          actions: [
            GestureDetector(
              onTap: showFilters,
              child: Container(
                margin: const EdgeInsetsDirectional.only(end: 8, bottom: 4),
                height: 40.rh(context),
                width: 40.rw(context),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: context.color.borderColor,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                alignment: Alignment.center,
                padding: EdgeInsets.all(4.rw(context)),
                child: CustomImage(
                  imageUrl: AppIcons.filter,
                  color: context.color.textColorDark,
                  width: 24.rw(context),
                  height: 24.rh(context),
                ),
              ),
            ),
          ],
        ),
        body: CustomRefreshIndicator(
          onRefresh: () async {
            await fetchMyProperties();
          },
          child: BlocBuilder<FetchMyPropertiesCubit, FetchMyPropertiesState>(
            builder: (context, state) {
              if (state is FetchMyPropertiesInProgress) {
                return UiUtils.buildHorizontalShimmer(context);
              }
              if (state is FetchMyPropertiesFailure) {
                return SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.7,
                  width: MediaQuery.sizeOf(context).width,
                  child: Center(
                    child: SomethingWentWrong(
                      errorMessage: state.errorMessage.toString(),
                    ),
                  ),
                );
              }
              if (state is FetchMyPropertiesSuccess &&
                  state.myProperty.isEmpty) {
                return NoDataFound(
                  title: 'noPropertyAdded'.translate(context),
                  description: 'noPropertyAddedDescription'.translate(context),
                  onTapRetry: fetchMyProperties,
                  showMainButton: true,
                  mainButtonTitle: 'ddPropertyLbl'.translate(context),
                  onTapMainButton: _navigateToAddProperty,
                );
              }
              if (state is FetchMyPropertiesSuccess &&
                  state.myProperty.isNotEmpty) {
                if (ResponsiveHelper.isLargeTablet(context) ||
                    ResponsiveHelper.isTablet(context)) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 130.rh(context),
                    ),
                    physics: Constant.scrollPhysics,
                    controller: controller,
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                      horizontal: 16,
                    ),
                    itemCount:
                        state.myProperty.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.myProperty.length) {
                        if (state.isLoadingMore) {
                          return Center(
                            child: UiUtils.progress(
                              height: 30.rh(context),
                              width: 30.rw(context),
                            ),
                          );
                        }
                        return const SizedBox();
                      }
                      final property = state.myProperty[index];
                      final status =
                          property.requestStatus.toString() == 'approved'
                          ? property.status.toString()
                          : property.requestStatus.toString();
                      return BlocProvider(
                        create: (context) => AddToFavoriteCubitCubit(),
                        child: PropertyHorizontalCard(
                          property: property,
                          showLikeButton: false,
                          statusButton: StatusButton(
                            lable: statusText(status),
                            color: statusColor(status).withValues(alpha: 0.2),
                            textColor: statusColor(status),
                          ),
                          // useRow: true,
                        ),
                      );
                    },
                  );
                } else {
                  return ListView.separated(
                    separatorBuilder: (context, index) => const SizedBox(
                      height: 8,
                    ),
                    physics: Constant.scrollPhysics,
                    controller: controller,
                    padding: const EdgeInsets.all(16),
                    itemCount:
                        state.myProperty.length + (state.isLoadingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.myProperty.length) {
                        if (state.isLoadingMore) {
                          return Center(
                            child: UiUtils.progress(
                              height: 30.rh(context),
                              width: 30.rw(context),
                            ),
                          );
                        }
                        return const SizedBox();
                      }
                      final property = state.myProperty[index];
                      final status =
                          property.requestStatus.toString() == 'approved'
                          ? property.status.toString()
                          : property.requestStatus.toString();
                      return BlocProvider(
                        create: (context) => AddToFavoriteCubitCubit(),
                        child: PropertyHorizontalCard(
                          property: property,
                          showLikeButton: false,
                          statusButton: StatusButton(
                            lable: statusText(status),
                            color: statusColor(status).withValues(alpha: 0.2),
                            textColor: statusColor(status),
                          ),
                        ),
                      );
                    },
                  );
                }
              }
              return SomethingWentWrong(
                errorMessage: 'somethingWentWrng'.translate(context),
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> showFilters() async {
    // Reset temporary selections to current values when opening filter
    tempSelectedType = selectedType;
    tempSelectedStatus = selectedStatus;
    await showModalBottomSheet<dynamic>(
      context: context,
      showDragHandle: true,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: context.color.secondaryColor,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              color: context.color.secondaryColor,
              width: MediaQuery.of(context).size.width,
              child: Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  CustomText(
                    'filterTitle'.translate(context),
                    color: context.color.inverseSurface,
                    fontWeight: .bold,
                    fontSize: context.font.xl,
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    'status'.translate(context),
                    color: context.color.inverseSurface,
                    fontWeight: .bold,
                    fontSize: context.font.md,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    runSpacing: 8,
                    children: [
                      buildFilterCheckbox(
                        'all'.translate(context),
                        tempSelectedStatus,
                        '',
                        FilterType.status,
                        setModalState,
                      ),
                      buildFilterCheckbox(
                        'approved'.translate(context),
                        tempSelectedStatus,
                        'approved',
                        FilterType.status,
                        setModalState,
                      ),
                      buildFilterCheckbox(
                        'rejected'.translate(context),
                        tempSelectedStatus,
                        'rejected',
                        FilterType.status,
                        setModalState,
                      ),
                      buildFilterCheckbox(
                        'pending'.translate(context),
                        tempSelectedStatus,
                        'pending',
                        FilterType.status,
                        setModalState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    'type'.translate(context),
                    color: context.color.inverseSurface,
                    fontWeight: .bold,
                    fontSize: context.font.md,
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    runSpacing: 8,
                    children: [
                      buildFilterCheckbox(
                        'all'.translate(context),
                        tempSelectedType,
                        '',
                        FilterType.propertyType,
                        setModalState,
                      ),
                      buildFilterCheckbox(
                        'sell'.translate(context),
                        tempSelectedType,
                        'sell',
                        FilterType.propertyType,
                        setModalState,
                      ),
                      buildFilterCheckbox(
                        'rent'.translate(context),
                        tempSelectedType,
                        'rent',
                        FilterType.propertyType,
                        setModalState,
                      ),
                      buildFilterCheckbox(
                        'sold'.translate(context),
                        tempSelectedType,
                        'sold',
                        FilterType.propertyType,
                        setModalState,
                      ),
                      buildFilterCheckbox(
                        'rented'.translate(context),
                        tempSelectedType,
                        'rented',
                        FilterType.propertyType,
                        setModalState,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  UiUtils.buildButton(
                    context,
                    onPressed: () async {
                      // Apply the temporary selections
                      setState(() {
                        selectedType = tempSelectedType;
                        selectedStatus = tempSelectedStatus;
                      });
                      // Close the modal
                      Navigator.pop(context);
                      // Fetch properties with new filters
                      await fetchMyProperties();
                    },
                    height: 48.rh(context),
                    buttonTitle: 'applyFilter'.translate(context),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _navigateToAddProperty() async {
    await GuestChecker.check(
      onNotGuest: () async {
        unawaited(Widgets.showLoader(context));
        final checkPackage = CheckPackage();

        final packageAvailable = await checkPackage.checkPackageAvailable(
          packageType: PackageType.propertyList,
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
              await _showCompleteProfileDialog();
            } else if (AppSettings.isVerificationRequired &&
                context.read<FetchSystemSettingsCubit>().getSetting(
                      SystemSetting.verificationStatus,
                    ) !=
                    'success') {
              await _showVerificationRequiredDialog();
            } else {
              await _navigateToAddScreen();
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
            dialog: const BlurredSubscriptionDialogBox(
              packageType: SubscriptionPackageType.propertyList,
              isAcceptContainesPush: true,
            ),
          );
        }
      },
    );
  }

  /// Navigates to add property/project screen
  Future<void> _navigateToAddScreen() async {
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
      arguments: {'type': PropertyAddType.property},
    );

    Widgets.hideLoder(context);
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

  Widget buildFilterCheckbox(
    String title,
    String currentValue,
    String optionValue,
    FilterType filterType,
    StateSetter setModalState,
  ) {
    final isSelected = currentValue.toLowerCase() == optionValue.toLowerCase();

    return GestureDetector(
      onTap: () {
        setModalState(() {
          switch (filterType) {
            case FilterType.status:
              tempSelectedStatus = optionValue.toLowerCase();
            case FilterType.propertyType:
              tempSelectedType = optionValue.toLowerCase();
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        margin: const EdgeInsetsDirectional.only(end: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: isSelected
                ? context.color.tertiaryColor
                : context.color.borderColor,
            width: isSelected ? 2 : 1,
          ),
          color: isSelected
              ? context.color.tertiaryColor
              : context.color.primaryColor,
        ),
        child: CustomText(
          title,
          color: isSelected
              ? context.color.buttonColor
              : context.color.inverseSurface,
          fontWeight: isSelected ? .bold : .w600,
        ),
      ),
    );
  }
}
