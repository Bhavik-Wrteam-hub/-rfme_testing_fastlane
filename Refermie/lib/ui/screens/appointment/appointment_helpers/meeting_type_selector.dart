import 'package:ebroker/ui/screens/appointment/appointment_helpers/appointment_widgets_export.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class MeetingTypeSelector extends StatelessWidget {
  const MeetingTypeSelector({
    required this.meetingTypes,
    required this.selectedMeetingType,
    required this.onMeetingTypeChanged,
    super.key,
  });

  final List<String> meetingTypes;
  final String? selectedMeetingType;
  final ValueChanged<String?> onMeetingTypeChanged;

  @override
  Widget build(BuildContext context) {
    final normalized = meetingTypes
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    return AppointmentCardContainer(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomText(
              'selectMeetingType'.translate(context),
              color: context.color.textColorDark,
              fontSize: context.font.sm,
              fontWeight: .w500,
            ),
          ),
          UiUtils.getDivider(context),
          const SizedBox(height: 8),
          ...normalized.map((meetingType) {
            return MeetingTypeOption(
              type: meetingType,
              isSelected: selectedMeetingType == meetingType,
              onChanged: onMeetingTypeChanged,
            );
          }),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class MeetingTypeOption extends StatelessWidget {
  const MeetingTypeOption({
    required this.type,
    required this.isSelected,
    required this.onChanged,
    super.key,
  });

  final String type;
  final bool isSelected;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(type),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          border: Border.all(color: context.color.borderColor),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            CustomImage(
              imageUrl: type == 'in_person'
                  ? AppIcons.meeting
                  : type == 'virtual'
                  ? AppIcons.videoCall
                  : AppIcons.clock,
              height: 18,
              width: 18,
              color: context.color.textColorDark,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomText(
                type == 'in_person'
                    ? 'inPerson'.translate(context)
                    : type == 'virtual'
                    ? 'virtual'.translate(context)
                    : 'phone'.translate(context),
                color: context.color.textColorDark,
                fontSize: context.font.sm,
                fontWeight: .w400,
              ),
            ),
            RadioGroup(
              groupValue: isSelected ? type : null,
              onChanged: onChanged,
              child: Radio<String>(
                value: type,
                visualDensity: VisualDensity.compact,
                activeColor: context.color.tertiaryColor,
                materialTapTargetSize: .shrinkWrap,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
