import 'package:ebroker/ui/screens/appointment/appointment_helpers/appointment_card_container.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class RemoveScheduleWarning extends StatefulWidget {
  const RemoveScheduleWarning({super.key});

  @override
  State<RemoveScheduleWarning> createState() => _RemoveScheduleWarningState();
}

class _RemoveScheduleWarningState extends State<RemoveScheduleWarning> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: AppointmentCardContainer(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: .min,
          children: [
            Row(
              children: [
                CustomText(
                  'removeScheduleWarning'.translate(context),
                  color: context.color.textColorDark,
                  fontSize: context.font.sm,
                  fontWeight: .w500,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context, false),
                  child: CustomImage(
                    imageUrl: AppIcons.closeCircle,
                    color: context.color.textColorDark,
                    fit: .contain,
                    width: 24.rw(context),
                    height: 24.rh(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            UiUtils.getDivider(context),
            const SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: Color.lerp(
                  Colors.red,
                  context.color.secondaryColor,
                  0.9,
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: .circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: CustomImage(
                          imageUrl: AppIcons.warning,
                          color: Colors.white,
                          width: 14.rw(context),
                          height: 14.rh(context),
                          fit: .contain,
                        ),
                      ),
                      const SizedBox(width: 16),
                      CustomText(
                        'warning'.translate(context),
                        color: Colors.red,
                        fontSize: context.font.md,
                        fontWeight: .w500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomText(
                    'areYouSureYouWantToCancelThisSchedule'.translate(context),
                    color: context.color.textColorDark,
                    fontSize: context.font.sm,
                    fontWeight: .w500,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: UiUtils.buildButton(
                    context,
                    onPressed: () => Navigator.pop(context, false),
                    height: 48.rh(context),
                    showElevation: false,
                    fontSize: context.font.md,
                    buttonTitle: 'cancelLbl'.translate(context),
                    buttonColor: context.color.secondaryColor,
                    textColor: context.color.tertiaryColor,
                    border: BorderSide(color: context.color.tertiaryColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: UiUtils.buildButton(
                    context,
                    showElevation: false,
                    onPressed: () => Navigator.pop(context, true),
                    height: 48.rh(context),
                    fontSize: context.font.md,
                    buttonTitle:
                        '${'yes'.translate(context)}, ${'cancelLbl'.translate(context)}',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
