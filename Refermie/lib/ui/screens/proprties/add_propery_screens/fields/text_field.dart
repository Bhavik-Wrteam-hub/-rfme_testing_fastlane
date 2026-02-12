import 'package:ebroker/ui/screens/proprties/add_propery_screens/custom_fields/custom_field.dart';
import 'package:ebroker/ui/screens/widgets/custom_text_form_field.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class CustomTextField extends CustomField<dynamic> {
  TextEditingController? controller;

  @override
  void init() {
    id = data['id'];
    controller = TextEditingController(text: data['value']?.toString() ?? '');
    super.init();
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget render(BuildContext context) {
    return Column(
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
        CustomTextFormField(
          hintText: 'writeSomething'.translate(context),
          action: .next,
          validator: CustomTextFieldValidator.nullCheck,
          controller: controller,
          onChange: (value) {},
        ),
      ],
    );
  }

  @override
  String type = 'textbox';

  @override
  String? backValue() {
    return controller?.text;
  }
}
