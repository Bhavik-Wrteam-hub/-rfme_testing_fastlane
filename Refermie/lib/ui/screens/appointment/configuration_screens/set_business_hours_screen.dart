import 'package:ebroker/data/cubits/appointment/delete/delete_extra_time_slot_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_agent_time_schedules_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_booking_preferences_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/manage_extra_time_slot_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/set_agent_time_schedule_cubit.dart';
import 'package:ebroker/data/model/appointment/agent_time_schedule_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/appointment_widgets_export.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/remove_schedule_warning.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/view_schedule_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TimeSlot {
  TimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.appointmentCount,
  });
  final String id;
  final String startTime;
  final String endTime;
  final String appointmentCount;

  TimeSlot copyWith({
    String? id,
    String? startTime,
    String? endTime,
    String? appointmentCount,
  }) {
    return TimeSlot(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      appointmentCount: appointmentCount ?? this.appointmentCount,
    );
  }
}

class DaySchedule {
  DaySchedule({
    required this.dayIndex,
    required this.dayName,
    required this.isEnabled,
    required this.isExpanded,
    required this.timeSlots,
    required this.extraSlots,
  });
  final int dayIndex;
  final String dayName;
  final bool isEnabled;
  final bool isExpanded;
  final List<TimeSlot> timeSlots;
  final List<ExtraSlot> extraSlots;

  DaySchedule copyWith({
    int? dayIndex,
    String? dayName,
    bool? isEnabled,
    bool? isExpanded,
    List<TimeSlot>? timeSlots,
    List<ExtraSlot>? extraSlots,
  }) {
    return DaySchedule(
      dayIndex: dayIndex ?? this.dayIndex,
      dayName: dayName ?? this.dayName,
      isEnabled: isEnabled ?? this.isEnabled,
      isExpanded: isExpanded ?? this.isExpanded,
      timeSlots: timeSlots ?? this.timeSlots,
      extraSlots: extraSlots ?? this.extraSlots,
    );
  }
}

class SetBusinessHoursScreen extends StatefulWidget {
  const SetBusinessHoursScreen({super.key});

  @override
  State<SetBusinessHoursScreen> createState() => _SetBusinessHoursScreenState();
}

class _SetBusinessHoursScreenState extends State<SetBusinessHoursScreen> {
  List<DaySchedule> _weekSchedule = [];
  List<ExtraSlot> _extraSlots = [];
  int? _bufferTimeMinutes;
  bool _isInitialized = false;
  bool _preferencesLoaded = false;
  String selectedTab = 'dailyHours';

  // Track deleted time slot IDs for API submission
  final List<String> _deletedSlotIds = [];

  // Cache for time options to avoid recalculation
  // Removed: previously used to cache generated dropdown options

  @override
  void initState() {
    super.initState();
    _initializeWeekSchedule();
    // Load data after the widget is built and context is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (_isInitialized || !mounted) return;

    // Load preferences first, schedules will be loaded by BlocConsumer
    await _fetchBookingPreferences();

    // Check if data is already available from global cubit
    final cubit = context.read<FetchAgentTimeSchedulesCubit>();
    if (cubit.state is FetchAgentTimeSchedulesSuccess) {
      final state = cubit.state as FetchAgentTimeSchedulesSuccess;
      setState(() {
        _extraSlots = state.schedules.extraSlots;
      });
      _populateWeekScheduleFromApi(state.schedules.timeSchedules);
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _fetchBookingPreferences() async {
    final cubit = context.read<FetchBookingPreferencesCubit>();
    if (cubit.state is! FetchBookingPreferencesSuccess) {
      await cubit.fetchBookingPreferences();
    } else {
      final state = cubit.state as FetchBookingPreferencesSuccess;
      setState(() {
        _preferencesLoaded = true;
      });
      final parsedBuffer = int.parse(
        state.bookingPreferences.bufferTimeMinutes,
      );
      _updatePreferences(bufferTime: parsedBuffer);
    }
  }

  void _populateWeekScheduleFromApi(List<TimeSchedule> timeSchedules) {
    if (!mounted) return;

    setState(() {
      // time options cache removed
      _deletedSlotIds.clear(); // Clear deleted IDs when loading fresh data

      // Reset all days
      for (var i = 0; i < _weekSchedule.length; i++) {
        _weekSchedule[i] = _weekSchedule[i].copyWith(
          isEnabled: false,
          isExpanded: false,
          timeSlots: [],
          extraSlots: [],
        );
      }

      // Group schedules by day for better performance
      final schedulesByDay = <int, List<TimeSchedule>>{};
      for (final schedule in timeSchedules) {
        if (schedule.isActive == '1') {
          final dayIndex = _getDayIndexFromApiName(
            schedule.dayOfWeek.toLowerCase(),
          );
          if (dayIndex != -1) {
            schedulesByDay.putIfAbsent(dayIndex, () => []).add(schedule);
          }
        } else {}
      }

      // Group extra slots by day of the week
      final extraSlotsByDay = _groupExtraSlotsByDay();

      // Process each day
      schedulesByDay.forEach((dayIndex, daySchedules) {
        final timeSlots = daySchedules
            .map(
              (schedule) => TimeSlot(
                id: schedule.id,
                startTime: _formatTimeFromApi(schedule.startTime),
                endTime: _formatTimeFromApi(schedule.endTime),
                appointmentCount: schedule.appointmentCount,
              ),
            )
            .toList();

        _weekSchedule[dayIndex] = _weekSchedule[dayIndex].copyWith(
          isEnabled: true,
          isExpanded: false,
          timeSlots: timeSlots,
          extraSlots: extraSlotsByDay[dayIndex] ?? [],
        );
      });

      // Also populate days that only have extra slots
      extraSlotsByDay.forEach((dayIndex, extraSlots) {
        if (!schedulesByDay.containsKey(dayIndex)) {
          _weekSchedule[dayIndex] = _weekSchedule[dayIndex].copyWith(
            isEnabled: false,
            isExpanded: false,
            timeSlots: [],
            extraSlots: extraSlots,
          );
        }
      });
    });
  }

  int _getDayIndexFromApiName(String apiDayName) {
    const dayMapping = {
      'sunday': 0,
      'monday': 1,
      'tuesday': 2,
      'wednesday': 3,
      'thursday': 4,
      'friday': 5,
      'saturday': 6,
    };
    return dayMapping[apiDayName.toLowerCase()] ?? -1;
  }

  String _formatTimeFromApi(String apiTime) {
    try {
      return apiTime.length >= 5 ? apiTime.substring(0, 5) : apiTime;
    } on Exception catch (_) {
      return apiTime;
    }
  }

  Map<int, List<ExtraSlot>> _groupExtraSlotsByDay() {
    final extraSlotsByDay = <int, List<ExtraSlot>>{};

    for (final extraSlot in _extraSlots) {
      try {
        final date = DateTime.parse(extraSlot.date);
        final dayIndex = date.weekday % 7; // Convert to 0-6 format (Sunday = 0)

        extraSlotsByDay.putIfAbsent(dayIndex, () => []).add(extraSlot);
      } on Exception {
        // Skip invalid dates
        continue;
      }
    }

    return extraSlotsByDay;
  }

  void _initializeWeekSchedule() {
    _weekSchedule = List.generate(7, (index) {
      return DaySchedule(
        dayIndex: index,
        dayName: AppointmentHelper.getDayName(index),
        isEnabled: false,
        isExpanded: false,
        timeSlots: [],
        extraSlots: [],
      );
    });
  }

  void _updatePreferences({required int bufferTime}) {
    final shouldUpdate =
        _bufferTimeMinutes != bufferTime || !_preferencesLoaded;

    if (!shouldUpdate) return;

    setState(() {
      _bufferTimeMinutes = bufferTime;
      _preferencesLoaded = true;
    });
  }

  // Unified success handler for all operations
  void _handleOperationSuccess(String message) {
    HelperUtils.showSnackBarMessage(
      context,
      message,
      type: .success,
    );
  }

  // Unified error handler for all operations
  void _handleOperationError(String message) {
    HelperUtils.showSnackBarMessage(
      context,
      message,
      type: .error,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<DeleteExtraTimeSlotCubit, DeleteExtraTimeSlotState>(
          listener: (context, state) {
            if (state is DeleteExtraTimeSlotSuccess) {
              _handleOperationSuccess(
                'extraTimeSlotDeletedSuccessfully'.translate(context),
              );
            }
            if (state is DeleteExtraTimeSlotFailure) {
              HelperUtils.showSnackBarMessage(
                context,
                state.errorMessage?.toString() ?? '',
                type: .error,
              );
            }
          },
        ),
        BlocListener<ManageExtraTimeSlotCubit, ManageExtraTimeSlotState>(
          listener: (context, state) {
            if (state is ManageExtraTimeSlotSuccess) {
              _handleOperationSuccess(
                'extraTimeSlotUpdatedSuccessfully'.translate(context),
              );
            }
            if (state is ManageExtraTimeSlotFailure) {
              HelperUtils.showSnackBarMessage(
                context,
                state.errorMessage,
                type: .error,
              );
            }
          },
        ),
        // Consolidated listener for main operations
        BlocListener<SetAgentTimeScheduleCubit, SetAgentTimeScheduleState>(
          listener: (context, state) async {
            if (state is SetAgentTimeScheduleSuccess) {
              _handleOperationSuccess(
                'scheduleSavedSuccessfully'.translate(context),
              );
              await context
                  .read<FetchAgentTimeSchedulesCubit>()
                  .fetchAgentTimeSchedules(forceRefresh: true);
            } else if (state is SetAgentTimeScheduleFailure) {
              _handleOperationError(state.errorMessage);
            }
          },
        ),
        BlocListener<
          FetchBookingPreferencesCubit,
          FetchBookingPreferencesState
        >(
          listener: (context, state) {
            if (state is FetchBookingPreferencesSuccess) {
              final parsedBuffer = int.parse(
                state.bookingPreferences.bufferTimeMinutes,
              );
              _updatePreferences(bufferTime: parsedBuffer);
            }
          },
        ),
      ],
      child: Builder(
        builder: (context) {
          final cubit = context.read<FetchAgentTimeSchedulesCubit>();
          // Trigger the API call using the global cubit instance
          if (!_isInitialized) {
            WidgetsBinding.instance.addPostFrameCallback((_) async {
              // Only fetch if not already loading or if we need to refresh
              if (cubit.state is FetchAgentTimeSchedulesInitial ||
                  cubit.state is FetchAgentTimeSchedulesFailure) {
                await cubit.fetchAgentTimeSchedules(forceRefresh: true);
              }
            });
          }

          return BlocConsumer<
            FetchAgentTimeSchedulesCubit,
            FetchAgentTimeSchedulesState
          >(
            listener: (context, state) {
              if (state is FetchAgentTimeSchedulesSuccess) {
                setState(() {
                  _extraSlots = state.schedules.extraSlots;
                });
                _populateWeekScheduleFromApi(state.schedules.timeSchedules);
              }
            },
            builder: (context, fetchState) {
              if (fetchState is FetchAgentTimeSchedulesLoading ||
                  !_preferencesLoaded) {
                return AppointmentHelper.buildShimmer();
              }

              return BlocBuilder<
                SetAgentTimeScheduleCubit,
                SetAgentTimeScheduleState
              >(
                builder: (context, saveState) {
                  return Stack(
                    children: [
                      _buildContentArea(),
                      _buildTabSwitch(),
                      _buildSaveButton(),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTabSwitch() {
    return PositionedDirectional(
      start: 0,
      end: 0,
      top: 0,
      child: SizedBox(
        height: 44.rh(context),
        child: ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(4)),
          child: Row(
            mainAxisAlignment: .center,
            children: [
              _buildTabButton('dailyHours'),
              _buildTabButton('extraHours'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTabButton(String tab) {
    final isSelected = selectedTab == tab;
    final color = Color.lerp(
      isSelected ? context.color.tertiaryColor : context.color.textColorDark,
      context.color.secondaryColor,
      0.9,
    );
    final border = tab == 'dailyHours'
        ? const BorderRadius.only(
            topLeft: Radius.circular(4),
            bottomLeft: Radius.circular(4),
          )
        : const BorderRadius.only(
            topRight: Radius.circular(4),
            bottomRight: Radius.circular(4),
          );
    return Expanded(
      child: ClipRRect(
        borderRadius: border,
        child: UiUtils.buildButton(
          context,
          radius: 0,
          showElevation: false,
          onPressed: () {
            setState(() {
              selectedTab = tab;
            });
          },
          fontSize: context.font.sm.rf(context),

          buttonTitle: tab.translate(context),
          buttonColor: color,
          textColor: isSelected
              ? context.color.tertiaryColor
              : context.color.textLightColor,
        ),
      ),
    );
  }

  Widget _buildContentArea() {
    final upperPadding = ResponsiveHelper.isLargeTablet(context)
        ? kBottomNavigationBarHeight + 24
        : kBottomNavigationBarHeight;
    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: upperPadding),
          _buildInfoContainer(
            title: selectedTab == 'extraHours'
                ? 'extraAvailability'
                : 'setBusinessHours',
            description: selectedTab == 'extraHours'
                ? 'specifyExtraAvailability'
                : 'specifyBusinessHours',
          ),
          if (selectedTab == 'extraHours') ...[
            _buildExtraHoursTab(),
          ] else ...[
            _buildWeeklyScheduleCard(),
            const SizedBox(height: kBottomNavigationBarHeight + 20),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoContainer({
    required String title,
    required String description,
  }) {
    return AppointmentCardContainer(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: .start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: context.color.textColorDark.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: CustomImage(
              imageUrl: AppIcons.clock,
              width: 20.rw(context),
              height: 20.rh(context),
              color: context.color.textColorDark,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                CustomText(
                  title.translate(context),
                  color: context.color.textColorDark,
                  fontWeight: .w500,
                ),
                const SizedBox(height: 4),
                CustomText(
                  description.translate(context),
                  color: context.color.textColorDark,
                  fontSize: context.font.xs,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyScheduleCard() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        ..._weekSchedule.map(
          (daySchedule) => _buildDayCard(
            daySchedule: daySchedule,
            isLastDay: daySchedule == _weekSchedule.last,
          ),
        ),
      ],
    );
  }

  Widget _buildExtraHoursTab() {
    final daysWithExtras = _weekSchedule
        .where((day) => day.extraSlots.isNotEmpty)
        .toList();

    return SingleChildScrollView(
      child: AppointmentCardContainer(
        margin: const EdgeInsets.only(
          bottom: kBottomNavigationBarHeight + 20,
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (daysWithExtras.isEmpty)
              NoDataFound(
                title: 'noExtraHoursFound'.translate(context),
                description: 'noExtraHoursFoundDescription'.translate(context),
                onTapRetry: () async {
                  await context
                      .read<FetchAgentTimeSchedulesCubit>()
                      .fetchAgentTimeSchedules(forceRefresh: true);
                },
              )
            else
              ...daysWithExtras.map(_buildExtraHoursSection),
          ],
        ),
      ),
    );
  }

  Widget _buildDayCard({
    required DaySchedule daySchedule,
    required bool isLastDay,
  }) {
    return AppointmentCardContainer(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          _buildDayHeader(daySchedule),
          if (daySchedule.isExpanded &&
              daySchedule.isEnabled &&
              daySchedule.timeSlots.isNotEmpty)
            _buildDayContent(daySchedule)
          else if (!daySchedule.isEnabled)
            _buildDayClosed(),
        ],
      ),
    );
  }

  Widget _buildDayClosed() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: context.color.secondaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: context.color.borderColor,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 8),
      child: CustomText(
        'closed'.translate(context),
        color: context.color.textLightColor,
        fontSize: context.font.sm,
      ),
    );
  }

  Widget _buildDayHeader(DaySchedule daySchedule) {
    final hasContent = daySchedule.timeSlots.isNotEmpty;

    return InkWell(
      onTap: daySchedule.isEnabled && hasContent
          ? () => _toggleDayExpansion(daySchedule.dayIndex)
          : null,
      child: Container(
        height: 44.rh(context),
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            AppointmentSwitch(
              value: daySchedule.isEnabled,
              onChanged: (value) async =>
                  _toggleDayEnabled(daySchedule.dayIndex, value),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: CustomText(
                daySchedule.dayName.translate(context),
                color: context.color.textColorDark,
                fontSize: context.font.md,
                fontWeight: .w500,
              ),
            ),
            if (daySchedule.isEnabled && hasContent)
              daySchedule.isExpanded
                  ? Transform.flip(
                      flipY: true,
                      child: CustomImage(
                        imageUrl: AppIcons.downArrow,
                        width: 20.rw(context),
                        height: 20.rh(context),
                        color: context.color.textLightColor,
                      ),
                    )
                  : CustomImage(
                      imageUrl: AppIcons.downArrow,
                      width: 20.rw(context),
                      height: 20.rh(context),
                      color: context.color.textLightColor,
                    ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayContent(DaySchedule daySchedule) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          // Regular time slots
          if (daySchedule.timeSlots.isNotEmpty) ...[
            ...daySchedule.timeSlots.map(
              (slot) => Padding(
                padding: const EdgeInsets.only(bottom: 8, top: 8),
                child: _buildTimeSlot(daySchedule.dayIndex, slot),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeSlot(int dayIndex, TimeSlot slot) {
    final daySchedule = _weekSchedule[dayIndex];
    final isFirstSlot = daySchedule.timeSlots.first.id == slot.id;
    final timeSelector = AppointmentTimePicker(
      startTime: slot.startTime,
      endTime: slot.endTime,
      onChanged: (newStart, newEnd) async {
        await _updateTimeSlot(
          dayIndex,
          slot.id,
          startTime: newStart,
          endTime: newEnd,
        );
      },
    );

    return Row(
      children: [
        Expanded(child: timeSelector),
        const SizedBox(width: 12),
        // Show both plus and minus buttons for first slot, only minus for others
        if (isFirstSlot) ...[
          // Plus button for first slot
          GestureDetector(
            onTap: () => _addTimeSlot(dayIndex),
            child: Container(
              height: 44.rh(context),
              width: 44.rw(context),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Icon(
                Icons.add,
                color: Colors.green,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        // Minus button for all slots
        GestureDetector(
          onTap: () async {
            await _removeTimeSlot(dayIndex, slot.id);
          },
          child: Container(
            height: 44.rh(context),
            width: 44.rw(context),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.remove,
              color: Colors.red,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExtraHoursSection(DaySchedule daySchedule) {
    // Group extra slots by exact date string (YYYY-MM-DD)
    final slotsByDate = <String, List<ExtraSlot>>{};
    for (final slot in daySchedule.extraSlots) {
      slotsByDate.putIfAbsent(slot.date, () => []).add(slot);
    }

    // Sort dates ascending
    final sortedDates = slotsByDate.keys.toList()
      ..sort((a, b) {
        try {
          return DateTime.parse(a).compareTo(DateTime.parse(b));
        } on Exception {
          return a.compareTo(b);
        }
      });

    return Column(
      crossAxisAlignment: .start,
      children: [
        ...sortedDates.expand((dateStr) {
          final slots = List<ExtraSlot>.from(
            slotsByDate[dateStr]!,
          )..sort((a, b) => a.startTime.compareTo(b.startTime));

          final parsedDate = _tryParseDate(dateStr);
          final dateLabel = parsedDate != null
              ? AppointmentHelper.formatDate(
                  parsedDate,
                  format: 'MMMM dd, yyyy',
                )
              : dateStr;

          final primaryTimeText = slots.length == 1
              ? '${AppointmentHelper.formatTimeToAmPm(slots.first.startTime)} - ${AppointmentHelper.formatTimeToAmPm(slots.first.endTime)}'
              : _formatSlotsTimeWindow(slots);

          return [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
              child: CustomText(
                dateLabel,
                color: context.color.textColorDark,
                fontWeight: .w500,
              ),
            ),
            AppointmentCardContainer(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisSize: .min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: context.color.textColorDark.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: CustomImage(
                            imageUrl: AppIcons.clock,
                            width: 20.rw(context),
                            height: 20.rh(context),
                            color: context.color.textColorDark,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: CustomText(
                            primaryTimeText,
                            color: context.color.textLightColor,
                            fontSize: context.font.sm,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (slots.length > 1)
                    UiUtils.buildButton(
                      context,
                      height: 36.rh(context),
                      autoWidth: true,
                      showElevation: false,
                      buttonColor: context.color.tertiaryColor.withValues(
                        alpha: 0.1,
                      ),
                      textColor: context.color.tertiaryColor,
                      onPressed: () => _showViewSlotsForDate(dateStr, slots),
                      buttonTitle: 'viewSchedule'.translate(context),
                    ),
                ],
              ),
            ),
          ];
        }),
      ],
    );
  }

  DateTime? _tryParseDate(String dateStr) {
    try {
      return DateTime.parse(dateStr);
    } on Exception {
      return null;
    }
  }

  String _formatSlotsTimeWindow(List<ExtraSlot> slots) {
    if (slots.isEmpty) return '';
    final starts = slots.map((e) => e.startTime).toList()..sort();
    final ends = slots.map((e) => e.endTime).toList()..sort();
    final earliestStart = starts.first;
    final latestEnd = ends.last;
    return '${AppointmentHelper.formatTimeToAmPm(earliestStart)} - ${AppointmentHelper.formatTimeToAmPm(latestEnd)}';
  }

  Future<void> _showViewSlotsForDate(
    String dateStr,
    List<ExtraSlot> slots,
  ) async {
    final date = _tryParseDate(dateStr);
    final title = date != null
        ? AppointmentHelper.formatDate(date, format: 'MMMM dd, yyyy')
        : dateStr;
    final dayName = date != null
        ? AppointmentHelper.getDayName(date.weekday % 7)
        : '';

    final sorted = List<ExtraSlot>.from(slots)
      ..sort((a, b) => a.startTime.compareTo(b.startTime));

    await showDialog<void>(
      context: context,
      builder: (context) => ViewScheduleDialog(
        slots: sorted,
        title: title,
        dayName: dayName,
      ),
    );
  }

  Future<void> _toggleDayEnabled(int dayIndex, bool enabled) async {
    // Show confirmation dialog when disabling a day with existing slots that have appointments
    if (!enabled) {
      final existingSlotsWithAppointments = _weekSchedule[dayIndex].timeSlots
          .where(
            (slot) =>
                _isExistingSlot(slot.id) &&
                int.tryParse(slot.appointmentCount) != null &&
                int.parse(slot.appointmentCount) > 0,
          );

      if (existingSlotsWithAppointments.isNotEmpty) {
        final confirmed = await _showModificationConfirmationDialog(
          title: 'disableDay'.translate(context),
          message: 'areYouSureYouWantToDisableThisDay'.translate(context),
        );
        if (!confirmed) return;
      }
    }

    setState(() {
      // Track deleted IDs when disabling a day
      if (!enabled) {
        for (final slot in _weekSchedule[dayIndex].timeSlots) {
          if (_isExistingSlot(slot.id)) {
            _deletedSlotIds.add(slot.id);
          }
        }
      }

      _weekSchedule[dayIndex] = _weekSchedule[dayIndex].copyWith(
        isEnabled: enabled,
        isExpanded: enabled && _weekSchedule[dayIndex].isExpanded,
        timeSlots: enabled
            ? (_weekSchedule[dayIndex].timeSlots.isEmpty
                  ? _createSingleTimeSlot(dayIndex)
                  : _weekSchedule[dayIndex].timeSlots)
            : [],
        extraSlots: _weekSchedule[dayIndex].extraSlots,
      );

      // Clear cache for this day
      // time options cache removed
    });
  }

  void _toggleDayExpansion(int dayIndex) {
    setState(() {
      _weekSchedule[dayIndex] = _weekSchedule[dayIndex].copyWith(
        isExpanded: !_weekSchedule[dayIndex].isExpanded,
      );
    });
  }

  List<TimeSlot> _createSingleTimeSlot(int dayIndex) {
    final slotId = AppointmentHelper.generateSlotId(dayIndex);
    return [
      TimeSlot(
        id: slotId,
        startTime: '',
        endTime: '',
        appointmentCount: '0',
      ),
    ];
  }

  void _addTimeSlot(int dayIndex) {
    final newSlotId = AppointmentHelper.generateSlotId(dayIndex);
    final newSlot = TimeSlot(
      id: newSlotId,
      startTime: '',
      endTime: '',
      appointmentCount: '0',
    );

    setState(() {
      final currentSlots = List<TimeSlot>.from(
        _weekSchedule[dayIndex].timeSlots,
      )..add(newSlot);
      _weekSchedule[dayIndex] = _weekSchedule[dayIndex].copyWith(
        timeSlots: currentSlots,
      );
    });
  }

  Future<void> _removeTimeSlot(int dayIndex, String slotId) async {
    // Show confirmation dialog for existing slots with appointments
    if (_isExistingSlot(slotId)) {
      final confirmed = await _showModificationConfirmationDialog(
        title: 'removeTimeSlot'.translate(context),
        message: 'areYouSureYouWantToRemoveThisTimeSlot'.translate(
          context,
        ),
      );
      if (!confirmed) return;
    }

    setState(() {
      // Track deleted ID if it's an existing slot from API
      if (_isExistingSlot(slotId)) {
        _deletedSlotIds.add(slotId);
      }

      final currentSlots = _weekSchedule[dayIndex].timeSlots
          .where((slot) => slot.id != slotId)
          .toList();

      // Check if this was the last time slot
      final shouldDisableDay = currentSlots.isEmpty;

      _weekSchedule[dayIndex] = _weekSchedule[dayIndex].copyWith(
        timeSlots: currentSlots,
        isEnabled: !shouldDisableDay && _weekSchedule[dayIndex].isEnabled,
        isExpanded: !shouldDisableDay && _weekSchedule[dayIndex].isExpanded,
      );

      // time options cache removed
    });
  }

  Future<void> _updateTimeSlot(
    int dayIndex,
    String slotId, {
    String? startTime,
    String? endTime,
  }) async {
    // Don't update time slot if preferences are not loaded yet
    if (!_preferencesLoaded) {
      return;
    }

    // Show confirmation dialog for existing slots with appointments
    if (_isExistingSlot(slotId)) {
      // Find the slot to check its appointment count
      final slot = _weekSchedule[dayIndex].timeSlots.firstWhere(
        (slot) => slot.id == slotId,
        orElse: () =>
            TimeSlot(id: '', startTime: '', endTime: '', appointmentCount: '0'),
      );

      // Only show warning if there are appointments
      if (int.tryParse(slot.appointmentCount) != null &&
          int.parse(slot.appointmentCount) > 0) {
        final confirmed = await _showModificationConfirmationDialog(
          title: 'modifyTimeSlot'.translate(context),
          message: 'areYouSureYouWantToModifyThisPreDefinedTimeSlot'.translate(
            context,
          ),
        );
        if (!confirmed) return;
      }
    }

    // Basic validation: end must be after start
    if (startTime != null && endTime != null) {
      try {
        final f = DateFormat('HH:mm');
        if (!f.parse(endTime).isAfter(f.parse(startTime))) {
          HelperUtils.showSnackBarMessage(
            context,
            'endTimeMustBeAfterStartTime',
            type: .error,
          );
          return;
        }
        // Conflict validation with buffer time against existing slots
        if (_doesTimeRangeConflict(dayIndex, slotId, startTime, endTime)) {
          HelperUtils.showSnackBarMessage(
            context,
            'timeConflictsWithExistingSlots',
            type: .error,
          );
          return;
        }
      } on Exception {
        // ignore and proceed
      }
    }

    setState(() {
      final currentSlots = _weekSchedule[dayIndex].timeSlots.map((slot) {
        if (slot.id == slotId) {
          return slot.copyWith(
            startTime: startTime ?? slot.startTime,
            endTime: endTime ?? slot.endTime,
          );
        }
        return slot;
      }).toList();

      _weekSchedule[dayIndex] = _weekSchedule[dayIndex].copyWith(
        timeSlots: currentSlots,
      );
    });
  }

  Map<String, dynamic> getApiReadyScheduleData() {
    final scheduleMap = <String, dynamic>{};
    var scheduleIndex = 0;

    for (var dayIndex = 0; dayIndex < _weekSchedule.length; dayIndex++) {
      final daySchedule = _weekSchedule[dayIndex];
      if (!daySchedule.isEnabled) continue;

      final dayName = _getDayName(dayIndex);

      for (final timeSlot in daySchedule.timeSlots) {
        // Use actual slot ID for existing slots, or generate new one for new slots
        final slotId = _isExistingSlot(timeSlot.id) ? timeSlot.id : '';

        scheduleMap['schedule[$scheduleIndex][id]'] = slotId;
        scheduleMap['schedule[$scheduleIndex][day]'] = dayName;
        scheduleMap['schedule[$scheduleIndex][start_time]'] =
            timeSlot.startTime;
        scheduleMap['schedule[$scheduleIndex][end_time]'] = timeSlot.endTime;
        scheduleIndex++;
      }
    }

    // Add deleted IDs to the request
    for (var i = 0; i < _deletedSlotIds.length; i++) {
      scheduleMap['deleted_ids[$i]'] = _deletedSlotIds[i];
    }

    return scheduleMap;
  }

  String _getDayName(int dayIndex) {
    return AppointmentHelper.getApiDayName(dayIndex);
  }

  // Removed: dropdown start time generation, now using time picker

  // removed: unused conflict checker for generated dropdown ranges

  bool _doesTimeRangeConflict(
    int dayIndex,
    String slotId,
    String startTime,
    String endTime,
  ) {
    final daySchedule = _weekSchedule[dayIndex];

    for (final existingSlot in daySchedule.timeSlots) {
      if (existingSlot.id == slotId) continue;
      if (existingSlot.startTime.isEmpty || existingSlot.endTime.isEmpty) {
        continue;
      }

      try {
        final timeFormat = DateFormat('HH:mm');
        final rangeStart = timeFormat.parse(startTime);
        final rangeEnd = timeFormat.parse(endTime);
        final existingStart = timeFormat.parse(existingSlot.startTime);
        final existingEnd = timeFormat.parse(existingSlot.endTime);

        final startWithBuffer = existingStart.subtract(
          Duration(minutes: _bufferTimeMinutes ?? 0),
        );
        final endWithBuffer = existingEnd.add(
          Duration(minutes: _bufferTimeMinutes ?? 0),
        );

        if (rangeStart.isBefore(endWithBuffer) &&
            rangeEnd.isAfter(startWithBuffer)) {
          return true;
        }
      } on Exception catch (_) {
        return true;
      }
    }
    return false;
  }

  /// Check if a slot ID is from API (existing) or locally generated (new)
  bool _isExistingSlot(String slotId) {
    // API slots have numeric IDs, local slots have format "dayIndex_timestamp"
    return RegExp(r'^\d+$').hasMatch(slotId);
  }

  /// Show confirmation dialog for modifying/removing pre-defined time slots
  Future<bool> _showModificationConfirmationDialog({
    required String title,
    required String message,
  }) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => const RemoveScheduleWarning(),
        ) ??
        false;
  }

  Widget _buildSaveButton() {
    return Positioned(
      bottom: 16.rh(context),
      left: 0,
      right: 0,
      child: SizedBox(
        width: context.screenWidth,
        height: 48.rh(context),
        child: UiUtils.buildButton(
          context,
          onPressed: _saveSchedule,
          buttonTitle: 'saveSchedule'.translate(context),
        ),
      ),
    );
  }

  Future<void> _saveSchedule() async {
    if (Constant.isDemoModeOn &&
        (HiveUtils.getUserDetails().isDemoUser ?? false)) {
      return HelperUtils.showSnackBarMessage(
        context,
        'thisActionNotValidDemo',
      );
    }
    try {
      final currentState = context.read<SetAgentTimeScheduleCubit>().state;
      if (currentState is SetAgentTimeScheduleInProgress) return;

      final hasEnabledDays = _weekSchedule.any(
        (day) => day.isEnabled && day.timeSlots.isNotEmpty,
      );

      if (!hasEnabledDays) {
        HelperUtils.showSnackBarMessage(
          context,
          'pleaseEnableAtLeastOneDay',
          type: .warning,
        );
        return;
      }

      final scheduleData = getApiReadyScheduleData();
      await context.read<SetAgentTimeScheduleCubit>().setAgentTimeSchedule(
        parameters: scheduleData,
      );
    } on Exception catch (e) {
      HelperUtils.showSnackBarMessage(
        context,
        e.toString(),
        type: .error,
      );
    }
  }
}
