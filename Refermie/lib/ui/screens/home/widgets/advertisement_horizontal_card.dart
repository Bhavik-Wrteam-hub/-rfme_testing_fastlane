import 'package:ebroker/data/cubits/delete_advertisment_cubit.dart';
import 'package:ebroker/data/cubits/project/fetch_my_promoted_projects.dart';
import 'package:ebroker/data/cubits/property/fetch_my_promoted_propertys_cubit.dart';
import 'package:ebroker/data/model/advertisement_model.dart';
import 'package:ebroker/data/repositories/project_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/home/widgets/sell_rent_label.dart';
import 'package:ebroker/ui/screens/widgets/promoted_widget.dart';
import 'package:flutter/material.dart';

/// Base class for advertisement cards with common UI structure
abstract class BaseAdvertisementHorizontalCard extends StatelessWidget {
  const BaseAdvertisementHorizontalCard({
    super.key,
    this.statusButton,
    this.showDeleteButton,
    this.onDeleteTap,
    this.showLikeButton,
    this.isPromoted,
    this.isPremium,
  });

  final StatusButton? statusButton;
  final bool? showDeleteButton;
  final VoidCallback? onDeleteTap;
  final bool? showLikeButton;
  final bool? isPromoted;
  final bool? isPremium;

  // Abstract methods to be implemented by subclasses

  String get rentduration;

  String get advertisementId;

  String get itemId;

  String get titleImage;

  String get itemType;

  String get categoryImage;

  String get categoryName;

  String get price;

  String get title;

  String get city;

  String get status;

  // Abstract methods for actions
  void onCardTap(BuildContext context);

  void onShareAction(BuildContext context);

  void onDeleteSuccess(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.5),
      child: GestureDetector(
        onLongPress: () => onShareAction(context),
        onTap: () => onCardTap(context),
        child: Container(
          padding: const EdgeInsets.all(8),
          height: 126.rh(context),
          decoration: BoxDecoration(
            border: Border.all(
              color: context.color.borderColor,
            ),
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            fit: .expand,
            children: [
              Row(
                children: [
                  _buildImageSection(context),
                  SizedBox(width: 12.rw(context)),
                  _buildInfoSection(context),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CustomImage(
            imageUrl: titleImage,
            height: double.infinity,
            width: 124.rw(context),
          ),
        ),
        if (isPremium ?? false)
          PositionedDirectional(
            start: 4.rw(context),
            top: 4.rh(context),
            child: CustomImage(
              imageUrl: AppIcons.premium,
              height: 24.rh(context),
              width: 24.rw(context),
            ),
          ),
        if (isPromoted ?? false)
          PositionedDirectional(
            start: 4.rw(context),
            bottom: 4.rh(context),
            child: const PromotedCard(),
          ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              CustomImage(
                imageUrl: categoryImage,
                color: context.color.textLightColor,
                width: 18.rw(context),
                height: 18.rh(context),
              ),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: CustomText(
                  categoryName,
                  maxLines: 1,
                  fontWeight: .w400,
                  fontSize: context.font.xxs,
                  color: context.color.textLightColor,
                ),
              ),
              if (statusButton != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 2,
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusButton!.color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  height: 20.rh(context),
                  child: Center(
                    child: CustomText(
                      statusButton!.lable,
                      fontWeight: .bold,
                      fontSize: context.font.xxs,
                      color: statusButton?.textColor ?? Colors.black,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          // Title
          CustomText(
            title.firstUpperCase(),
            maxLines: 1,
            fontSize: context.font.sm,
            color: context.color.textColorDark,
          ),
          const SizedBox(height: 4),
          // City
          if (city != '')
            Row(
              children: [
                CustomImage(
                  imageUrl: AppIcons.location,
                  width: 18.rw(context),
                  height: 18.rh(context),
                  color: context.color.textLightColor,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: CustomText(
                    city.trim(),
                    maxLines: 1,
                    fontSize: context.font.xs,
                    fontWeight: .w500,
                    color: context.color.textLightColor,
                  ),
                ),
              ],
            ),
          // Divider
          const SizedBox(height: 6),
          UiUtils.getDivider(context),
          const SizedBox(height: 6),
          // Price & Type
          if (itemType.toLowerCase() == 'rent' ||
              itemType.toLowerCase() == 'sell')
            Row(
              children: [
                Expanded(
                  child: _buildPrice(
                    context,
                    price,
                    itemType.toLowerCase() == 'rent',
                  ),
                ),
                SellRentLabel(
                  propertyType: itemType.toLowerCase() == 'rent'
                      ? 'rent'
                      : 'sell',
                ),
                if (showDeleteButton ?? false) const SizedBox(width: 4),
                if (showDeleteButton ?? false) _buildDeleteButton(context),
              ],
            )
          else
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                CustomText(
                  itemType.toLowerCase().translate(context),
                  fontWeight: .w600,
                  fontSize: context.font.xs,
                  color: context.color.tertiaryColor,
                ),
                if (showDeleteButton ?? false) _buildDeleteButton(context),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPrice(BuildContext context, String price, bool isRent) {
    return Row(
      crossAxisAlignment: .end,
      children: [
        Flexible(
          child: CustomText(
            price +
                (isRent
                    ? ' / ${rentduration.toLowerCase().translate(context)}'
                    : ''),
            fontWeight: .w600,
            maxLines: 1,
            fontSize: context.font.sm,
            color: context.color.tertiaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return BlocConsumer<DeleteAdvertismentCubit, DeleteAdvertismentState>(
      listener: (context, state) {
        if (state is DeleteAdvertismentSuccess) {
          onDeleteSuccess(context);
        }
      },
      builder: (BuildContext context, DeleteAdvertismentState state) {
        if (status != '1') {
          return const SizedBox.shrink();
        }
        return GestureDetector(
          onTap: () async {
            await UiUtils.showBlurredDialoge(
              context,
              dialog: BlurredDialogBox(
                title: 'deleteBtnLbl'.translate(context),
                onAccept: () async {
                  if (Constant.isDemoModeOn) {
                    HelperUtils.showSnackBarMessage(
                      context,
                      'thisActionNotValidDemo',
                    );
                  } else {
                    await context.read<DeleteAdvertismentCubit>().delete(
                      advertisementId,
                    );
                  }
                },
                content: CustomText(
                  'confirmDeleteAdvert'.translate(context),
                ),
              ),
            );
          },
          child: Container(
            width: 24.rw(context),
            height: 24.rh(context),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: context.color.error.withValues(alpha: 0.1),
              shape: .circle,
            ),
            child: (state is DeleteAdvertismentInProgress)
                ? UiUtils.progress()
                : CustomImage(
                    imageUrl: AppIcons.delete,
                    color: context.color.error,
                  ),
          ),
        );
      },
    );
  }
}

/// Advertisement Card For Property
class MyAdvertisementPropertyHorizontalCard
    extends BaseAdvertisementHorizontalCard {
  const MyAdvertisementPropertyHorizontalCard({
    required this.advertisement,
    required this.isPropertyPromoted,
    required this.isPropertyPremium,
    super.key,
    super.statusButton,
    super.showDeleteButton,
    super.onDeleteTap,
    super.showLikeButton,
  });

  final AdvertisementProperty? advertisement;
  final bool isPropertyPromoted;
  final bool isPropertyPremium;

  @override
  String get rentduration => advertisement?.property.rentduration ?? '';

  @override
  String get advertisementId => advertisement?.id.toString() ?? '';

  @override
  String get itemId => advertisement?.propertyId ?? '';

  @override
  String get titleImage => advertisement?.property.titleImage ?? '';

  @override
  String get itemType => advertisement?.property.propertyType ?? '';

  @override
  String get categoryImage => advertisement?.property.category?.image ?? '';

  @override
  String get categoryName => advertisement?.property.category?.category ?? '';

  @override
  String get price => advertisement?.property.price ?? '';

  @override
  String get title => advertisement?.property.title ?? '';

  @override
  String get city => advertisement?.property.city ?? '';

  @override
  String get status => advertisement?.status ?? '';

  @override
  bool get isPremium => isPropertyPremium;

  @override
  bool get isPromoted => isPropertyPromoted;

  @override
  Future<void> onShareAction(BuildContext context) async {
    await HelperUtils.share(
      context,
      advertisement?.property.slugId ?? '',
    );
  }

  @override
  Future<void> onCardTap(BuildContext context) async {
    final hasInternet = await HelperUtils.checkInternet();

    if (!hasInternet) {
      return HelperUtils.showSnackBarMessage(
        context,
        'noInternet',
        type: .error,
      );
    }
    try {
      unawaited(Widgets.showLoader(context));
      final fetch = PropertyRepository();
      final dataOutput = await fetch.fetchPropertyFromPropertyId(
        id: int.parse(advertisement?.propertyId ?? ''),
        isMyProperty: true,
      );
      Future.delayed(
        Duration.zero,
        () async {
          Widgets.hideLoder(context);
          await HelperUtils.goToNextPage(
            Routes.propertyDetails,
            context,
            false,
            args: {
              'propertyData': dataOutput,
              'fromMyProperty': false,
            },
          );
        },
      );
    } on Exception catch (_) {
      Widgets.hideLoder(context);
    }
  }

  @override
  void onDeleteSuccess(BuildContext context) {
    context.read<FetchMyPromotedPropertysCubit>().delete(
      advertisement?.id.toString() ?? '',
    );
  }
}

/// Advertisement Card For project
class MyAdvertisementProjectHorizontalCard
    extends BaseAdvertisementHorizontalCard {
  const MyAdvertisementProjectHorizontalCard({
    required this.advertisement,
    required this.isProjectPromoted,
    required this.isProjectPremium,
    super.key,
    super.statusButton,
    super.showDeleteButton,
    super.onDeleteTap,
    super.showLikeButton,
  });

  final AdvertisementProject? advertisement;
  final bool isProjectPromoted;
  final bool isProjectPremium;

  @override
  String get rentduration => '';

  @override
  String get advertisementId => advertisement?.id.toString() ?? '';

  @override
  String get itemId => advertisement?.projectId ?? '';

  @override
  String get titleImage => advertisement?.project.image ?? '';

  @override
  String get itemType => advertisement?.project.type ?? '';

  @override
  String get categoryImage => advertisement?.project.category?.image ?? '';

  @override
  String get categoryName => advertisement?.project.category?.category ?? '';

  @override
  String get price => '';

  @override
  String get title => advertisement?.project.title ?? '';

  @override
  String get city => advertisement?.project.city ?? '';

  @override
  String get status => advertisement?.status ?? '';

  @override
  bool get isPremium => isProjectPremium;

  @override
  bool get isPromoted => isProjectPromoted;

  @override
  Future<void> onShareAction(BuildContext context) async {
    await HelperUtils.share(
      context,
      advertisement?.project.slugId ?? '',
    );
  }

  @override
  Future<void> onCardTap(BuildContext context) async {
    final hasInternet = await HelperUtils.checkInternet();

    if (!hasInternet) {
      return HelperUtils.showSnackBarMessage(
        context,
        'noInternet',
        type: .error,
      );
    }
    try {
      unawaited(Widgets.showLoader(context));
      final projectRepository = ProjectRepository();
      final projectDetails = await projectRepository.getProjectDetails(
        context,
        id: int.parse(advertisement?.projectId ?? ''),
        isMyProject: true,
      );
      Future.delayed(
        Duration.zero,
        () async {
          Widgets.hideLoder(context);
          await HelperUtils.goToNextPage(
            Routes.projectDetailsScreen,
            context,
            false,
            args: {
              'project': projectDetails,
            },
          );
        },
      );
    } on Exception catch (_) {
      Widgets.hideLoder(context);
    }
  }

  @override
  void onDeleteSuccess(BuildContext context) {
    context.read<FetchMyPromotedProjectsCubit>().delete(
      advertisement?.id.toString() ?? '',
    );
  }
}
