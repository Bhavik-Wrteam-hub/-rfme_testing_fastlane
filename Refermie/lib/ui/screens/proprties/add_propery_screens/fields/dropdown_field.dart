import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class CustomDropdownField extends CustomField<dynamic> {
  @override
  String type = 'dropdown';
  List<dynamic> translatedValues = [];

  dynamic value;
  @override
  dynamic backValue() {
    // Find the selected item and return its actual value for the API
    if (value == null) return null;

    for (final item in translatedValues) {
      final uniqueValue =
          item['id']?.toString() ??
          item['value']?.toString() ??
          translatedValues.indexOf(item).toString();
      if (uniqueValue == value) {
        return item['value']?.toString() ?? item['id']?.toString();
      }
    }
    return value;
  }

  @override
  void init() {
    id = data['id'];

    translatedValues =
        (data['translated_option_value'] as List<dynamic>?) ?? [];
    // Use the original value or id as the unique identifier, not the display name
    value =
        data['value'] ??
        translatedValues.first['id']?.toString() ??
        translatedValues.first['value']?.toString() ??
        '';
    super.init();
  }

  @override
  Widget render(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              width: 32.rw(context),
              height: 32.rh(context),
              decoration: BoxDecoration(
                color: context.color.tertiaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: CustomImage(
                imageUrl: data['image']?.toString() ?? '',
              ),
            ),
            SizedBox(width: 8.rw(context)),
            Expanded(
              child: CustomText(
                data['translated_name']?.toString() ??
                    data['name']?.toString() ??
                    '',
                fontWeight: .w400,
                fontSize: context.font.sm,
                color: context.color.textColorDark,
              ),
            ),
            if (data['is_required'] == 1) ...[
              const SizedBox(width: 4),
              CustomText('*', color: context.color.error),
            ],
          ],
        ),
        SizedBox(height: 8.rh(context)),
        Padding(
          padding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              color: context.color.secondaryColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: context.color.borderColor,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: SizedBox(
                width: double.infinity,
                child: DropdownButton(
                  value: value,
                  dropdownColor: context.color.secondaryColor,
                  isExpanded: true,
                  padding: const EdgeInsets.symmetric(vertical: 5),
                  icon: CustomImage(
                    imageUrl: AppIcons.downArrow,
                  ),
                  isDense: true,
                  borderRadius: BorderRadius.circular(4),
                  style: TextStyle(
                    color: context.color.textLightColor,
                    fontSize: context.font.md,
                  ),
                  underline: const SizedBox.shrink(),
                  items: List.generate(
                    translatedValues.length,
                    (index) {
                      final valueName =
                          translatedValues[index]['translated']?.toString() ??
                          translatedValues[index]['value']?.toString() ??
                          '';
                      // Use a unique identifier (id or index) as the value to avoid duplicates
                      final uniqueValue =
                          translatedValues[index]['id']?.toString() ??
                          translatedValues[index]['value']?.toString() ??
                          index.toString();
                      return DropdownMenuItem(
                        value: uniqueValue,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: CustomText(valueName),
                        ),
                      );
                    },
                  ),
                  onChanged: (v) {
                    value = v;
                    update(() {});
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
