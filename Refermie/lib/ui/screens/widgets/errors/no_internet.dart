import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class NoInternet extends StatelessWidget {
  const NoInternet({super.key, this.onRetry});
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion(
      value: UiUtils.getSystemUiOverlayStyle(context: context),
      child: Scaffold(
        backgroundColor: context.color.secondaryColor,
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: .center,
            children: [
              SizedBox(
                child: CustomImage(
                  imageUrl: AppIcons.noInternet,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              CustomText(
                'noInternet'.translate(context),
                fontWeight: .w600,
                fontSize: context.font.xl,
                color: context.color.tertiaryColor,
              ),
              const SizedBox(
                height: 10,
              ),
              CustomText(
                'noInternetErrorMsg'.translate(context),
                textAlign: .center,
                maxLines: 5,
              ),
              const SizedBox(
                height: 5,
              ),
              TextButton(
                onPressed: onRetry,
                style: ButtonStyle(
                  overlayColor: WidgetStateProperty.all(
                    context.color.tertiaryColor.withValues(alpha: 0.2),
                  ),
                ),
                child: CustomText(
                  'retry'.translate(context),
                  color: context.color.tertiaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
