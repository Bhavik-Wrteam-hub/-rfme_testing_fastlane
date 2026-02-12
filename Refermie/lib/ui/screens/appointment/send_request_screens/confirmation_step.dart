import 'package:ebroker/data/model/agent/agents_properties_models/customer_data.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/agents/cards/agent_property_card.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/appointment_widgets_export.dart';
import 'package:ebroker/ui/screens/appointment/send_request_screens/appointment_flow.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ConfirmationStep extends StatefulWidget {
  const ConfirmationStep({
    required this.appointmentData,
    required this.agentDetails,
    required this.onMessageChanged,
    required this.onChangePressed,
    this.isRescheduleMode = false,
    this.onReasonChanged,
    super.key,
  });

  final AppointmentData appointmentData;
  final CustomerData agentDetails;
  final ValueChanged<String> onMessageChanged;
  final VoidCallback onChangePressed;
  final bool isRescheduleMode;
  final ValueChanged<String>? onReasonChanged;

  @override
  State<ConfirmationStep> createState() => _ConfirmationStepState();
}

class _ConfirmationStepState extends State<ConfirmationStep> {
  final TextEditingController messageController = TextEditingController();
  final TextEditingController reasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    messageController.text = widget.appointmentData.message ?? '';
    reasonController.text = widget.appointmentData.reason ?? '';
  }

  @override
  void dispose() {
    reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _UserInfoCard(agentDetails: widget.agentDetails),
          const SizedBox(height: 16),
          if (widget.appointmentData.property != null)
            AgentPropertyCard(
              agentPropertiesData: widget.appointmentData.property!,
              isSelected: false,
              isSelectable: false,
            ),
          const SizedBox(height: 16),
          _AppointmentDetailsCard(
            appointmentData: widget.appointmentData,
            onChangePressed: widget.onChangePressed,
          ),
          const SizedBox(height: 16),
          if (widget.isRescheduleMode && widget.onReasonChanged != null)
            _ReasonField(
              reasonController: reasonController,
              onReasonChanged: widget.onReasonChanged!,
            ),
          if (!widget.isRescheduleMode || widget.onReasonChanged == null)
            _MessageField(
              messageController: messageController,
              onMessageChanged: widget.onMessageChanged,
            ),
        ],
      ),
    );
  }
}

class _UserInfoCard extends StatelessWidget {
  const _UserInfoCard({required this.agentDetails});

  final CustomerData agentDetails;

  @override
  Widget build(BuildContext context) {
    return AppointmentCardContainer(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            _UserAvatar(image: agentDetails.profile),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  _UserDetails(
                    name: agentDetails.name.firstUpperCase(),
                    email: agentDetails.email,
                  ),
                  if (agentDetails.isVerified ?? false) const _VerifiedBadge(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.image});

  final String image;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 64.rw(context),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(4),
        ),
        child: CustomImage(
          fit: .fill,
          imageUrl: image,
        ),
      ),
    );
  }
}

class _UserDetails extends StatelessWidget {
  const _UserDetails({required this.name, required this.email});

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        CustomText(
          name,
          color: context.color.textColorDark,
          fontSize: context.font.sm,
          fontWeight: .w500,
        ),
        const SizedBox(height: 4),
        CustomText(
          email,
          color: context.color.textLightColor,
          fontSize: context.font.xs,
        ),
        const SizedBox(height: 4),
      ],
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF0186D8).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: .min,
        children: [
          const Icon(Icons.verified, color: Color(0xFF0186D8), size: 16),
          const SizedBox(width: 4),
          CustomText(
            'verified'.translate(context),
            color: const Color(0xFF0186D8),
            fontSize: context.font.xs,
            fontWeight: .w500,
          ),
        ],
      ),
    );
  }
}

class _AppointmentDetailsCard extends StatelessWidget {
  const _AppointmentDetailsCard({
    required this.appointmentData,
    required this.onChangePressed,
  });

  final AppointmentData appointmentData;
  final VoidCallback onChangePressed;

  @override
  Widget build(BuildContext context) {
    return AppointmentCardContainer(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CustomText(
                  'meetingSchedule'.translate(context),
                  color: context.color.textColorDark,
                  fontSize: context.font.sm,
                  fontWeight: .w500,
                ),
                const Spacer(),
                GestureDetector(
                  onTap: onChangePressed,
                  child: Row(
                    children: [
                      CustomImage(
                        imageUrl: AppIcons.edit,
                        width: 20,
                        height: 20,
                        color: context.color.textColorDark,
                      ),
                      const SizedBox(width: 8),
                      CustomText(
                        'change'.translate(context),
                        color: context.color.textColorDark,
                        fontSize: context.font.sm,
                        fontWeight: .w500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          UiUtils.getDivider(context),
          const SizedBox(height: 16),
          _AppointmentDetailItem(
            icon: AppIcons.calendar,
            title: appointmentData.selectedDate != null
                ? DateFormat(
                    'MMM dd, yyyy',
                  ).format(appointmentData.selectedDate!)
                : '',
            subtitle: 'appointmentDate'.translate(context),
          ),
          const SizedBox(height: 16),
          _AppointmentDetailItem(
            icon: AppIcons.clock,
            title:
                appointmentData.selectedStartTime != null &&
                    appointmentData.selectedEndTime != null
                ? '${AppointmentHelper.formatTimeToAmPm(appointmentData.selectedStartTime!)} - ${AppointmentHelper.formatTimeToAmPm(appointmentData.selectedEndTime!)}'
                : '',
            subtitle: 'appointmentTime'.translate(context),
          ),
          const SizedBox(height: 16),
          _AppointmentDetailItem(
            icon: AppIcons.meeting,
            title: (appointmentData.meetingType == 'in_person')
                ? 'inPerson'.translate(context)
                : (appointmentData.meetingType == 'virtual')
                ? 'virtual'.translate(context)
                : (appointmentData.meetingType == 'phone')
                ? 'phone'.translate(context)
                : (appointmentData.meetingType ?? ''),
            subtitle: 'meetingType'.translate(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _AppointmentDetailItem extends StatelessWidget {
  const _AppointmentDetailItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final String icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.color.textColorDark.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: CustomImage(
              imageUrl: icon,
              width: 20,
              height: 20,
              color: context.color.textColorDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                CustomText(
                  title,
                  color: context.color.textColorDark,
                  fontSize: context.font.sm,
                  fontWeight: .w500,
                ),
                const SizedBox(height: 4),
                CustomText(
                  subtitle,
                  color: context.color.textLightColor,
                  fontSize: context.font.xs,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReasonField extends StatelessWidget {
  const _ReasonField({
    required this.reasonController,
    required this.onReasonChanged,
  });

  final TextEditingController reasonController;
  final ValueChanged<String> onReasonChanged;

  @override
  Widget build(BuildContext context) {
    return AppointmentCardContainer(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            CustomText(
              'reasonForRescheduling'.translate(context),
              color: context.color.textColorDark,
              fontSize: context.font.sm,
              fontWeight: .w500,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: reasonController,
              fillColor: context.color.primaryColor,
              maxLine: 3,
              hintText: 'writeReasonHere'.translate(context),
              autovalidate: AutovalidateMode.onUserInteraction,
              validator: CustomTextFieldValidator.nullCheck,
              onChange: (value) {
                onReasonChanged(value.toString());
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _MessageField extends StatelessWidget {
  const _MessageField({
    required this.messageController,
    required this.onMessageChanged,
  });

  final TextEditingController messageController;
  final ValueChanged<String> onMessageChanged;

  @override
  Widget build(BuildContext context) {
    return AppointmentCardContainer(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            CustomText(
              'messageOptional'.translate(context),
              color: context.color.textColorDark,
              fontSize: context.font.sm,
              fontWeight: .w500,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: messageController,
              fillColor: context.color.primaryColor,
              onChange: (value) {
                onMessageChanged(value.toString());
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
