// Country picker widget to encapsulate country selection functionality
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class CountryPickerWidget extends StatelessWidget {
  const CountryPickerWidget({
    required this.flagEmoji,
    required this.onTap,
    required this.countryCode,
    super.key,
  });
  final String? flagEmoji;
  final VoidCallback onTap;
  final String? countryCode;
  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: .scaleDown,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsetsDirectional.only(
            start: 10,
          ),
          height: 48.rh(context),
          alignment: Alignment.center,
          child: Row(
            children: [
              CustomText(
                flagEmoji ?? '',
                fontSize: context.font.xxl,
              ),
              const SizedBox(width: 4),
              CustomImage(
                imageUrl: AppIcons.downArrow,
                height: 16.rh(context),
                width: 16.rw(context),
                color: context.color.tertiaryColor,
              ),
              const SizedBox(width: 4),
              Container(
                height: 24.rh(context),
                width: 1,
                color: Colors.grey.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 4),
              CustomText(
                '+${countryCode ?? ''}',
                fontSize: context.font.md,
                color: context.color.textColorDark,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
