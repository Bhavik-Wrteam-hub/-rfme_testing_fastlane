import 'package:ebroker/exports/main_export.dart';
import 'package:url_launcher/url_launcher.dart' as urllauncher;

class PropertyParametersGrid extends StatelessWidget {
  const PropertyParametersGrid({
    required this.property,
    super.key,
  });
  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      width: double.infinity,
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
            'facilities'.translate(context),
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
            semanticChildCount: property.parameters?.length ?? 0,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              mainAxisExtent: 39.rh(context),
            ),
            itemCount: property.parameters?.length ?? 0,
            itemBuilder: (context, index) {
              final parameter = property.parameters![index];
              return _buildParameterItem(context, parameter);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildParameterItem(BuildContext context, Parameter parameter) {
    return Row(
      mainAxisSize: .min,
      crossAxisAlignment: .start,
      children: [
        _buildParameterIcon(context, parameter),
        SizedBox(width: 10.rw(context)),
        _buildParameterContent(context, parameter),
      ],
    );
  }

  Widget _buildParameterIcon(BuildContext context, Parameter parameter) {
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
      child: FittedBox(
        child: CustomImage(
          imageUrl: parameter.image?.toString() ?? '',
          width: 24.rw(context),
          height: 24.rh(context),
          color: context.color.textColorDark,
        ),
      ),
    );
  }

  Widget _buildParameterContent(BuildContext context, Parameter parameter) {
    return Expanded(
      child: Column(
        crossAxisAlignment: .start,
        mainAxisSize: .min,
        children: [
          CustomText(
            parameter.translatedName ?? parameter.name?.toString() ?? '',
            maxLines: 1,
            textAlign: .start,
            fontSize: context.font.xs,
            fontWeight: .w400,
            color: context.color.textColorDark,
          ),
          _buildParameterValue(context, parameter),
        ],
      ),
    );
  }

  Widget _buildParameterValue(BuildContext context, Parameter parameter) {
    if (parameter.typeOfParameter == 'file') {
      return GestureDetector(
        onTap: () async {
          await urllauncher.launchUrl(
            Uri.parse(parameter.value?.toString() ?? ''),
            mode: urllauncher.LaunchMode.externalApplication,
          );
        },
        child: CustomText(
          'viewFile'.translate(context),
          showUnderline: true,
          maxLines: 1,
          fontWeight: .w400,
          fontSize: context.font.sm,
          color: context.color.inverseSurface,
        ),
      );
    } else if (parameter.value is List) {
      return CustomText(
        (parameter.translatedValue ?? parameter.value as List? ?? []).join(
          ', ',
        ),
        fontWeight: .w400,
        maxLines: 1,
        fontSize: context.font.sm,
        color: context.color.inverseSurface,
      );
    } else if (parameter.typeOfParameter == 'textarea') {
      return CustomText(
        maxLines: 1,
        parameter.value?.toString() ?? '',
        fontWeight: .w400,
        fontSize: context.font.sm,
        color: context.color.inverseSurface,
      );
    } else {
      return CustomText(
        maxLines: 1,
        parameter.value?.toString() ?? '',
        fontWeight: .w400,
        fontSize: context.font.sm,
        color: context.color.inverseSurface,
      );
    }
  }
}
