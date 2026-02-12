import 'package:ebroker/data/model/appointment/agent_time_schedule_model.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/appointment_card_container.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/appointment_helper.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class ViewScheduleDialog extends StatefulWidget {
  const ViewScheduleDialog({
    required this.title,
    required this.slots,
    required this.dayName,
    super.key,
  });
  final String title;
  final List<ExtraSlot> slots;
  final String dayName;
  @override
  State<ViewScheduleDialog> createState() => _ViewScheduleDialogState();
}

class _ViewScheduleDialogState extends State<ViewScheduleDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.rw(context)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: context.color.primaryColor,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.color.primaryColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .start,
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  margin: const EdgeInsetsDirectional.only(end: 12),
                  decoration: BoxDecoration(
                    shape: .circle,
                    color: context.color.textColorDark.withValues(alpha: 0.1),
                  ),
                  child: CustomImage(
                    imageUrl: AppIcons.calendar,
                    color: context.color.textColorDark,
                    fit: .contain,
                    width: 20.rw(context),
                    height: 20.rh(context),
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      CustomText(
                        widget.dayName.translate(context),
                        fontSize: context.font.md,
                        fontWeight: .w600,
                      ),
                      const SizedBox(height: 4),
                      CustomText(
                        widget.title,
                        fontSize: context.font.xs,
                        fontWeight: .w500,
                      ),
                    ],
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
            _buildSlots(),
          ],
        ),
      ),
    );
  }

  Widget _buildSlots() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          'dateScheduleTimeSlots'.translate(context),
          fontSize: context.font.md,
          fontWeight: .w600,
        ),
        const SizedBox(height: 12),
        UiUtils.getDivider(context),
        const SizedBox(height: 16),
        SizedBox(
          height: _calculateGridViewHeight(),
          child: GridView.builder(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 36.rh(context),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
            ),
            itemCount: widget.slots.length,
            itemBuilder: (context, index) => AppointmentCardContainer(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  CustomImage(
                    imageUrl: AppIcons.clock,
                    width: 18.rw(context),
                    height: 18.rh(context),
                    color: context.color.textColorDark,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: CustomText(
                      '${AppointmentHelper.formatTimeToAmPm(
                        widget.slots[index].startTime,
                      )} - ${AppointmentHelper.formatTimeToAmPm(
                        widget.slots[index].endTime,
                      )}',
                      fontSize: context.font.xs,
                      fontWeight: .w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _calculateGridViewHeight() {
    const crossAxisCount = 2;
    const mainAxisExtent = 36.0;
    const mainAxisSpacing = 16.0;

    final rowCount = (widget.slots.length / crossAxisCount).ceil();
    return (rowCount * mainAxisExtent) + ((rowCount - 1) * mainAxisSpacing);
  }
}
