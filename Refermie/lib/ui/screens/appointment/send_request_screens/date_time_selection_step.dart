import 'package:ebroker/data/cubits/appointment/get/fetch_monthly_time_slots_cubit.dart';
import 'package:ebroker/data/model/appointment/monthly_time_slots_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/appointment_widgets_export.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/meeting_type_selector.dart';
import 'package:ebroker/ui/screens/appointment/send_request_screens/appointment_flow.dart';
import 'package:flutter/material.dart';

class DateTimeSelectionStep extends StatefulWidget {
  const DateTimeSelectionStep({
    required this.appointmentData,
    required this.focusedDay,
    required this.firstDay,
    required this.lastDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onTimeSlotChanged,
    required this.onMeetingTypeChanged,
    required this.agentId,
    required this.isAdmin,
    super.key,
  });

  final AppointmentData appointmentData;
  final DateTime focusedDay;
  final DateTime firstDay;
  final DateTime lastDay;
  final void Function(DateTime, DateTime) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final void Function(String?, String?) onTimeSlotChanged;
  final ValueChanged<String?> onMeetingTypeChanged;
  final String agentId;
  final bool isAdmin;
  @override
  State<DateTimeSelectionStep> createState() => _DateTimeSelectionStepState();
}

class _DateTimeSelectionStepState extends State<DateTimeSelectionStep> {
  MonthlyTimeSlotsModel? _monthlyTimeSlotsData;
  late DateTime _currentFocusedDay;
  List<String> _availableMeetingTypes = [];

  @override
  void initState() {
    super.initState();
    _currentFocusedDay = widget.focusedDay;
    unawaited(_loadMonthlyTimeSlots());
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadMonthlyTimeSlots() async {
    await context.read<FetchMonthlyTimeSlotsCubit>().fetchMonthlyTimeSlots(
      year: _currentFocusedDay.year.toString(),
      month: _currentFocusedDay.month.toString(),
      agentId: widget.agentId,
      isAdmin: widget.isAdmin,
    );
  }

  Future<void> _onPageChangedWithAPI(DateTime focusedDay) async {
    // Always call the parent's onPageChanged first to update parent state
    widget.onPageChanged(focusedDay);

    // Check if month/year changed from our tracked focused day
    if (focusedDay.month != _currentFocusedDay.month ||
        focusedDay.year != _currentFocusedDay.year) {
      // Update our tracked focused day
      setState(() {
        _currentFocusedDay = focusedDay;
      });

      // Fetch new data for the new month/year
      await context.read<FetchMonthlyTimeSlotsCubit>().fetchMonthlyTimeSlots(
        year: focusedDay.year.toString(),
        month: focusedDay.month.toString(),
        agentId: widget.agentId,
        isAdmin: widget.isAdmin,
      );
    }
  }

  List<TimeSlot> _getAvailableTimeSlotsForDate(DateTime date) {
    if (_monthlyTimeSlotsData == null) return [];

    final dateKey = AppointmentHelper.getDateKey(date);
    final slots = _monthlyTimeSlotsData!.days[dateKey] ?? [];

    return slots;
  }

  bool _isDateAvailable(DateTime date) {
    if (_monthlyTimeSlotsData == null) return false;

    final dateKey = AppointmentHelper.getDateKey(date);
    final slots = _monthlyTimeSlotsData!.days[dateKey] ?? [];

    return slots.isNotEmpty;
  }

  void _extractMeetingTypes() {
    if ((_monthlyTimeSlotsData?.availableMeetingTypes ?? '').isNotEmpty) {
      _availableMeetingTypes = _monthlyTimeSlotsData!.availableMeetingTypes
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      _availableMeetingTypes = [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FetchMonthlyTimeSlotsCubit, FetchMonthlyTimeSlotsState>(
      listener: (context, state) {
        if (state is FetchMonthlyTimeSlotsSuccess) {
          setState(() {
            _monthlyTimeSlotsData = state.monthlyTimeSlots;
            _extractMeetingTypes();
          });
        } else if (state is FetchMonthlyTimeSlotsFailure) {
          HelperUtils.showSnackBarMessage(
            context,
            'Failed to load time slots: ${state.errorMessage}',
          );
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            AppointmentCalendarCard(
              isFromAllSchedules: false,
              focusedDay: _currentFocusedDay,
              selectedDay: widget.appointmentData.selectedDate,
              firstDay: widget.firstDay,
              lastDay: widget.lastDay,
              onDaySelected: widget.onDaySelected,
              onPageChanged: _onPageChangedWithAPI,
              enabledDayPredicate: _isDateAvailable,
              showHeader: true,
              availableDateKeys: _monthlyTimeSlotsData?.days.entries
                  .where((e) => e.value.isNotEmpty)
                  .map((e) => e.key)
                  .toList(),
            ),
            const SizedBox(height: 16),
            BlocBuilder<FetchMonthlyTimeSlotsCubit, FetchMonthlyTimeSlotsState>(
              builder: (context, state) {
                if (state is FetchMonthlyTimeSlotsLoading) {
                  return AppointmentCardContainer(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: CustomText(
                            'selectTimeSlot'.translate(context),
                            color: context.color.textColorDark,
                            fontSize: context.font.sm,
                            fontWeight: .w500,
                          ),
                        ),
                        UiUtils.getDivider(context),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 12,
                            children: List.generate(10, (index) {
                              return CustomShimmer(
                                borderRadius: 4,
                                height: 20,
                                width: index.isEven ? 70 : 80,
                              );
                            }),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final availableSlots =
                    widget.appointmentData.selectedDate != null
                    ? _getAvailableTimeSlotsForDate(
                        widget.appointmentData.selectedDate!,
                      )
                    : <TimeSlot>[];

                return Column(
                  children: [
                    _TimeSlotSelector(
                      currentFocusedDay: _currentFocusedDay,
                      selectedStartTime:
                          widget.appointmentData.selectedStartTime,
                      selectedEndTime: widget.appointmentData.selectedEndTime,
                      onTimeSlotChanged: widget.onTimeSlotChanged,
                      availableTimeSlots: availableSlots,
                    ),
                    const SizedBox(height: 16),
                    MeetingTypeSelector(
                      meetingTypes: _availableMeetingTypes,
                      selectedMeetingType: widget.appointmentData.meetingType,
                      onMeetingTypeChanged: widget.onMeetingTypeChanged,
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeSlotSelector extends StatelessWidget {
  const _TimeSlotSelector({
    required this.selectedStartTime,
    required this.selectedEndTime,
    required this.onTimeSlotChanged,
    required this.currentFocusedDay,
    this.availableTimeSlots = const [],
  });

  final String? selectedStartTime;
  final String? selectedEndTime;
  final DateTime? currentFocusedDay;
  final void Function(String?, String?) onTimeSlotChanged;
  final List<TimeSlot> availableTimeSlots;

  @override
  Widget build(BuildContext context) {
    return AppointmentCardContainer(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomText(
              'selectStartTime'.translate(context),
              color: context.color.textColorDark,
              fontSize: context.font.sm,
              fontWeight: .w500,
            ),
          ),
          UiUtils.getDivider(context),
          Padding(
            padding: const EdgeInsets.all(16),
            child: currentFocusedDay == null
                ? CustomText(
                    'pleaseSelectDate'.translate(context),
                    color: context.color.textLightColor,
                    fontSize: context.font.sm,
                  )
                : availableTimeSlots.isEmpty
                ? CustomText(
                    'noTimeSlotsAvailableForSelectedDate'.translate(context),
                    color: context.color.textLightColor,
                    fontSize: context.font.sm,
                  )
                : Column(
                    crossAxisAlignment: .start,
                    children: [
                      GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithMaxCrossAxisExtent(
                              maxCrossAxisExtent: 150,
                              childAspectRatio: 2,
                              mainAxisSpacing: 8,
                              crossAxisSpacing: 8,
                              mainAxisExtent: 40,
                            ),
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: availableTimeSlots.length,
                        itemBuilder: (context, index) {
                          final timeSlot = availableTimeSlots[index];
                          final isSelected =
                              selectedStartTime == timeSlot.startTime;
                          return _TimeSlotChip(
                            slot: AppointmentHelper.formatTimeToAmPm(
                              timeSlot.startTime,
                            ),
                            isSelected: isSelected,
                            onTap: () {
                              if (isSelected) {
                                onTimeSlotChanged(null, null);
                              } else {
                                onTimeSlotChanged(
                                  timeSlot.startTime,
                                  timeSlot.endTime,
                                );
                              }
                            },
                          );
                        },
                      ),
                      if (selectedStartTime != null &&
                          selectedEndTime != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.color.tertiaryColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: context.color.tertiaryColor.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: context.color.tertiaryColor,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: CustomText(
                                  '${'appointmentDuration'.translate(context)} : ${AppointmentHelper.formatTimeToAmPm(selectedStartTime!)} - ${AppointmentHelper.formatTimeToAmPm(selectedEndTime!)}',
                                  color: context.color.textColorDark,
                                  fontSize: context.font.sm,
                                  fontWeight: .w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _TimeSlotChip extends StatelessWidget {
  const _TimeSlotChip({
    required this.slot,
    required this.isSelected,
    required this.onTap,
  });

  final String slot;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return UiUtils.buildButton(
      context,
      onPressed: onTap,
      buttonTitle: slot,
      autoWidth: true,
      textColor: isSelected
          ? context.color.buttonColor
          : context.color.textLightColor,
      fontSize: context.font.sm,
      buttonColor: isSelected
          ? context.color.tertiaryColor
          : context.color.secondaryColor,
      border: BorderSide(
        color: isSelected
            ? context.color.tertiaryColor
            : context.color.borderColor,
      ),
    );
  }
}
