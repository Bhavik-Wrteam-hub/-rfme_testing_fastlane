import 'package:ebroker/data/cubits/appointment/get/fetch_agent_time_schedules_cubit.dart';
import 'package:ebroker/data/cubits/appointment/get/fetch_booking_preferences_cubit.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/appointment/configuration_screens/all_schedules_screen.dart';
import 'package:ebroker/ui/screens/appointment/configuration_screens/booking_preferences.dart';
import 'package:ebroker/ui/screens/appointment/configuration_screens/set_business_hours_screen.dart';
import 'package:ebroker/utils/custom_tabbar.dart';
import 'package:flutter/material.dart';

class AppointmentConfigurationScreen extends StatefulWidget {
  const AppointmentConfigurationScreen({super.key});

  static Route<dynamic> route(RouteSettings routeSettings) {
    return CupertinoPageRoute(
      builder: (context) => const AppointmentConfigurationScreen(),
    );
  }

  @override
  State<AppointmentConfigurationScreen> createState() =>
      _AppointmentConfigurationScreenState();
}

class _AppointmentConfigurationScreenState
    extends State<AppointmentConfigurationScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  Future<void> _onTabChanged() async {
    if (_tabController.indexIsChanging) {
      // User is trying to change tabs
      if (_tabController.index != 0) {
        // Trying to switch away from booking preferences tab
        if (!_areBookingPreferencesValid()) {
          // Prevent tab change and show warning
          await _showValidationWarning();
          // Reset to booking preferences tab
          _tabController.animateTo(0);
        }
      }
    }
  }

  bool _areBookingPreferencesValid() {
    final bookingPrefsState = context
        .read<FetchBookingPreferencesCubit>()
        .state;

    if (bookingPrefsState is! FetchBookingPreferencesSuccess) {
      return false;
    }

    final preferences = bookingPrefsState.bookingPreferences;

    // Check all required fields except autoConfirm
    return preferences.meetingDurationMinutes.isNotEmpty &&
        preferences.bufferTimeMinutes.isNotEmpty &&
        preferences.leadTimeMinutes.isNotEmpty &&
        preferences.availableMeetingTypes.isNotEmpty;
  }

  Future<void> _showValidationWarning() async {
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 48.rw(context)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        backgroundColor: context.color.secondaryColor,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.color.secondaryColor,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: context.color.borderColor),
          ),
          child: Column(
            mainAxisSize: .min,
            crossAxisAlignment: .start,
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  CustomText(
                    'incomplete'.translate(context),
                    color: context.color.textColorDark,
                    fontSize: context.font.lg,
                    fontWeight: .w600,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: CustomImage(
                      imageUrl: AppIcons.closeCircle,
                      color: context.color.textColorDark,
                      fit: .contain,
                      height: 24.rh(context),
                      width: 24.rw(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              UiUtils.getDivider(context),
              const SizedBox(height: 16),
              CustomText(
                'pleaseFillAllFieldsInBookingPreferences'.translate(context),
                color: context.color.textColorDark,
                fontSize: context.font.md,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      FetchBookingPreferencesCubit,
      FetchBookingPreferencesState
    >(
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            clearAppointmentCubits();
            Navigator.pop(context);
          },
          child: Scaffold(
            backgroundColor: context.color.primaryColor,
            appBar: CustomAppBar(
              title: 'appointmentConfiguration'.translate(context),
              onTapBackButton: clearAppointmentCubits,
            ),
            body: Column(
              children: [
                CustomTabBar(
                  isScrollable: true,
                  tabController: _tabController,
                  tabs: [
                    Tab(text: 'bookingPreferences'.translate(context)),
                    Tab(text: 'setBusinessHours'.translate(context)),
                    Tab(text: 'allSchedules'.translate(context)),
                  ],
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TabBarView(
                      physics: const NeverScrollableScrollPhysics(),
                      controller: _tabController,
                      children: const [
                        BookingPreferecesScreen(),
                        SetBusinessHoursScreen(),
                        AllSchedulesScreen(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void clearAppointmentCubits() {
    context.read<FetchBookingPreferencesCubit>().clear();
    context.read<FetchAgentTimeSchedulesCubit>().clear();
  }
}
