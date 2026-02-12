import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class CustomRadioField extends CustomField<dynamic> {
  @override
  String type = 'radiobutton';
  String? selectedRadioValue;
  List<dynamic> translatedValues = [];
  @override
  String? backValue() {
    return selectedRadioValue;
  }

  @override
  void init() {
    id = data['id'];

    translatedValues =
        (data['translated_option_value'] as List<dynamic>?) ?? [];

    selectedRadioValue =
        data['value']?.toString() ??
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
            SizedBox(
              width: 10.rw(context),
            ),
            Flexible(
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
        Wrap(
          children: List.generate(translatedValues.length, (index) {
            final valueName =
                translatedValues[index]['translated']?.toString() ??
                translatedValues[index]['value']?.toString() ??
                '';
            return Padding(
              padding: EdgeInsetsDirectional.only(
                start: index == 0 ? 0 : 4,
                end: 4,
                bottom: 4,
                top: 4,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  selectedRadioValue =
                      translatedValues[index]['value']?.toString() ?? '';
                  update(() {});
                },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: context.color.borderColor),
                    color:
                        selectedRadioValue ==
                            translatedValues[index]['value']?.toString()
                        ? context.color.tertiaryColor.withValues(alpha: 0.1)
                        : context.color.secondaryColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    child: CustomText(
                      valueName,
                      color:
                          selectedRadioValue ==
                              translatedValues[index]['value']?.toString()
                          ? context.color.tertiaryColor
                          : context.color.textLightColor,
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
