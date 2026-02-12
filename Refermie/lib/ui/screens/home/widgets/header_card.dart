import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class TitleHeader extends StatelessWidget {
  const TitleHeader({
    required this.title,
    super.key,
    this.onSeeAll,
    this.enableShowAll,
  });

  final String title;
  final VoidCallback? onSeeAll;
  final bool? enableShowAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 20,
        bottom: 16,
        start: 18,
        end: 18,
      ),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Expanded(
            child: CustomText(
              title,
              fontWeight: .w700,
              fontSize: context.font.md,
              color: context.color.textColorDark,
              maxLines: 1,
            ),
          ),
          if (enableShowAll ?? true)
            GestureDetector(
              onTap: () {
                onSeeAll?.call();
              },
              child: CustomText(
                'seeAll'.translate(context),
                fontWeight: .w400,
                fontSize: context.font.xs,
                color: context.color.textLightColor,
              ),
            ),
        ],
      ),
    );
  }
}
