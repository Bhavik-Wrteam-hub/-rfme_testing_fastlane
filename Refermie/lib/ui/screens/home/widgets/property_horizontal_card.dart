import 'package:ebroker/data/model/advertisement_model.dart';
import 'package:ebroker/data/repositories/check_package.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/widgets/sell_rent_label.dart';
import 'package:ebroker/ui/screens/widgets/like_button_widget.dart';
import 'package:ebroker/ui/screens/widgets/promoted_widget.dart';
import 'package:ebroker/utils/price_format.dart';

class PropertyHorizontalCard extends StatelessWidget {
  const PropertyHorizontalCard({
    required this.property,
    this.advertisement,
    this.properties,
    super.key,
    this.statusButton,
    this.showDeleteButton,
    this.showLikeButton,
    this.additionalImageWidth,
    this.isFromSearch,
    this.isFromMyProperty,
    this.disableTap,
    this.showFeatured,
  });

  final PropertyModel property;
  final AdvertisementProperty? advertisement;
  final List<PropertyModel>? properties;
  final StatusButton? statusButton;
  final bool? showDeleteButton;
  final double? additionalImageWidth;
  final bool? showLikeButton;
  final bool? isFromSearch;
  final bool? isFromMyProperty;
  final bool? disableTap;
  final bool? showFeatured;

  @override
  Widget build(BuildContext context) {
    final price = property.price!.priceFormat(
      enabled: Constant.isNumberWithSuffix,
      context: context,
    );

    final isPremium = property.allPropData['is_premium'] as bool? ?? false;
    final isPromoted = property.promoted ?? false;
    final isAddedByMe = property.addedBy.toString() == HiveUtils.getUserId();
    final isRent = property.propertyType.toString().toLowerCase() == 'rent';
    return BlocProvider(
      create: (context) => AddToFavoriteCubitCubit(),
      child: GestureDetector(
        onLongPress: () async {
          await HelperUtils.share(context, property.slugId ?? '');
        },
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
                          packageType:
                              SubscriptionPackageType.premiumProperties,
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
          height: 132.rh(context),
          decoration: BoxDecoration(
            border: Border.all(color: context.color.borderColor),
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: CustomImage(
                      imageUrl: property.titleImage ?? '',
                      height: double.infinity,
                      width: 127.rw(context),
                      loadingImageHash: property.lowQualityTitleImage,
                    ),
                  ),
                  if (isPremium)
                    PositionedDirectional(
                      start: 4.rw(context),
                      top: 4.rh(context),
                      child: CustomImage(
                        imageUrl: AppIcons.premium,
                        height: 24.rh(context),
                        width: 24.rw(context),
                      ),
                    ),
                  if (isPromoted)
                    PositionedDirectional(
                      start: 4.rw(context),
                      bottom: 4.rh(context),
                      child: const PromotedCard(),
                    ),
                ],
              ),
              SizedBox(width: 8.rw(context)),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    // Category
                    Row(
                      children: [
                        Container(
                          alignment: Alignment.center,
                          child: CustomImage(
                            imageUrl: property.category?.image ?? '',
                            color: context.color.textLightColor,
                            width: 18.rw(context),
                            height: 18.rh(context),
                          ),
                        ),
                        SizedBox(width: 4.rw(context)),
                        Expanded(
                          child: CustomText(
                            property.category?.translatedName ??
                                property.category?.category ??
                                '',
                            maxLines: 1,
                            fontWeight: .w500,
                            fontSize: context.font.xxs,
                            color: context.color.textLightColor,
                          ),
                        ),
                        // Like Button
                        if (showLikeButton ?? true)
                          LikeButtonWidget(
                            propertyId: property.id!,
                            isFavourite: property.isFavourite == '1',
                          ),
                        if (showLikeButton == false && statusButton == null)
                          SizedBox(height: 24.rh(context)),
                        if (statusButton != null)
                          Container(
                            height: 24.rh(context),
                            decoration: BoxDecoration(
                              color: statusButton!.color,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            child: Row(
                              mainAxisAlignment: .center,
                              children: [
                                Center(
                                  child: CustomText(
                                    statusButton!.lable,
                                    fontWeight: .bold,
                                    fontSize: context.font.xxs,
                                    color:
                                        statusButton?.textColor ??
                                        context.color.textColorDark,
                                  ),
                                ),
                                if (property.editReason != null &&
                                    property.editReason!.isNotEmpty) ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      await UiUtils.showBlurredDialoge(
                                        context,
                                        dialog: BlurredDialogBox(
                                          acceptTextColor:
                                              context.color.buttonColor,
                                          showCancleButton: false,
                                          title: 'editedByAdmin'.translate(
                                            context,
                                          ),
                                          content: CustomText(
                                            property.editReason ?? '',
                                          ),
                                        ),
                                      );
                                    },
                                    child: CustomImage(
                                      imageUrl: AppIcons.info,
                                      width: 18.rw(context),
                                      height: 18.rh(context),
                                      color: statusButton!.textColor,
                                    ),
                                  ),
                                ],
                                if (property.requestStatus.toString() ==
                                    'rejected') ...[
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () async {
                                      await UiUtils.showBlurredDialoge(
                                        context,
                                        dialog: BlurredDialogBox(
                                          acceptTextColor:
                                              context.color.buttonColor,
                                          showCancleButton: false,
                                          title: statusButton!.lable,
                                          content: CustomText(
                                            property.rejectReason?.reason
                                                    .toString() ??
                                                '',
                                          ),
                                        ),
                                      );
                                    },
                                    child: CustomImage(
                                      imageUrl: AppIcons.info,
                                      width: 18.rw(context),
                                      height: 18.rh(context),
                                      color: statusButton!.textColor,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 8.rh(context)),
                    // Title
                    CustomText(
                      property.translatedTitle ??
                          property.title?.firstUpperCase() ??
                          '',
                      maxLines: 1,
                      fontWeight: .w400,
                      fontSize: context.font.sm,
                      color: context.color.textColorDark,
                    ),
                    SizedBox(height: 4.rh(context)),
                    // City
                    if (property.city != '')
                      Row(
                        children: [
                          CustomImage(
                            imageUrl: AppIcons.location,
                            width: 18.rw(context),
                            height: 18.rh(context),
                            color: context.color.textLightColor,
                          ),
                          SizedBox(width: 4.rw(context)),
                          Expanded(
                            child: CustomText(
                              property.city?.trim() ?? '',
                              maxLines: 1,
                              fontSize: context.font.xs,
                              fontWeight: .w400,
                              color: context.color.textLightColor,
                            ),
                          ),
                        ],
                      ),
                    // Divider
                    SizedBox(height: 8.rh(context)),
                    UiUtils.getDivider(context),
                    SizedBox(height: 8.rh(context)),
                    // Price & Type
                    Row(
                      children: [
                        Expanded(child: _buildPrice(context, price, isRent)),
                        SellRentLabel(
                          propertyType: property.propertyType.toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _navigateToPropertyDetails(
    BuildContext context,
    int propertyId,
    bool isMyProperty,
  ) async {
    final fetch = PropertyRepository();
    final dataOutput = await fetch.fetchPropertyFromPropertyId(
      id: propertyId,
      isMyProperty: isMyProperty,
    );

    Widgets.hideLoder(context);

    Future.delayed(Duration.zero, () async {
      await HelperUtils.goToNextPage(
        Routes.propertyDetails,
        context,
        false,
        args: {'propertyData': dataOutput},
      );
    });
  }

  Widget _buildPrice(BuildContext context, String price, bool isRent) {
    return Row(
      crossAxisAlignment: .end,
      children: [
        Flexible(
          child: CustomText(
            price + (isRent ? ' /' : ''),
            fontWeight: .w500,
            fontSize: context.font.md,
            color: context.color.tertiaryColor,
            maxLines: 1,
          ),
        ),
        if (isRent) ...[
          SizedBox(width: 4.rw(context)),
          Flexible(
            child: CustomText(
              '${property.rentduration?.toLowerCase().translate(context)}',
              fontWeight: .w500,
              maxLines: 1,
              fontSize: context.font.xxs,
              color: context.color.tertiaryColor,
            ),
          ),
        ],
      ],
    );
  }
}

class StatusButton {
  StatusButton({required this.lable, required this.color, this.textColor});

  final String lable;
  final Color color;
  final Color? textColor;
}
