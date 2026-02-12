import 'dart:async';

import 'package:ebroker/data/cubits/appointment/get/fetch_agent_upcoming_appointments_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_user_upcoming_appointments_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/update_appointment_status_cubit.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/customer_data.dart';
import 'package:ebroker/data/model/appointment/appointment_model.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/appointment_details_bottom_sheet.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/cancel_dialog.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/change_meeting_type_dialog.dart';
import 'package:ebroker/ui/screens/appointment/send_request_screens/appointment_flow.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppointmentCard extends StatefulWidget {
  const AppointmentCard({
    required this.appointment,
    required this.isAgent,
    required this.isFromPreviousAppointments,
    super.key,
  });

  final AppointmentModel appointment;
  final bool isAgent;
  final bool isFromPreviousAppointments;
  @override
  State<AppointmentCard> createState() => _AppointmentCardState();
}

class _AppointmentCardState extends State<AppointmentCard> {
  bool _isAccepting = false;
  bool _isCancelling = false;
  final TextEditingController _reasonController = TextEditingController();

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.color.borderColor),
      ),
      child: Column(
        children: [
          _buildUserInfo(context, widget.appointment),
          const SizedBox(height: 10),
          UiUtils.getDivider(context),
          const SizedBox(height: 10),
          if (widget.isAgent) ...[
            _buildPropertyInfo(context, widget.appointment),
            const SizedBox(height: 10),
            UiUtils.getDivider(context),
            const SizedBox(height: 10),
          ],
          _buildMeetingDetails(context, widget.appointment),
          const SizedBox(height: 10),
          UiUtils.getDivider(context),
          const SizedBox(height: 10),
          _buildActionButtons(context, widget.appointment),
          if (widget.appointment.reason != null &&
              widget.appointment.reason != '' &&
              widget.appointment.reason!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildReason(context, widget.appointment),
          ],
        ],
      ),
    );
  }

  Widget _buildReason(BuildContext context, AppointmentModel appointment) {
    final status = appointment.status.toLowerCase();
    Color backgroundColor;
    String titleText;
    switch (status) {
      case 'rescheduled':
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        titleText = 'rescheduleAlert'.translate(context);
      case 'rejected':
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        titleText = 'rejectedAlert'.translate(context);
      case 'cancelled':
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        titleText = 'cancelledAlert'.translate(context);
      case 'auto_cancelled':
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        titleText = 'cancelledAlert'.translate(context);
      default:
        backgroundColor = context.color.borderColor;
        titleText = '';
    }
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            titleText,
            color: context.color.textColorDark,
            fontSize: context.font.xxs,
            fontWeight: .w500,
          ),
          const SizedBox(height: 4),
          CustomText(
            appointment.reason ?? '',
            color: context.color.textColorDark,
            fontSize: context.font.xs,
            fontWeight: .w500,
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfo(
    BuildContext context,
    AppointmentModel appointment,
  ) {
    final isAgent = appointment.agent != null;
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CustomImage(
            imageUrl: isAgent
                ? appointment.agent?.profile ?? ''
                : appointment.user?.profile ?? '',
            width: 50.rw(context),
            height: 50.rh(context),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            mainAxisAlignment: .center,
            children: [
              CustomText(
                isAgent
                    ? appointment.agent?.name ?? ''
                    : appointment.user?.name ?? '',
                color: context.color.textColorDark,
              ),
              const SizedBox(height: 4),
              CustomText(
                isAgent
                    ? appointment.agent?.email ?? ''
                    : appointment.user?.email ?? '',
                fontSize: context.font.xs,
                color: context.color.textLightColor,
              ),
            ],
          ),
        ),
        _buildStatusBadge(context),
      ],
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final status = widget.appointment.status.toLowerCase();
    Color backgroundColor;
    Color textColor;

    switch (status) {
      case 'confirmed':
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
      case 'completed':
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
      case 'rescheduled':
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
      case 'pending':
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
      case 'rejected':
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
      case 'cancelled':
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
      case 'auto_cancelled':
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
      default:
        backgroundColor = context.color.borderColor;
        textColor = context.color.textColorDark;
    }

    final statusLabel = status == 'auto_cancelled'
        ? 'cancelled'.translate(context)
        : status;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomText(
        statusLabel.firstUpperCase(),
        fontSize: context.font.xs,
        fontWeight: .w400,
        color: textColor,
      ),
    );
  }

  Widget _buildPropertyInfo(
    BuildContext context,
    AppointmentModel appointment,
  ) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: CustomImage(
            imageUrl: appointment.property?.titleImage ?? '',
            width: 50.rw(context),
            height: 50.rh(context),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              CustomText(
                'bookedProperty'.translate(context),
                fontSize: context.font.xs,
                color: context.color.textLightColor,
              ),
              const SizedBox(height: 4),
              CustomText(
                appointment.property?.translatedTitle ??
                    appointment.property?.title ??
                    '',
                color: context.color.textColorDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatTime({
    required String startTime,
    required String endTime,
  }) {
    return '${startTime.formatDate(format: 'hh:mm a')} - ${endTime.formatDate(format: 'hh:mm a')}';
  }

  Widget _buildMeetingDetails(
    BuildContext context,
    AppointmentModel appointment,
  ) {
    final meetingType = appointment.meetingType == 'in_person'
        ? 'inPerson'.translate(context)
        : appointment.meetingType == 'virtual'
        ? 'virtual'.translate(context)
        : 'phone'.translate(context);
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              CustomText(
                'meetingType'.translate(context),
                fontSize: context.font.xs,
                color: context.color.textLightColor,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: .center,
                children: [
                  CustomText(
                    meetingType,
                    fontSize: context.font.sm,
                    fontWeight: .w500,
                    color: context.color.textColorDark,
                  ),
                  const SizedBox(width: 8),
                  if (appointment.status != 'completed' &&
                      widget.appointment.status != 'cancelled' &&
                      widget.appointment.status != 'auto_cancelled' &&
                      !widget.isFromPreviousAppointments)
                    GestureDetector(
                      onTap: () => _showMeetingTypeDialog(context),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: context.color.tertiaryColor.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: CustomImage(
                          imageUrl: AppIcons.edit,
                          width: 16.rw(context),
                          height: 16.rh(context),
                          color: context.color.tertiaryColor,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        Container(
          width: 2,
          height: 54.rh(context),
          color: context.color.borderColor,
        ),
        Expanded(
          child: Column(
            mainAxisAlignment: .center,
            children: [
              CustomText(
                'meetingTime'.translate(context),
                fontSize: context.font.xs,
                color: context.color.textLightColor,
              ),
              const SizedBox(height: 10),
              CustomText(
                _formatTime(
                  startTime: appointment.startAt,
                  endTime: appointment.endAt,
                ),
                fontSize: context.font.sm,
                fontWeight: .w500,
                color: context.color.textColorDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _showMeetingTypeDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (context) => ChangeMeetingTypeDialog(
        isAgent: widget.isAgent,
        selectedMeetingType: widget.appointment.meetingType,
        availableMeetingTypes: widget.appointment.availableMeetingTypes
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        appointmentId: widget.appointment.id.toString(),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    AppointmentModel appointment,
  ) {
    final isConfirmed = widget.appointment.status == 'confirmed';
    final isRescheduled = widget.appointment.status == 'rescheduled';
    final isCancelled =
        widget.appointment.status == 'cancelled' ||
        widget.appointment.status == 'auto_cancelled';
    final isCompleted = widget.appointment.status == 'completed';

    return Row(
      mainAxisAlignment: .end,
      children: [
        UiUtils.buildButton(
          context,
          showElevation: false,
          padding: const EdgeInsets.all(8),
          autoWidth: true,
          onPressed: () => _showAppointmentDetails(
            context,
            widget.isFromPreviousAppointments,
          ),
          height: 36.rh(context),
          width: 36.rw(context),
          buttonTitle: 'seeDetails'.translate(context),
          textColor: context.color.textColorDark,
          buttonColor: context.color.borderColor,
          fontSize: context.font.xs,
          suffixWidget: CustomImage(
            imageUrl: AppIcons.arrowRight,
            fit: .contain,
            width: 20.rw(context),
            height: 20.rh(context),
            color: context.color.textColorDark,
          ),
          border: BorderSide.none,
        ),
        const SizedBox(width: 8),
        if (!widget.isFromPreviousAppointments) ...[
          if (widget.isAgent &&
              !isConfirmed &&
              !isRescheduled &&
              !isCancelled &&
              !isCompleted) ...[
            GestureDetector(
              onTap: _isAccepting ? null : _acceptAppointment,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                height: 36.rh(context),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _isAccepting
                      ? Colors.grey.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: _isAccepting
                    ? SizedBox(
                        width: 16.rw(context),
                        height: 16.rh(context),
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green,
                          ),
                        ),
                      )
                    : CustomText(
                        'accept'.translate(context),
                        color: Colors.green,
                        fontSize: context.font.xs,
                      ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          if (!isCancelled && !isCompleted) ...[
            GestureDetector(
              onTap: () => _startRescheduleFlow(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                height: 36.rh(context),
                width: 36.rw(context),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: CustomImage(
                  imageUrl: AppIcons.clock,
                  fit: .contain,
                  width: 20.rw(context),
                  height: 20.rh(context),
                  color: Colors.blue,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isCancelling ? null : () => _showCancelDialog(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                height: 36.rh(context),
                width: 36.rw(context),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 20.rh(context),
                ),
              ),
            ),
          ],
        ],
      ],
    );
  }

  Future<void> _showAppointmentDetails(
    BuildContext context,
    bool isFromPreviousAppointments,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: context.color.secondaryColor,
      builder: (context) => AppointmentDetailsBottomSheet(
        appointment: widget.appointment,
        isFromAgentAppointments: widget.isAgent,
        isFromPreviousAppointments: isFromPreviousAppointments,
      ),
    );
  }

  Future<void> _acceptAppointment() async {
    setState(() {
      _isAccepting = true;
    });

    try {
      await context
          .read<UpdateAppointmentStatusCubit>()
          .updateAppointmentStatus(
            appointmentId: widget.appointment.id.toString(),
            status: 'confirmed',
            reason: '',
            date: '',
            startTime: '',
            endTime: '',
          );

      // Refresh the appointments list
      if (widget.isAgent) {
        unawaited(
          context
              .read<FetchAgentUpcomingAppointmentsCubit>()
              .fetchAgentUpcomingAppointments(forceRefresh: true),
        );
      } else {
        unawaited(
          context
              .read<FetchUserUpcomingAppointmentsCubit>()
              .fetchUserUpcomingAppointments(forceRefresh: true),
        );
      }

      if (mounted) {
        HelperUtils.showSnackBarMessage(
          context,
          'appointmentAcceptedSuccessfully',
        );
      }
    } on Exception catch (_) {
      if (mounted) {
        HelperUtils.showSnackBarMessage(
          context,
          'failedToAcceptAppointment',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAccepting = false;
        });
      }
    }
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return CancelDialog(
          onCancel: _cancelAppointment,
          reasonController: _reasonController,
        );
      },
    );
  }

  Future<void> _startRescheduleFlow(BuildContext context) async {
    // Get current user details from HiveUtils if the current user is an agent
    final currentUser = HiveUtils.getUserDetails();
    final isAdmin =
        widget.appointment.adminId != null &&
        widget.appointment.adminId != '' &&
        widget.appointment.adminId!.isNotEmpty;

    // Determine agent details based on whether current user is agent or normal user

    final agentDetails = widget.isAgent || isAdmin
        ? CustomerData(
            id: isAdmin ? 0 : int.parse(widget.appointment.agentId ?? '0'),
            slugId: currentUser.token ?? '',
            name: currentUser.name ?? '',
            profile: currentUser.profile ?? '',
            mobile: currentUser.mobile ?? '',
            email: currentUser.email ?? '',
            address: currentUser.address,
            city: null,
            country: null,
            state: null,
            facebookId: currentUser.facebook,
            twitterId: currentUser.twitter,
            youtubeId: currentUser.youtube,
            instagramId: currentUser.instagram,
            aboutMe: null,
            projectCount: currentUser.customertotalpost?.toString(),
            propertyCount: null,
            propertiesSoldCount: null,
            propertiesRentedCount: null,
            isVerified: false,
            isAppointmentAvailable: currentUser.isAppointmentAvailable ?? false,
          )
        : CustomerData(
            id: widget.appointment.agent?.id ?? 0,
            slugId: '',
            name: widget.appointment.agent?.name ?? '',
            profile: widget.appointment.agent?.profile ?? '',
            mobile: '',
            email: widget.appointment.agent?.email ?? '',
            address: null,
            city: null,
            country: null,
            state: null,
            facebookId: null,
            twitterId: null,
            youtubeId: null,
            instagramId: null,
            aboutMe: null,
            projectCount: null,
            propertyCount: null,
            propertiesSoldCount: null,
            propertiesRentedCount: null,
            isVerified: false,
            isAppointmentAvailable:
                widget.appointment.agent?.isAppointmentAvailable ?? false,
          );

    // Navigate to the reschedule flow instead of showing dialog
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (context) => AppointmentFlow(
          agentDetails: agentDetails,
          isAdmin: false,
          isRescheduleMode: true,
          existingAppointment: widget.appointment,
          onRescheduleComplete: () async {
            // Refresh the appointments list after reschedule
            if (widget.isAgent) {
              unawaited(
                context
                    .read<FetchAgentUpcomingAppointmentsCubit>()
                    .fetchAgentUpcomingAppointments(forceRefresh: true),
              );
            } else {
              unawaited(
                context
                    .read<FetchUserUpcomingAppointmentsCubit>()
                    .fetchUserUpcomingAppointments(forceRefresh: true),
              );
            }
          },
        ),
      ),
    );
  }

  Future<void> _cancelAppointment() async {
    setState(() {
      _isCancelling = true;
    });
    if (_reasonController.text.trim().isEmpty) {
      await Fluttertoast.showToast(
        msg: 'reasonForCancellationRequired'.translate(context),
      );
      return;
    }

    try {
      await context
          .read<UpdateAppointmentStatusCubit>()
          .updateAppointmentStatus(
            appointmentId: widget.appointment.id.toString(),
            status: 'cancelled',
            reason: _reasonController.text.trim(),
            date: '',
            startTime: '',
            endTime: '',
          );

      // Refresh the appointments list
      if (widget.isAgent) {
        unawaited(
          context
              .read<FetchAgentUpcomingAppointmentsCubit>()
              .fetchAgentUpcomingAppointments(forceRefresh: true),
        );
      } else {
        unawaited(
          context
              .read<FetchUserUpcomingAppointmentsCubit>()
              .fetchUserUpcomingAppointments(forceRefresh: true),
        );
      }
      Navigator.of(context).pop();
    } on Exception catch (_) {
      if (mounted) {
        HelperUtils.showSnackBarMessage(
          context,
          'failedToCancelAppointment',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCancelling = false;
        });
      }
    }
  }
}
