import 'dart:convert';

import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class CheckboxField extends CustomField<dynamic> {
  List<dynamic> checkedValues = [];
  List<dynamic> translatedValues = [];
  @override
  String type = 'checkbox';
  String backValues = '';

  @override
  String backValue() {
    return backValues;
  }

  @override
  void init() {
    id = data['id'];
    translatedValues =
        (data['translated_option_value'] as List<dynamic>?) ?? [];
    if (data['value'] != null) {
      final selectedValue = data['value'].toString().split(',');
      checkedValues = selectedValue;
    }
    final dataMap = checkedValues.fold(
      <String, dynamic>{},
      (previousValue, element) =>
          previousValue..addAll({'${previousValue.length}': element}),
    );

    backValues = json.encode(dataMap);
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
            Flexible(
              child: CustomText(
                data['name']?.toString() ?? '',
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
          children: List.generate(
            translatedValues.length,
            (index) {
              final valueName =
                  translatedValues[index]['translated']?.toString() ??
                  translatedValues[index]['value']?.toString() ??
                  '';

              return Padding(
                padding: const EdgeInsetsDirectional.all(4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () {
                    if (checkedValues.contains(
                      translatedValues[index]['value'],
                    )) {
                      checkedValues.remove(translatedValues[index]['value']);
                    } else {
                      checkedValues.add(translatedValues[index]['value']);
                    }

                    final dataMap = checkedValues.fold(
                      <String, dynamic>{},
                      (previousValue, element) =>
                          previousValue
                            ..addAll({'${previousValue.length}': element}),
                    );

                    backValues = json.encode(dataMap);

                    update(() {});
                    // AbstractField.fieldsData
                    //     .addAll({widget.parameters['id']: json.encode(temp)});
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: context.color.borderColor),
                      color:
                          checkedValues.contains(
                            translatedValues[index]['value'],
                          )
                          ? context.color.tertiaryColor.withValues(alpha: 0.1)
                          : context.color.secondaryColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 14,
                      ),
                      child: Row(
                        mainAxisSize: .min,
                        children: [
                          Icon(
                            checkedValues.contains(
                                  translatedValues[index]['value'],
                                )
                                ? Icons.done
                                : Icons.add,
                            color:
                                checkedValues.contains(
                                  translatedValues[index]['value'],
                                )
                                ? context.color.tertiaryColor
                                : context.color.textColorDark,
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(
                            child: CustomText(
                              valueName,
                              color:
                                  checkedValues.contains(
                                    translatedValues[index]['value'],
                                  )
                                  ? context.color.tertiaryColor
                                  : context.color.textLightColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
