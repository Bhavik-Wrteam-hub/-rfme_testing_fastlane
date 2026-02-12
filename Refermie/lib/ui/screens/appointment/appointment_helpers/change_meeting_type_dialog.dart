import 'package:ebroker/data/cubits/appointment/get/fetch_agent_upcoming_appointments_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_user_upcoming_appointments_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/update_meeting_type_cubit.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/meeting_type_selector.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChangeMeetingTypeDialog extends StatefulWidget {
  const ChangeMeetingTypeDialog({
    required this.isAgent,
    required this.appointmentId,
    required this.selectedMeetingType,
    required this.availableMeetingTypes,
    super.key,
  });
  final bool isAgent;
  final String appointmentId;
  final String selectedMeetingType;
  final List<String> availableMeetingTypes;

  @override
  State<ChangeMeetingTypeDialog> createState() =>
      _ChangeMeetingTypeDialogState();
}

class _ChangeMeetingTypeDialogState extends State<ChangeMeetingTypeDialog> {
  String? _selectedMeetingType;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedMeetingType = widget.selectedMeetingType;
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
                    'changeMeetingType'.translate(context),
                    fontWeight: .w600,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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
            MeetingTypeSelector(
              meetingTypes: widget.availableMeetingTypes,
              selectedMeetingType: _selectedMeetingType,
              onMeetingTypeChanged: (meetingType) {
                setState(() {
                  _selectedMeetingType = meetingType;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                Expanded(
                  child: UiUtils.buildButton(
                    context,
                    onPressed: () => Navigator.pop(context),
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
                    onPressed: () async {
                      if (isLoading) return;
                      if (_selectedMeetingType == null) {
                        HelperUtils.showSnackBarMessage(
                          context,
                          'pleaseSelectMeetingType',
                        );
                        return;
                      }
                      setState(() {
                        isLoading = true;
                      });
                      try {
                        await context
                            .read<UpdateMeetingTypeCubit>()
                            .updateMeetingType(
                              appointmentId: widget.appointmentId,
                              meetingType: _selectedMeetingType!,
                            );
                        if (widget.isAgent) {
                          await context
                              .read<FetchAgentUpcomingAppointmentsCubit>()
                              .fetchAgentUpcomingAppointments(
                                forceRefresh: false,
                              );
                          isLoading = false;
                        } else {
                          await context
                              .read<FetchUserUpcomingAppointmentsCubit>()
                              .fetchUserUpcomingAppointments(
                                forceRefresh: false,
                              );
                          isLoading = false;
                        }
                        Navigator.pop(context);
                      } on Exception catch (_) {
                        HelperUtils.showSnackBarMessage(
                          context,
                          'failedToChangeMeetingType',
                        );
                        isLoading = false;
                        Navigator.pop(context);
                      } finally {
                        isLoading = false;
                      }
                    },
                    buttonTitle: isLoading ? '' : 'update'.translate(context),
                    prefixWidget: isLoading
                        ? UiUtils.progress(
                            height: 16.rh(context),
                            width: 16.rw(context),
                          )
                        : null,
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
