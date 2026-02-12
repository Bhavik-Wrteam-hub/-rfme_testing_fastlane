import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/price_format.dart';
import 'package:flutter/material.dart';

class PropertyHeader extends StatelessWidget {
  const PropertyHeader({
    required this.property,
    super.key,
  });

  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        const SizedBox(height: 12),
        _buildCategoryAndType(context),
        const SizedBox(height: 8),
        _buildTitleAndDate(context),
        const SizedBox(height: 6),
        _buildPrice(context),
      ],
    );
  }

  Widget _buildCategoryAndType(BuildContext context) {
    final statusColor =
        (property.propertyType.toString().toLowerCase() == 'sell' ||
                property.propertyType.toString().toLowerCase() == 'sold')
            ? Colors.blue
            : Colors.amber;
    return Row(
      children: [
        CustomImage(
          imageUrl: property.category?.image ?? '',
          width: 24.rw(context),
          height: 24.rh(context),
          color: context.color.textColorDark,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: CustomText(
            property.category?.translatedName ??
                property.category?.category ??
                '',
            fontWeight: .w500,
            fontSize: context.font.sm,
            color: context.color.textColorDark,
          ),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
          height: 28.rh(context),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            color: statusColor.withValues(alpha: 0.1),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Center(
              child: CustomText(
                property.propertyType
                    .toString()
                    .toLowerCase()
                    .translate(context),
                fontWeight: .w600,
                fontSize: context.font.sm,
                color: statusColor,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitleAndDate(BuildContext context) {
    return Row(
      mainAxisAlignment: .spaceBetween,
      children: [
        Expanded(
          child: CustomText(
            property.translatedTitle ?? property.title?.firstUpperCase() ?? '',
            fontWeight: .w800,
            fontSize: context.font.md,
            color: context.color.textColorDark,
          ),
        ),
        CustomText(
          property.postCreated ?? '',
          fontSize: context.font.xs,
          fontWeight: .w500,
          color: context.color.textColorDark,
        ),
      ],
    );
  }

  Widget _buildPrice(BuildContext context) {
    var priceText = property.price!.priceFormat(
      enabled: Constant.isNumberWithSuffix,
      context: context,
    );

    if (property.propertyType.toString().toLowerCase() == 'rent' &&
        property.rentduration != '' &&
        property.rentduration != null) {
      priceText =
          '$priceText / ${(property.rentduration ?? '').toLowerCase().translate(context)}';
    }

    return Row(
      children: [
        CustomText(
          priceText,
          fontWeight: .w700,
          fontSize: context.font.sm,
          color: context.color.tertiaryColor,
        ),
        if (Constant.isNumberWithSuffix &&
            property.propertyType.toString().toLowerCase() != 'rent') ...[
          const SizedBox(width: 5),
          CustomText(
            '(${property.price!.priceFormat(context: context, enabled: false)})',
            fontWeight: .w500,
            fontSize: context.font.sm,
            color: context.color.tertiaryColor,
          ),
        ],
      ],
    );
  }
}
