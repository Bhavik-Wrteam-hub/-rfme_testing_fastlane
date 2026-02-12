import 'package:dio/dio.dart';
import 'package:ebroker/data/model/subscription_pacakage_model.dart';
import 'package:ebroker/data/repositories/subscription_repository.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/payment/in_app_purchase/in_app_purchase_manager.dart';
import 'package:ebroker/utils/price_format.dart';
import 'package:flutter/material.dart';

class SubscriptionPackageTile extends StatefulWidget {
  const SubscriptionPackageTile({
    required this.onTap,
    required this.package,
    required this.packageFeatures,
    super.key,
  });

  final SubscriptionPackageModel package;
  final List<AllFeature> packageFeatures;
  final VoidCallback onTap;

  @override
  State<SubscriptionPackageTile> createState() =>
      _SubscriptionPackageTileState();
}

class _SubscriptionPackageTileState extends State<SubscriptionPackageTile> {
  InAppPurchaseManager inAppPurchase = InAppPurchaseManager();
  MultipartFile? _bankReceiptFile;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 16),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          buildPackageTitle(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
              border: Border(
                left: BorderSide(
                  color: context.color.borderColor,
                ),
                right: BorderSide(
                  color: context.color.borderColor,
                ),
                bottom: BorderSide(
                  color: context.color.borderColor,
                ),
              ),
            ),
            child: Column(
              children: [
                packageFeaturesAndValidity(),
                buildSeparator(),
                buildPriceAndSubscribe(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String getDuration({required int duration, required BuildContext context}) {
    final days = duration ~/ 24;
    return '$days';
  }

  Widget buildPriceAndSubscribe() {
    final packageDuration = getDuration(
      duration: widget.package.duration,
      context: context,
    );
    final isUnderReview = widget.package.packageStatus == 'review';
    final isRejected = widget.package.packageStatus == 'rejected';
    return Column(
      children: [
        if (isUnderReview) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: .center,
            children: [
              const Icon(
                Icons.access_time,
                color: Colors.orangeAccent,
              ),
              const SizedBox(width: 4),
              CustomText(
                'adminVerificationPending'.translate(context),
                fontSize: context.font.sm,
                color: Colors.orangeAccent,
                fontWeight: .w500,
              ),
            ],
          ),
        ],
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          decoration: BoxDecoration(
            color: context.color.textColorDark.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              Column(
                mainAxisSize: .min,
                crossAxisAlignment: .start,
                children: [
                  CustomText(
                    widget.package.price == 0
                        ? 'free'.translate(context)
                        : widget.package.price.toString().priceFormat(
                            context: context,
                          ),
                    fontSize: context.font.lg,
                    color: context.color.textColorDark,
                    fontWeight: .bold,
                  ),
                  CustomText(
                    '$packageDuration ${packageDuration == '1' ? 'day'.translate(context) : 'days'.translate(context)}',
                    fontSize: context.font.md,
                    color: context.color.textColorDark,
                  ),
                ],
              ),
              const Spacer(),
              if (isUnderReview)
                UiUtils.buildButton(
                  context,
                  height: 32.rh(context),
                  autoWidth: true,
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      Routes.transactionHistory,
                    );
                  },
                  buttonTitle: 'view'.translate(context),
                )
              else if (isRejected)
                buildUploadReceiptButton(
                  transactionId: widget.package.paymentTransactionId ?? '',
                )
              else
                UiUtils.buildButton(
                  context,
                  height: 32.rh(context),
                  autoWidth: true,
                  onPressed: widget.onTap,
                  buttonTitle: 'subscribe'.translate(context),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildSeparator() {
    return Container(
      margin: const EdgeInsets.only(top: 18, bottom: 18),
      child: MySeparator(
        color: context.color.tertiaryColor.withValues(alpha: 0.7),
      ),
    );
  }

  Widget buildPackageTitle() {
    return Container(
      height: 48.rh(context),
      alignment: AlignmentDirectional.centerStart,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: context.color.brightness == .dark
            ? context.color.textColorDark.withValues(alpha: 0.1)
            : context.color.textColorDark,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(4),
          topRight: Radius.circular(4),
        ),
      ),
      child: CustomText(
        widget.package.translatedName ?? widget.package.name,
        fontSize: context.font.md,
        color: Colors.white,
        fontWeight: .w600,
      ),
    );
  }

  Widget packageFeaturesAndValidity() {
    return Column(
      children: [
        buildValidity(
          duration: widget.package.duration.toString(),
        ),
        const SizedBox(height: 18),
        buildPackageFeatures(
          packageFeatures: widget.packageFeatures,
          package: widget.package,
        ),
      ],
    );
  }

  Widget buildValidity({required String duration}) {
    final packageDuration = getDuration(
      duration: int.parse(duration),
      context: context,
    );
    return Row(
      children: [
        CustomImage(
          imageUrl: AppIcons.featureAvailable,
          height: 20.rh(context),
          width: 20.rw(context),
        ),
        const SizedBox(width: 8),
        CustomText(
          '${'validUntil'.translate(context)} $packageDuration ${packageDuration == '1' ? 'day'.translate(context) : 'days'.translate(context)}',
          fontSize: context.font.xs,
          color: context.color.textColorDark,
          fontWeight: .w500,
        ),
      ],
    );
  }

  Widget buildPackageFeatures({
    required List<AllFeature> packageFeatures,
    required SubscriptionPackageModel package,
  }) {
    return ListView.separated(
      shrinkWrap: true,
      separatorBuilder: (context, index) {
        return const SizedBox(height: 18);
      },
      physics: const NeverScrollableScrollPhysics(),
      itemCount: packageFeatures.length,
      itemBuilder: (context, index) {
        final allFeatures = packageFeatures[index];
        final includedFeatures = package.features
            .where((element) => element.id == allFeatures.id)
            .toList();
        // Check if we have matching features before accessing
        var getLimit = '';
        if (includedFeatures.isNotEmpty) {
          if (includedFeatures[0].limit?.toString() != '0') {
            getLimit =
                includedFeatures[0].limit?.toString() ??
                includedFeatures[0].limitType.toString();
          } else {
            getLimit = includedFeatures[0].limitType.name.translate(context);
          }
        }

        return Row(
          children: [
            CustomImage(
              imageUrl:
                  package.features.any(
                    (element) => element.id == allFeatures.id,
                  )
                  ? AppIcons.featureAvailable
                  : AppIcons.featureNotAvailable,
              height: 20.rh(context),
              width: 20.rw(context),
            ),
            const SizedBox(
              width: 8,
            ),
            CustomText(
              allFeatures.translatedName ?? allFeatures.name,
              fontSize: context.font.xs,
              color: context.color.textColorDark,
              fontWeight: .w500,
            ),
            const SizedBox(
              width: 8,
            ),
            if (getLimit != '')
              CustomText(
                ': ${getLimit.firstUpperCase()}',
                fontSize: context.font.xs,
                color: context.color.textColorDark,
                fontWeight: .w500,
              ),
          ],
        );
      },
    );
  }

  Widget buildUploadReceiptButton({
    required String transactionId,
  }) {
    return Flexible(
      child: UiUtils.buildButton(
        context,
        height: 32.rh(context),
        autoWidth: true,
        onPressed: () async {
          final filePickerResult = await FilePicker.platform.pickFiles(
            type: FileType.custom,
            allowedExtensions: [
              'jpeg',
              'png',
              'jpg',
              'pdf',
              'doc',
              'docx',
              'webp',
            ],
          );
          if (filePickerResult != null) {
            _bankReceiptFile = await MultipartFile.fromFile(
              filePickerResult.files.first.path!,
              filename: filePickerResult.files.first.path!.split('/').last,
            );
          }
          if (_bankReceiptFile == null) {
            HelperUtils.showSnackBarMessage(
              context,
              'pleaseUploadReceipt',
            );
            return;
          }
          try {
            final result = await SubscriptionRepository().uploadBankReceiptFile(
              paymentTransactionId: transactionId,
              file: _bankReceiptFile!,
            );
            if (result['error'] == false) {
              HelperUtils.showSnackBarMessage(
                context,
                'receiptUploaded',
              );
              await context
                  .read<FetchSubscriptionPackagesCubit>()
                  .fetchPackages();
            } else {
              HelperUtils.showSnackBarMessage(
                context,
                result['message'].toString(),
              );
            }
          } on Exception catch (e) {
            HelperUtils.showSnackBarMessage(
              context,
              e.toString(),
            );
          }
        },
        buttonTitle: 'reUploadReceipt'.translate(context),
      ),
    );
  }
}

class MySeparator extends StatelessWidget {
  const MySeparator({
    super.key,
    this.height = 1,
    this.color = Colors.grey,
    this.isShimmer = false,
  });
  final double height;
  final Color color;
  final bool isShimmer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final boxWidth = constraints.constrainWidth();
        const dashWidth = 10.0;
        final dashHeight = height;
        final dashCount = (boxWidth / (2 * dashWidth)).floor();
        return Flex(
          mainAxisAlignment: .spaceBetween,
          direction: .horizontal,
          children: List.generate(dashCount, (_) {
            return SizedBox(
              width: dashWidth,
              height: dashHeight,
              child: isShimmer
                  ? CustomShimmer(
                      height: dashHeight,
                      width: dashWidth,
                      borderRadius: 0,
                    )
                  : DecoratedBox(
                      decoration: BoxDecoration(color: color),
                    ),
            );
          }),
        );
      },
    );
  }
}
