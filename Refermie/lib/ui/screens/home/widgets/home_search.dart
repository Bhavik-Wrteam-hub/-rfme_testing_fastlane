import 'package:ebroker/app/routes.dart';
import 'package:ebroker/ui/screens/widgets/custom_text_form_field.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class HomeSearchField extends StatelessWidget {
  const HomeSearchField({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        right: 18,
        left: 18,
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              behavior: .translucent,
              onTap: () async {
                await Navigator.pushNamed(
                  context,
                  Routes.searchScreenRoute,
                  arguments: {'autoFocus': true},
                );
              },
              child: AbsorbPointer(
                child: Container(
                  width: (MediaQuery.of(context).size.width - 102).rw(context),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    color: context.color.secondaryColor,
                  ),
                  child: CustomTextFormField(
                    isReadOnly: true,
                    fillColor: Theme.of(context).colorScheme.secondaryColor,
                    hintText: 'searchHintLbl'.translate(context),
                    prefix: buildSearchIcon(context),
                    onChange: (value) {
                      FocusScope.of(context).unfocus();
                    },
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 8.rw(context)),
          GestureDetector(
            onTap: () async {
              final hasInternet = await HelperUtils.checkInternet();
              if (!hasInternet) {
                return HelperUtils.showSnackBarMessage(
                  context,
                  'noInternet',
                  type: .error,
                );
              }
              await Navigator.pushNamed(context, Routes.propertyMapScreen);
            },
            child: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              width: 50.rw(context),
              height: 50.rh(context),
              decoration: BoxDecoration(
                border: Border.all(color: context.color.borderColor),
                color: context.color.secondaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomImage(
                imageUrl: AppIcons.propertyMap,
                color: context.color.tertiaryColor,
                width: 24.rw(context),
                height: 24.rh(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSearchIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: CustomImage(
        imageUrl: AppIcons.search,
        width: 24.rw(context),
        height: 24.rh(context),
        color: context.color.tertiaryColor,
      ),
    );
  }
}
