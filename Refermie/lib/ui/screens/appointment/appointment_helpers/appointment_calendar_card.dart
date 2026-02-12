import 'package:ebroker/data/model/appointment/agent_time_schedule_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/appointment_calendar_styles.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/appointment_card_container.dart';
import 'package:table_calendar/table_calendar.dart';

/// Reusable calendar card component for appointment screens
class AppointmentCalendarCard extends StatelessWidget {
  const AppointmentCalendarCard({
    required this.focusedDay,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.isFromAllSchedules,
    this.selectedDay,
    this.firstDay,
    this.lastDay,
    this.enabledDayPredicate,
    this.showHeader = false,
    this.headerTitle,
    this.timeSchedules,
    this.extraSlots,
    this.availableDateKeys,
    super.key,
  });

  final DateTime focusedDay;
  final DateTime? selectedDay;
  final DateTime? firstDay;
  final DateTime? lastDay;
  final bool isFromAllSchedules;
  final void Function(DateTime, DateTime) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final bool Function(DateTime)? enabledDayPredicate;
  final bool showHeader;
  final String? headerTitle;
  final List<TimeSchedule>? timeSchedules;
  final List<ExtraSlot>? extraSlots;
  // Dates with availability in 'yyyy-MM-dd' format (used in booking flow)
  final List<String>? availableDateKeys;

  @override
  Widget build(BuildContext context) {
    return AppointmentCardContainer(
      child: Column(
        mainAxisSize: .min,
        crossAxisAlignment: .start,
        children: [
          if (showHeader) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              child: CustomText(
                headerTitle ?? 'selectDate'.translate(context),
                color: context.color.textColorDark,
                fontSize: context.font.sm,
                fontWeight: .w500,
              ),
            ),
          ],
          TableCalendar<dynamic>(
            firstDay: firstDay ?? DateTime(2020),
            lastDay: lastDay ?? DateTime(2030),
            focusedDay: focusedDay,
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            locale: HiveUtils.getLanguageCode(),
            enabledDayPredicate: enabledDayPredicate,
            daysOfWeekHeight: 48.rh(context),
            daysOfWeekStyle: AppointmentCalendarStyles.buildDaysOfWeekStyle(
              context,
            ),
            availableGestures: AvailableGestures.none,
            headerStyle: AppointmentCalendarStyles.buildHeaderStyle(context),
            calendarStyle: AppointmentCalendarStyles.buildCalendarStyle(
              context,
              isFromAllSchedules: isFromAllSchedules,
              timeSchedules: timeSchedules,
              extraSlots: extraSlots,
            ),
            onDaySelected: onDaySelected,
            onPageChanged: onPageChanged,
            calendarBuilders: CalendarBuilders(
              selectedBuilder: AppointmentCalendarStyles.selectedBuilder,
              todayBuilder: AppointmentCalendarStyles.todayBuilder,
              defaultBuilder: (context, day, focusedDay) =>
                  AppointmentCalendarStyles.defaultBuilder(
                    context,
                    day,
                    focusedDay,
                    isFromAllSchedules: isFromAllSchedules,
                    timeSchedules: timeSchedules,
                    extraSlots: extraSlots,
                    availableDateKeys: availableDateKeys,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
