import 'package:ebroker/data/model/appointment/agent_time_schedule_model.dart';
import 'package:ebroker/utils/app_icons.dart';
import 'package:ebroker/utils/custom_image.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;

import 'package:table_calendar/table_calendar.dart';

/// Centralized calendar styles for appointment screens
class AppointmentCalendarStyles {
  // Check if a date has any active schedules (by weekday) or extra slots (by exact date)
  static bool _hasSchedulesOrExtraSlots(
    DateTime date,
    List<TimeSchedule>? timeSchedules,
    List<ExtraSlot>? extraSlots,
  ) {
    if (timeSchedules == null && extraSlots == null) return false;

    final dayOfWeek = _getDayOfWeekFromDate(date);
    final dateString = DateFormat('yyyy-MM-dd').format(date);

    // Active schedules for the weekday
    final hasActiveScheduleForWeekday =
        timeSchedules?.any(
          (schedule) =>
              schedule.dayOfWeek.toLowerCase() == dayOfWeek &&
              schedule.isActive == '1',
        ) ??
        false;

    // Extra slots for the date
    final hasExtraSlotForDate =
        extraSlots?.any((slot) => slot.date == dateString) ?? false;

    return hasActiveScheduleForWeekday || hasExtraSlotForDate;
  }

  static String _getDayOfWeekFromDate(DateTime date) {
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

  static CalendarStyle buildCalendarStyle(
    BuildContext context, {
    required bool isFromAllSchedules,
    List<TimeSchedule>? timeSchedules,
    List<ExtraSlot>? extraSlots,
  }) {
    return CalendarStyle(
      todayTextStyle: TextStyle(color: context.color.tertiaryColor),
      todayDecoration: BoxDecoration(
        shape: .circle,
        border: Border.all(color: context.color.tertiaryColor),
      ),
      outsideDaysVisible: false,
      cellMargin: EdgeInsets.zero,
      tablePadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      tableBorder: TableBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(12.rh(context)),
        ),
      ),
      defaultTextStyle: TextStyle(
        color: context.color.textColorDark,
        fontSize: context.font.sm,
        fontWeight: .w400,
      ),
      selectedTextStyle: TextStyle(
        color: context.color.buttonColor,
        fontSize: context.font.md,
        fontWeight: .w500,
      ),
      selectedDecoration: BoxDecoration(
        color: context.color.tertiaryColor,
        shape: .circle,
      ),
      disabledDecoration: BoxDecoration(
        color: context.color.textLightColor.withValues(alpha: .2),
        // Keep as rectangle for disabled days
      ),
      disabledTextStyle: TextStyle(
        color: context.color.textLightColor,
        fontSize: context.font.sm,
      ),
      weekendTextStyle: TextStyle(
        color: context.color.textLightColor,
        fontSize: context.font.sm,
      ),
      holidayTextStyle: TextStyle(
        color: context.color.tertiaryColor.withValues(alpha: .7),
        fontSize: context.font.sm,
      ),
    );
  }

  // Custom builder for selected days with margin
  static Widget? selectedBuilder(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
  ) {
    return Container(
      margin: const EdgeInsets.all(4), // Only selected days get margin
      decoration: BoxDecoration(
        color: context.color.tertiaryColor,
        shape: .circle,
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: context.color.buttonColor,
            fontSize: context.font.md,
            fontWeight: .w500,
          ),
        ),
      ),
    );
  }

  // Custom builder for today with margin
  static Widget? todayBuilder(
    BuildContext context,
    DateTime day,
    DateTime focusedDay,
  ) {
    return Container(
      margin: const EdgeInsets.all(4), // Only today gets margin
      decoration: BoxDecoration(
        shape: .circle,
        border: Border.all(color: context.color.tertiaryColor),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(color: context.color.tertiaryColor),
        ),
      ),
    );
  }

  // Custom builder for default days with conditional bottom border
  static Widget? defaultBuilder(
    BuildContext context,
    DateTime day,
    DateTime focusedDay, {
    required bool isFromAllSchedules,
    List<TimeSchedule>? timeSchedules,
    List<ExtraSlot>? extraSlots,
    List<String>? availableDateKeys,
  }) {
    final hasAppointments =
        isFromAllSchedules &&
        _hasSchedulesOrExtraSlots(day, timeSchedules, extraSlots);

    // Also mark days that are available (booking flow monthly slots)
    final isAvailableDay =
        (availableDateKeys != null &&
            availableDateKeys.contains(DateFormat('yyyy-MM-dd').format(day))) ||
        hasAppointments;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: isAvailableDay
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border(
                bottom: BorderSide(
                  color: context.color.tertiaryColor,
                  width: 2,
                ),
              ),
            )
          : const BoxDecoration(shape: .circle),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: context.color.textColorDark,
            fontSize: context.font.sm,
            fontWeight: .w400,
          ),
        ),
      ),
    );
  }

  static HeaderStyle buildHeaderStyle(BuildContext context) {
    final arrow = Transform.flip(
      flipX: Directionality.of(context) == .rtl,
      child: CustomImage(
        imageUrl: AppIcons.arrowRight,
        height: 24.rh(context),
        width: 24.rw(context),
        color: context.color.textColorDark,
      ),
    );

    return HeaderStyle(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: context.color.borderColor),
          bottom: BorderSide(color: context.color.borderColor),
        ),
      ),
      titleCentered: true,
      titleTextStyle: TextStyle(
        color: context.color.textColorDark,
        fontSize: context.font.md,
        fontWeight: .w500,
      ),
      headerPadding: EdgeInsets.symmetric(
        horizontal: 12.rw(context),
        vertical: 4.rh(context),
      ),
      formatButtonVisible: false,
      rightChevronIcon: arrow,
      leftChevronIcon: Transform.flip(flipX: true, child: arrow),
      titleTextFormatter: (date, locale) =>
          DateFormat.yMMMM(locale).format(date),
    );
  }

  static DaysOfWeekStyle buildDaysOfWeekStyle(BuildContext context) {
    return DaysOfWeekStyle(
      dowTextFormatter: (date, locale) => DateFormat.E(locale).format(date)[0],
      weekdayStyle: TextStyle(
        color: context.color.textColorDark,
        fontSize: context.font.md,
        fontWeight: .w400,
      ),
      weekendStyle: TextStyle(
        color: context.color.textColorDark,
        fontSize: context.font.md,
        fontWeight: .w400,
      ),
    );
  }
}
