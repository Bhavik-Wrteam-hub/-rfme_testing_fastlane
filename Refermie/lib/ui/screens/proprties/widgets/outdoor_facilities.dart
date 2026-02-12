import 'package:ebroker/data/model/property_model.dart';
import 'package:ebroker/settings.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class OutdoorFacilityListWidget extends StatelessWidget {
  const OutdoorFacilityListWidget({
    required this.outdoorFacilityList,
    super.key,
  });
  final List<AssignedOutdoorFacility> outdoorFacilityList;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.color.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            'outdoorFacilities'.translate(context),
            fontSize: context.font.md,
            fontWeight: .w600,
            color: context.color.textColorDark,
          ),
          const SizedBox(height: 8),
          UiUtils.getDivider(context),
          const SizedBox(height: 8),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            semanticChildCount: outdoorFacilityList.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: 38.rh(context),
            ),
            itemCount: outdoorFacilityList.length,
            itemBuilder: (context, index) {
              final facility = outdoorFacilityList[index];
              return buildOutdoorFacilityItem(
                context,
                facility,
                AppSettings.distanceOption.translate(context),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildOutdoorFacilityItem(
    BuildContext context,
    AssignedOutdoorFacility facility,
    String distanceOption,
  ) {
    return Row(
      children: [
        buildFacilityImage(context, facility.image ?? ''),
        const SizedBox(width: 8),
        Flexible(
          child: buildFacilityNameAndDistance(
            context,
            facility.translatedName ?? facility.name ?? '',
            facility.distance ?? '',
            distanceOption.translate(context),
          ),
        ),
      ],
    );
  }

  Widget buildFacilityNameAndDistance(
    BuildContext context,
    String name,
    String distance,
    String distanceOption,
  ) {
    return Column(
      crossAxisAlignment: .start,
      mainAxisSize: .min,
      children: [
        CustomText(
          name,
          textAlign: .start,
          maxLines: 1,
          fontSize: context.font.xs,
          fontWeight: .w500,
          color: context.color.textColorDark,
        ),
        Row(
          children: [
            CustomText(
              '${distance != '0' ? distance : '<1'}  ',
              fontSize: context.font.sm,
              color: context.color.inverseSurface,
              fontWeight: .w500,
              maxLines: 1,
            ),
            CustomText(
              distanceOption.firstUpperCase(),
              fontSize: context.font.sm,
              color: context.color.inverseSurface,
              fontWeight: .w500,
              maxLines: 1,
            ),
          ],
        ),
      ],
    );
  }

  Widget buildFacilityImage(BuildContext context, String imageUrl) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.color.borderColor,
        ),
      ),
      alignment: Alignment.center,
      height: 36.rh(context),
      width: 36.rw(context),
      child: CustomImage(
        imageUrl: imageUrl,
        color: context.color.textColorDark,
        width: 24.rw(context),
        height: 24.rh(context),
      ),
    );
  }
}
