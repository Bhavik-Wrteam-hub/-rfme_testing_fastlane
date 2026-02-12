import 'dart:async';

import 'package:ebroker/data/cubits/appointment/get/fetch_agent_time_schedules_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_booking_preferences_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/manage_extra_time_slot_cubit.dart';
import 'package:ebroker/data/model/appointment/agent_time_schedule_model.dart';
import 'package:ebroker/data/model/appointment/booking_preferences_model.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/appointment_widgets_export.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AllSchedulesScreen extends StatefulWidget {
  const AllSchedulesScreen({super.key});

  @override
  State<AllSchedulesScreen> createState() => _AllSchedulesScreenState();
}

class _AllSchedulesScreenState extends State<AllSchedulesScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  List<ExtraSlot> _extraSlots = [];
  List<TimeSchedule> _timeSchedules = [];
  late BookingPreferencesModel _bookingPreferences;
  bool _isInitialized = false;
  bool _preferencesLoaded = false;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    // Load data after the widget is built and context is available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    if (_isInitialized || !mounted) return;

    // Check if data is already available from global cubit
    final cubit = context.read<FetchAgentTimeSchedulesCubit>();
    if (cubit.state is FetchAgentTimeSchedulesSuccess) {
      final state = cubit.state as FetchAgentTimeSchedulesSuccess;
      setState(() {
        _extraSlots = state.schedules.extraSlots;
        _timeSchedules = state.schedules.timeSchedules;
      });
    }

    // Check if booking preferences are already available
    final bookingCubit = context.read<FetchBookingPreferencesCubit>();
    if (bookingCubit.state is FetchBookingPreferencesSuccess) {
      final state = bookingCubit.state as FetchBookingPreferencesSuccess;
      setState(() {
        _bookingPreferences = state.bookingPreferences;
        _preferencesLoaded = true;
      });
    } else {
      await bookingCubit.fetchBookingPreferences();
    }

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  bool _isDateAvailable(DateTime date) {
    // Don't allow dates before today
    final today = DateTime.now();
    final dateOnly = DateTime(date.year, date.month, date.day);
    final todayOnly = DateTime(today.year, today.month, today.day);

    // Allow today and future dates
    return !dateOnly.isBefore(todayOnly);
  }

  List<TimeSchedule> _getTimeSchedulesForDate(DateTime date) {
    if (_selectedDay == null) return [];

    final dayOfWeek = _getDayOfWeekFromDate(date);
    final timeSchedules = _timeSchedules
        .where(
          (schedule) =>
              schedule.dayOfWeek.toLowerCase() == dayOfWeek &&
              schedule.isActive == '1',
        )
        .toList();
    return timeSchedules;
  }

  List<ExtraSlot> _getExtraSlotsForDate(DateTime date) {
    if (_selectedDay == null) return [];

    final dateString = DateFormat('yyyy-MM-dd').format(date);
    final extraSlots = _extraSlots
        .where((slot) => slot.date == dateString)
        .toList();
    return extraSlots;
  }

  String _getDayOfWeekFromDate(DateTime date) {
    const days = [
      'sunday',
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
    ];
    return days[date.weekday % 7];
  }

  String _formatTimeFromApi(String apiTime) {
    try {
      return apiTime.length >= 5 ? apiTime.substring(0, 5) : apiTime;
    } on Exception catch (_) {
      return apiTime;
    }
  }

  Future<void> _showExtraSlotDialog() async {
    if (Constant.isDemoModeOn &&
        (HiveUtils.getUserDetails().isDemoUser ?? false)) {
      HelperUtils.showSnackBarMessage(
        context,
        'thisActionNotValidDemo',
      );
      return;
    }
    await showDialog<dynamic>(
      context: context,
      builder: (context) => ExtraHoursDialog(
        selectedDate: _selectedDay!,
        existingSlot: _getExtraSlotsForDate(_selectedDay!).firstOrNull,
        bookingPreferences: _bookingPreferences,
        existingTimeSlots: _getTimeSchedulesForDate(_selectedDay!),
        extraSlots: _getExtraSlotsForDate(_selectedDay!),
        onSave: () async {
          await context
              .read<FetchAgentTimeSchedulesCubit>()
              .fetchAgentTimeSchedules(
                forceRefresh: true,
              );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        final cubit = context.read<FetchAgentTimeSchedulesCubit>();
        // Trigger the API calls using the global cubit instances
        if (!_isInitialized) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            // Only fetch if not already loading or if we need to refresh
            if (cubit.state is FetchAgentTimeSchedulesInitial ||
                cubit.state is FetchAgentTimeSchedulesFailure) {
              await cubit.fetchAgentTimeSchedules(forceRefresh: true);
            }
            // Always try to fetch booking preferences if not already loaded
            final bookingCubit = context.read<FetchBookingPreferencesCubit>();
            if (bookingCubit.state is! FetchBookingPreferencesSuccess) {
              await bookingCubit.fetchBookingPreferences();
            }
          });
        }

        return MultiBlocListener(
          listeners: [
            BlocListener<
              FetchAgentTimeSchedulesCubit,
              FetchAgentTimeSchedulesState
            >(
              listener: (context, state) {
                if (state is FetchAgentTimeSchedulesSuccess) {
                  setState(() {
                    _extraSlots = state.schedules.extraSlots;
                    _timeSchedules = state.schedules.timeSchedules;
                  });
                }
              },
            ),
            BlocListener<
              FetchBookingPreferencesCubit,
              FetchBookingPreferencesState
            >(
              listener: (context, state) {
                if (state is FetchBookingPreferencesSuccess) {
                  setState(() {
                    _bookingPreferences = state.bookingPreferences;
                    _preferencesLoaded = true;
                  });
                }
              },
            ),
            BlocListener<ManageExtraTimeSlotCubit, ManageExtraTimeSlotState>(
              listener: (context, state) {
                if (state is ManageExtraTimeSlotSuccess) {
                  HelperUtils.showSnackBarMessage(
                    context,
                    'extraTimeSlotsUpdatedSuccessfully',
                    type: .success,
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
          ],
          child:
              BlocBuilder<
                FetchAgentTimeSchedulesCubit,
                FetchAgentTimeSchedulesState
              >(
                builder: (context, fetchState) {
                  if (fetchState is FetchAgentTimeSchedulesLoading ||
                      !_preferencesLoaded) {
                    return AppointmentHelper.calendarShimmer();
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        AppointmentCalendarCard(
                          isFromAllSchedules: true,
                          focusedDay: _focusedDay,
                          selectedDay: _selectedDay,
                          firstDay:
                              DateTime.now(), // Prevent selecting past dates
                          timeSchedules: _timeSchedules,
                          extraSlots: _extraSlots,
                          onDaySelected: (selectedDay, focusedDay) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                            });
                          },
                          onPageChanged: (focusedDay) {
                            setState(() {
                              _focusedDay = focusedDay;
                            });
                          },
                          enabledDayPredicate: _isDateAvailable,
                        ),
                        const SizedBox(height: 16),
                        if (_selectedDay != null) ...[
                          _buildTimeSchedulesCard(),
                          const SizedBox(height: 16),
                          _buildExtraSlotsCard(),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  );
                },
              ),
        );
      },
    );
  }

  Widget _buildTimeSchedulesCard() {
    final timeSchedules = _getTimeSchedulesForDate(_selectedDay!);

    return AppointmentCardContainer(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: CustomText(
              '${'timeSlot'.translate(context)} - ${AppointmentHelper.formatDate(_selectedDay!, format: 'dd MMMM, yyyy')}',
              color: context.color.textColorDark,
              fontSize: context.font.md,
              fontWeight: .w500,
            ),
          ),
          UiUtils.getDivider(context),
          if (timeSchedules.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomText(
                'noTimeSlotsAvailableForThisDay'.translate(context),
                color: context.color.textLightColor,
                fontSize: context.font.sm,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: timeSchedules.map((schedule) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: CustomText(
                      '${AppointmentHelper.formatTimeToAmPm(_formatTimeFromApi(schedule.startTime))} to ${AppointmentHelper.formatTimeToAmPm(_formatTimeFromApi(schedule.endTime))}',
                      color: context.color.textColorDark,
                      fontSize: context.font.sm,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExtraSlotsCard() {
    final extraSlots = _getExtraSlotsForDate(_selectedDay!);

    return AppointmentCardContainer(
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: CustomText(
                    'dateScheduleTimeSlots'.translate(context),
                    color: context.color.textColorDark,
                    fontSize: context.font.md,
                    fontWeight: .w500,
                  ),
                ),
                GestureDetector(
                  onTap: _showExtraSlotDialog,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: context.color.borderColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: CustomImage(
                      imageUrl: AppIcons.edit,
                      width: 20.rw(context),
                      height: 20.rh(context),
                      color: context.color.textColorDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          UiUtils.getDivider(context),
          if (extraSlots.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: CustomText(
                'noExtraTimeSlotsForThisDate'.translate(context),
                color: context.color.textLightColor,
                fontSize: context.font.sm,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: extraSlots.map((slot) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildExtraSlotItem(slot),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildExtraSlotItem(ExtraSlot slot) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: context.color.borderColor.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            AppointmentHelper.formatDate(
              DateTime.parse(slot.date),
              format: 'dd MMM, yyyy',
            ),
            color: context.color.textColorDark,
            fontSize: context.font.sm,
            fontWeight: .w500,
          ),
          const SizedBox(height: 4),
          CustomText(
            '${AppointmentHelper.formatTimeToAmPm(slot.startTime)} - ${AppointmentHelper.formatTimeToAmPm(slot.endTime)}',
            color: context.color.textLightColor,
            fontSize: context.font.sm,
          ),
          if (slot.reason.isNotEmpty) ...[
            const SizedBox(height: 4),
            CustomText(
              slot.reason,
              color: context.color.textLightColor,
              fontSize: context.font.xs,
            ),
          ],
        ],
      ),
    );
  }
}
