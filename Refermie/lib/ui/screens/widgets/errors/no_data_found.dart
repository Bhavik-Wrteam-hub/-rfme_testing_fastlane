import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class NoDataFound extends StatelessWidget {
  const NoDataFound({
    required this.onTapRetry,
    required this.title,
    required this.description,
    super.key,
    this.onTapMainButton,
    this.height,
    this.mainButtonTitle,
    this.showMainButton,
    this.showRetryButton = true,
  });

  final double? height;

  final VoidCallback onTapRetry;
  final VoidCallback? onTapMainButton;

  final String title;
  final String description;
  final String? mainButtonTitle;
  final bool? showMainButton;
  final bool showRetryButton;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: .min,
        mainAxisAlignment: .center,
        children: [
          SizedBox(
            child: CustomImage(
              imageUrl: AppIcons.noDataFound,
              height: height ?? MediaQuery.of(context).size.height * 0.35,
            ),
          ),
          const SizedBox(height: 16),
          CustomText(
            title,
            fontWeight: .w600,
            fontSize: context.font.xl,
            textAlign: .center,
            color: context.color.tertiaryColor,
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: CustomText(
              description,
              textAlign: .center,
              fontSize: context.font.md,
            ),
          ),
          const SizedBox(height: 48),
          if (showMainButton ?? false)
            UiUtils.buildButton(
              context,
              outerPadding: const EdgeInsets.symmetric(horizontal: 20),
              onPressed: onTapMainButton ?? () {},
              buttonTitle: mainButtonTitle ?? '',
              height: 48.rh(context),
              showElevation: false,
            ),
          const SizedBox(height: 8),
          if (showRetryButton)
            UiUtils.buildButton(
              context,
              outerPadding: const EdgeInsets.symmetric(horizontal: 20),
              onPressed: onTapRetry,
              buttonTitle: 'retry'.translate(context),
              buttonColor: Colors.transparent,
              height: 48.rh(context),
              textColor: context.color.tertiaryColor,
              showElevation: false,
            ),
        ],
      ),
    );
  }
}
