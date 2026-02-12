import 'package:ebroker/data/cubits/property/fetch_compare_properties_cubit.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/widgets/sell_rent_label.dart';
import 'package:ebroker/ui/screens/widgets/like_button_widget.dart';
import 'package:ebroker/ui/screens/widgets/promoted_widget.dart';
import 'package:ebroker/utils/price_format.dart';

class PropertyCardBig extends StatelessWidget {
  const PropertyCardBig({
    required this.property,
    required this.isFromCompare,
    this.sourceProperty,
    super.key,
    this.isFirst,
    this.showEndPadding,
    this.showLikeButton,
    this.disableTap,
    this.showFeatured,
  });

  final PropertyModel property;
  final bool isFromCompare;
  final PropertyModel? sourceProperty;
  final bool? isFirst;
  final bool? showEndPadding;
  final bool? showLikeButton;
  final bool? disableTap;
  final bool? showFeatured;

  @override
  Widget build(BuildContext context) {
    final price = property.price!.priceFormat(
      enabled: Constant.isNumberWithSuffix,
      context: context,
    );
    final isPremium = property.isPremium ?? false;
    final isPromoted = property.promoted ?? false;
    final isAddedByMe = property.addedBy.toString() == HiveUtils.getUserId();
    final isRent = property.propertyType.toString().toLowerCase() == 'rent';
    return GestureDetector(
      onTap: () async {
        if (disableTap ?? false) return;

        final hasInternet = await HelperUtils.checkInternet();

        if (!hasInternet) {
          return HelperUtils.showSnackBarMessage(
            context,
            'noInternet',
            type: .error,
          );
        }

        try {
          if (isPremium) {
            await GuestChecker.check(
              onNotGuest: () async {
                unawaited(Widgets.showLoader(context));

                if (isAddedByMe) {
                  await _navigateToPropertyDetails(
                    context,
                    property.id!,
                    isAddedByMe,
                  );
                } else {
                  final checkPackage = CheckPackage();
                  final packageAvailable = await checkPackage
                      .checkPackageAvailable(
                        packageType: PackageType.premiumProperties,
                      );
                  if (packageAvailable) {
                    await _navigateToPropertyDetails(
                      context,
                      property.id!,
                      isAddedByMe,
                    );
                  } else {
                    Widgets.hideLoder(context);

                    await UiUtils.showBlurredDialoge(
                      context,
                      dialog: const BlurredSubscriptionDialogBox(
                        packageType: SubscriptionPackageType.premiumProperties,
                        isAcceptContainesPush: true,
                      ),
                    );
                  }
                }
              },
            );
          } else {
            unawaited(Widgets.showLoader(context));

            await _navigateToPropertyDetails(
              context,
              property.id!,
              isAddedByMe,
            );
          }
        } on Exception catch (_) {
          // Error handled in the finally block
        } finally {
          Widgets.hideLoder(context);
        }
      },
      child: Container(
        padding: EdgeInsets.all(8.rh(context)),
        width: 290.rw(context),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: context.color.secondaryColor,
          border: Border.all(
            color: context.color.borderColor,
          ),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: .start,
              mainAxisSize: .min,
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: CustomImage(
                        imageUrl: property.titleImage ?? '',
                        height: 132.rh(context),
                        width: double.infinity,
                        loadingImageHash: property.lowQualityTitleImage,
                      ),
                    ),
                    if (isPremium)
                      PositionedDirectional(
                        start: 10,
                        top: 10,
                        child: CustomImage(
                          imageUrl: AppIcons.premium,
                          height: 24.rh(context),
                          width: 24.rw(context),
                        ),
                      ),
                    if (isPromoted || (showFeatured ?? false))
                      const PositionedDirectional(
                        start: 10,
                        bottom: 10,
                        child: PromotedCard(),
                      ),
                  ],
                ),
                SizedBox(height: 8.rh(context)),
                Row(
                  children: [
                    CustomImage(
                      imageUrl: property.category?.image ?? '',
                      color: context.color.textLightColor,
                      width: 18.rw(context),
                      height: 18.rh(context),
                    ),
                    SizedBox(width: 4.rw(context)),
                    Expanded(
                      child: CustomText(
                        property.category?.translatedName ??
                            property.category?.category ??
                            '',
                        fontWeight: .w600,
                        fontSize: context.font.xs,
                        color: context.color.textLightColor,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.rh(context)),
                CustomText(
                  property.translatedTitle ?? property.title ?? '',
                  maxLines: 1,
                  fontSize: context.font.md,
                  fontWeight: .w600,
                  color: context.color.textColorDark,
                ),
                if (property.city != '') ...[
                  SizedBox(height: 8.rh(context)),
                  Row(
                    mainAxisSize: .min,
                    children: [
                      CustomImage(
                        imageUrl: AppIcons.location,
                        height: 18.rh(context),
                        width: 18.rw(context),
                        color: context.color.textLightColor,
                      ),
                      SizedBox(width: 5.rw(context)),
                      CustomText(
                        property.city ?? '',
                        maxLines: 1,
                        color: context.color.textLightColor,
                        fontSize: context.font.xs,
                        fontWeight: .w400,
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 8.rh(context)),
                UiUtils.getDivider(context),
                SizedBox(height: 8.rh(context)),
                Row(
                  crossAxisAlignment: .start,
                  children: [
                    Expanded(child: _buildPrice(context, price, isRent)),
                    SellRentLabel(
                      propertyType: isRent ? 'rent' : 'sell',
                    ),
                  ],
                ),
                if (isFromCompare) ...[
                  SizedBox(height: 8.rh(context)),
                  UiUtils.getDivider(context),
                  const Spacer(),
                  Row(
                    children: [
                      Expanded(
                        child: UiUtils.buildButton(
                          context,
                          onPressed: () async {
                            if (disableTap ?? false) return;
                            try {
                              if (isPremium) {
                                await GuestChecker.check(
                                  onNotGuest: () async {
                                    unawaited(Widgets.showLoader(context));

                                    if (isAddedByMe) {
                                      await _navigateToPropertyDetails(
                                        context,
                                        property.id!,
                                        isAddedByMe,
                                      );
                                    } else {
                                      final checkPackage = CheckPackage();
                                      final packageAvailable =
                                          await checkPackage
                                              .checkPackageAvailable(
                                                packageType: PackageType
                                                    .premiumProperties,
                                              );
                                      if (packageAvailable) {
                                        await _navigateToPropertyDetails(
                                          context,
                                          property.id!,
                                          isAddedByMe,
                                        );
                                      } else {
                                        Widgets.hideLoder(context);

                                        await UiUtils.showBlurredDialoge(
                                          context,
                                          dialog:
                                              const BlurredSubscriptionDialogBox(
                                                packageType:
                                                    SubscriptionPackageType
                                                        .premiumProperties,
                                                isAcceptContainesPush: true,
                                              ),
                                        );
                                      }
                                    }
                                  },
                                );
                              } else {
                                unawaited(Widgets.showLoader(context));

                                await _navigateToPropertyDetails(
                                  context,
                                  property.id!,
                                  isAddedByMe,
                                );
                              }
                            } finally {
                              Widgets.hideLoder(context);
                            }
                          },
                          buttonTitle: 'viewProperty'.translate(context),
                          buttonColor: context.color.secondaryColor,
                          border: BorderSide(
                            color: context.color.tertiaryColor,
                          ),
                          textColor: context.color.tertiaryColor,
                          fontSize: context.font.sm,
                          height: 44.rh(context),
                        ),
                      ),
                      SizedBox(
                        width: 8.rw(context),
                      ),
                      Expanded(
                        child: UiUtils.buildButton(
                          context,
                          onPressed: () async {
                            try {
                              unawaited(Widgets.showLoader(context));

                              // Get a property to compare with
                              final targetPropertyId = property.id!;

                              // Fetch comparison data using the cubit
                              final comparePropertiesCubit =
                                  FetchComparePropertiesCubit();
                              await comparePropertiesCubit
                                  .fetchCompareProperties(
                                    sourcePropertyId: sourceProperty!.id!,
                                    targetPropertyId: targetPropertyId,
                                  );

                              final state = comparePropertiesCubit.state;

                              if (state is FetchComparePropertiesSuccess) {
                                Widgets.hideLoder(context);
                                final sourcePropertyData = sourceProperty;

                                final targetPropertyData = property;

                                // Navigate to compare property screen with the fetched data
                                await Navigator.pushNamed(
                                  context,
                                  Routes.comparePropertiesScreen,
                                  arguments: {
                                    'comparisionData': state.comparisionData,
                                    'category': property.category,
                                    'isSourcePremium':
                                        sourcePropertyData
                                                ?.allPropData['is_premium']
                                            as bool?,
                                    'isTargetPremium':
                                        targetPropertyData
                                                .allPropData['is_premium']
                                            as bool? ??
                                        false,
                                    'isSourcePromoted':
                                        sourcePropertyData?.promoted ?? false,
                                    'isTargetPromoted':
                                        targetPropertyData.promoted ?? false,
                                  },
                                );
                              } else if (state
                                  is FetchComparePropertiesFailure) {
                                Widgets.hideLoder(context);
                                await UiUtils.showBlurredDialoge(
                                  context,
                                  dialog: const BlurredSubscriptionDialogBox(
                                    packageType: SubscriptionPackageType
                                        .premiumProperties,
                                  ),
                                );
                              } else {
                                Widgets.hideLoder(context);
                                HelperUtils.showSnackBarMessage(
                                  context,
                                  'somethingWentWrong',
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
                            } finally {
                              Widgets.hideLoder(context);
                            }
                          },
                          buttonTitle: 'compareProperty'.translate(context),
                          height: 44.rh(context),
                          fontSize: context.font.sm,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
            if (showLikeButton ?? true)
              PositionedDirectional(
                end: 18.rw(context),
                top: 116.rh(context),
                child: Container(
                  width: 32.rw(context),
                  height: 32.rh(context),
                  decoration: BoxDecoration(
                    color: context.color.secondaryColor,
                    shape: .circle,
                  ),
                  child: LikeButtonWidget(
                    propertyId: property.id!,
                    isFavourite: property.isFavourite == '1',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _navigateToPropertyDetails(
    BuildContext context,
    int propertyId,
    bool isMyProperty,
  ) async {
    // Store context reference to check if it's still mounted later
    final navigatorContext = context;

    final fetch = PropertyRepository();
    final dataOutput = await fetch.fetchPropertyFromPropertyId(
      id: propertyId,
      isMyProperty: isMyProperty,
    );

    Widgets.hideLoder(context);

    // Check if context is still valid before navigating
    if (navigatorContext.mounted) {
      await HelperUtils.goToNextPage(
        Routes.propertyDetails,
        navigatorContext,
        false,
        args: {
          'propertyData': dataOutput,
        },
      );
    }
  }

  Widget _buildPrice(BuildContext context, String price, bool isRent) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          price,
          fontWeight: .w500,
          fontSize: context.font.md,
          maxLines: 1,
          color: context.color.tertiaryColor,
        ),
        if (isRent) ...[
          SizedBox(width: 4.rw(context)),
          CustomText(
            '${isRent ? ' /' : ''}${property.rentduration?.toLowerCase().translate(context)}',
            fontWeight: .w500,
            maxLines: 1,
            fontSize: context.font.xxs,
            color: context.color.tertiaryColor,
          ),
        ],
      ],
    );
  }
}
