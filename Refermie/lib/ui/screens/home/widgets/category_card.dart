import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    required this.frontSpacing,
    required this.onTapCategory,
    required this.category,
    super.key,
  });

  final bool? frontSpacing;
  final dynamic Function(Category category) onTapCategory;
  final Category category;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: frontSpacing ?? false ? 5.0 : 0,
      ),
      child: GestureDetector(
        onTap: () {
          onTapCategory.call(category);
        },
        child: Row(
          children: <Widget>[
            Container(
              constraints: BoxConstraints(
                minWidth: 100.rw(context),
                minHeight: 28.rh(context),
              ),
              padding: EdgeInsets.only(
                left: 8.rw(context),
                right: 8.rw(context),
                top: 4.rh(context),
                bottom: 4.rh(context),
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: context.color.secondaryColor,
                border: Border.all(color: context.color.borderColor),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisSize: .min,
                children: [
                  CustomImage(
                    imageUrl: category.image ?? '',
                    color: context.color.tertiaryColor,
                    width: 18.rw(context),
                    height: 18.rh(context),
                  ),
                  SizedBox(width: 12.rw(context)),
                  SizedBox(
                    child: CustomText(
                      category.translatedName ?? category.category ?? '',
                      textAlign: .center,
                      maxLines: 1,
                      fontWeight: .w400,
                      fontSize: context.font.sm,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
