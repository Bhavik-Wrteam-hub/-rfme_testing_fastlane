import 'package:ebroker/ui/screens/widgets/custom_text_form_field.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class CancelDialog extends StatefulWidget {
  const CancelDialog({
    required this.onCancel,
    required this.reasonController,
    super.key,
  });
  final VoidCallback onCancel;
  final TextEditingController reasonController;
  @override
  State<CancelDialog> createState() => _CancelDialogState();
}

class _CancelDialogState extends State<CancelDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 22.rw(context)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: context.color.secondaryColor,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.8,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.color.secondaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Expanded(
                  child: CustomText(
                    'cancelAppointment'.translate(context),
                    fontWeight: .w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
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
                color: Colors.red.withValues(alpha: 0.1),
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
                        child: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.white,
                          size: 14.rw(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      CustomText(
                        'warning'.translate(context),
                        color: Colors.red,
                        fontSize: context.font.md,
                        fontWeight: .w500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  CustomText(
                    'areYouSureYouWantToCancel'.translate(context),
                    fontWeight: .w500,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            CustomText(
              'reasonForCancellation'.translate(context),
              fontSize: 14,
              fontWeight: .w500,
            ),
            const SizedBox(height: 8),
            CustomTextFormField(
              minLine: 5,
              maxLine: 8,
              controller: widget.reasonController,
              hintText: 'writeReasonHere'.translate(context),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                Expanded(
                  child: UiUtils.buildButton(
                    context,
                    onPressed: () => Navigator.of(context).pop(),
                    border: BorderSide(color: context.color.tertiaryColor),
                    buttonTitle: 'cancelLbl'.translate(context),
                    buttonColor: context.color.secondaryColor,
                    textColor: context.color.tertiaryColor,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: UiUtils.buildButton(
                    context,
                    onPressed: widget.onCancel,
                    buttonTitle: 'yes'.translate(context),
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
