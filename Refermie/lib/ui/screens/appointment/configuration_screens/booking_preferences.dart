import 'dart:async';

import 'package:ebroker/data/cubits/appointment/get/fetch_booking_preferences_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/update_booking_preferences_cubit.dart';
import 'package:ebroker/data/model/appointment/booking_preferences_model.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/appointment_widgets_export.dart';
import 'package:ebroker/ui/screens/widgets/errors/something_went_wrong.dart';
import 'package:ebroker/utils/constant.dart';
import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class BookingPreferecesScreen extends StatefulWidget {
  const BookingPreferecesScreen({super.key});

  @override
  State<BookingPreferecesScreen> createState() =>
      _BookingPreferecesScreenState();
}

class _BookingPreferecesScreenState extends State<BookingPreferecesScreen> {
  late BookingPreferencesModel _preferences;
  final TextEditingController _meetingDurationController =
      TextEditingController();
  final TextEditingController _bufferTimeController = TextEditingController();
  final TextEditingController _dailyLimitController = TextEditingController();
  final TextEditingController _cancelRescheduleBufferController =
      TextEditingController();
  final TextEditingController _minAdvanceBookingController =
      TextEditingController();
  final TextEditingController _autoCancelController = TextEditingController();
  final TextEditingController _autoCancelMessageController =
      TextEditingController();

  bool _autoConfirm = false;
  String _selectedTimezone = 'UTC';
  List<String> _selectedAvailabilityType = [];
  bool _isDataLoaded = false;

  // Form validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? _meetingDurationError;
  String? _bufferTimeError;
  String? _minAdvanceBookingError;
  String? _autoCancelError;
  String? _availabilityTypeError;
  String? _cancelRescheduleBufferError;
  String? _dailyLimitError;

  @override
  void initState() {
    super.initState();
    unawaited(fetchBookingPreferences(isFromInitial: true));
    _minAdvanceBookingController.text = '';

    // Add listeners to clear errors when user starts typing
    _meetingDurationController.addListener(() {
      if (_meetingDurationError != null) {
        setState(() => _meetingDurationError = null);
      }
    });

    _bufferTimeController.addListener(() {
      if (_bufferTimeError != null) {
        setState(() => _bufferTimeError = null);
      }
    });

    _minAdvanceBookingController.addListener(() {
      if (_minAdvanceBookingError != null) {
        setState(() => _minAdvanceBookingError = null);
      }
    });

    _autoCancelController.addListener(() {
      if (_autoCancelError != null) {
        setState(() => _autoCancelError = null);
      }
    });

    _cancelRescheduleBufferController.addListener(() {
      if (_cancelRescheduleBufferError != null) {
        setState(() => _cancelRescheduleBufferError = null);
      }
    });

    _dailyLimitController.addListener(() {
      if (_dailyLimitError != null) {
        setState(() => _dailyLimitError = null);
      }
    });
  }

  Future<void> fetchBookingPreferences({required bool isFromInitial}) async {
    _isDataLoaded = false;
    if (context.read<FetchBookingPreferencesCubit>().state
            is FetchBookingPreferencesSuccess &&
        isFromInitial) {
      return;
    }
    await context
        .read<FetchBookingPreferencesCubit>()
        .fetchBookingPreferences();
  }

  Future<void> _validateForm() async {
    if (Constant.isDemoModeOn &&
        (HiveUtils.getUserDetails().isDemoUser ?? false)) {
      HelperUtils.showSnackBarMessage(
        context,
        'thisActionNotValidDemo',
      );
      return;
    }
    setState(() {
      _meetingDurationError = null;
      _bufferTimeError = null;
      _minAdvanceBookingError = null;
      _autoCancelError = null;
      _availabilityTypeError = null;
      _cancelRescheduleBufferError = null;
      _dailyLimitError = null;
    });

    var isValid = true;

    // Validate meeting duration
    if (_meetingDurationController.text.trim().isEmpty) {
      setState(
        () => _meetingDurationError = 'meetingDurationRequired'.translate(
          context,
        ),
      );
      isValid = false;
    } else if (int.tryParse(_meetingDurationController.text.trim()) == null ||
        int.parse(_meetingDurationController.text.trim()) < 15 ||
        int.parse(_meetingDurationController.text.trim()) > 480) {
      setState(
        () => _meetingDurationError = 'meetingDurationOutOfRange'.translate(
          context,
        ),
      );
      isValid = false;
    }

    // Validate buffer time
    if (_bufferTimeController.text.trim().isEmpty) {
      setState(
        () => _bufferTimeError = 'bufferTimeRequired'.translate(context),
      );
      isValid = false;
    } else if (int.tryParse(_bufferTimeController.text.trim()) == null ||
        int.parse(_bufferTimeController.text.trim()) < 0 ||
        int.parse(_bufferTimeController.text.trim()) > 120) {
      setState(
        () => _bufferTimeError = 'bufferTimeOutOfRange'.translate(context),
      );
      isValid = false;
    }

    // Validate min advance booking time
    if (_minAdvanceBookingController.text.trim().isEmpty) {
      setState(
        () => _minAdvanceBookingError = 'minAdvanceBookingRequired'.translate(
          context,
        ),
      );
      isValid = false;
    } else if (int.tryParse(_minAdvanceBookingController.text.trim()) == null ||
        int.parse(_minAdvanceBookingController.text.trim()) < 0 ||
        int.parse(_minAdvanceBookingController.text.trim()) > 10080) {
      setState(
        () => _minAdvanceBookingError = 'minAdvanceBookingOutOfRange'.translate(
          context,
        ),
      );
      isValid = false;
    }

    // Validate cancel/reschedule buffer time
    if (_cancelRescheduleBufferController.text.trim().isEmpty) {
      setState(
        () => _cancelRescheduleBufferError = 'cancelRescheduleBufferRequired'
            .translate(context),
      );
      isValid = false;
    } else if (int.tryParse(_cancelRescheduleBufferController.text.trim()) ==
            null ||
        int.parse(_cancelRescheduleBufferController.text.trim()) < 0 ||
        int.parse(_cancelRescheduleBufferController.text.trim()) > 1440) {
      setState(
        () => _cancelRescheduleBufferError = 'cancelRescheduleBufferOutOfRange'
            .translate(context),
      );
      isValid = false;
    }

    // Validate auto cancel time
    if (_autoCancelController.text.trim().isEmpty) {
      setState(
        () => _autoCancelError = 'autoCancelTimeRequired'.translate(context),
      );
      isValid = false;
    } else if (int.tryParse(_autoCancelController.text.trim()) == null ||
        int.parse(_autoCancelController.text.trim()) < 0 ||
        int.parse(_autoCancelController.text.trim()) > 10080) {
      setState(
        () => _autoCancelError = 'autoCancelTimeOutOfRange'.translate(context),
      );
      isValid = false;
    }

    // Validate daily booking limit (optional)
    if (_dailyLimitController.text.trim().isNotEmpty) {
      if (int.tryParse(_dailyLimitController.text.trim()) == null ||
          int.parse(_dailyLimitController.text.trim()) < 1 ||
          int.parse(_dailyLimitController.text.trim()) > 100) {
        setState(
          () => _dailyLimitError = 'dailyBookingLimitOutOfRange'.translate(
            context,
          ),
        );
        isValid = false;
      }
    }

    // Validate availability types
    if (_selectedAvailabilityType.isEmpty ||
        _selectedAvailabilityType.every((type) => type.trim().isEmpty)) {
      setState(
        () => _availabilityTypeError = 'availabilityTypeRequired'.translate(
          context,
        ),
      );
      isValid = false;
    }

    if (isValid) {
      await _saveConfiguration();
    }
  }

  @override
  void dispose() {
    _meetingDurationController.dispose();
    _bufferTimeController.dispose();
    _dailyLimitController.dispose();
    _cancelRescheduleBufferController.dispose();
    _autoCancelController.dispose();
    _autoCancelMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      FetchBookingPreferencesCubit,
      FetchBookingPreferencesState
    >(
      builder: (context, state) {
        if (state is FetchBookingPreferencesLoading) {
          return AppointmentHelper.buildShimmer();
        }
        if (state is FetchBookingPreferencesFailure) {
          return SomethingWentWrong(
            errorMessage: state.errorMessage.toString(),
          );
        }
        if (state is FetchBookingPreferencesSuccess) {
          _preferences = state.bookingPreferences;
          // Only update the state if it hasn't been loaded yet
          if (!_isDataLoaded) {
            _autoConfirm = _preferences.autoConfirm == '1';
            // Validate timezone - use UTC as fallback if timezone is not in the options list
            _selectedTimezone =
                AppointmentHelper.timezoneOptions.contains(
                  _preferences.timezone,
                )
                ? _preferences.timezone
                : 'UTC';
            _minAdvanceBookingController.text = _preferences.leadTimeMinutes;
            _meetingDurationController.text =
                _preferences.meetingDurationMinutes;
            _bufferTimeController.text = _preferences.bufferTimeMinutes;
            _dailyLimitController.text = _preferences.dailyBookingLimit;
            _cancelRescheduleBufferController.text =
                _preferences.cancelRescheduleBufferMinutes;
            _autoCancelController.text = _preferences.autoCancelAfterMinutes;
            _autoCancelMessageController.text = _preferences.autoCancelMessage;
            _selectedAvailabilityType = _preferences.availableMeetingTypes
                .split(',')
                .where((type) => type.trim().isNotEmpty)
                .toList();
            _isDataLoaded = true;
          }

          return Stack(
            children: [
              SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildAutoConfirmCard(),
                      _buildSetBufferTimeCard(),
                      _buildDefaultMeetingDurationCard(),
                      _buildCancelRescheduleBufferCard(),
                      _buildAutoCancelCard(),
                      _buildCancellationMessageCard(),
                      _buildMinAdvanceBookingTimeCard(),
                      _buildMaxBookingsPerDayCard(),
                      _buildSelectMeetingCard(),
                      _buildTimezoneDropdown(),
                      const SizedBox(height: kBottomNavigationBarHeight + 16),
                    ],
                  ),
                ),
              ),
              _buildSavePreferencesButton(),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildCancelRescheduleBufferCard() {
    return AppointmentCardContainer(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          AppointmentTitleDescription(
            title: 'cancelRescheduleBufferMinutes'.translate(context),
            isRequired: true,
            description: 'minTimeBeforeAppointmentToCancelReschedule'.translate(
              context,
            ),
          ),
          const SizedBox(height: 12),
          AppointmentInputField(
            keyboardType: TextInputType.number,
            controller: _cancelRescheduleBufferController,
          ),
          if (_cancelRescheduleBufferError != null) ...[
            const SizedBox(height: 8),
            CustomText(
              _cancelRescheduleBufferError!,
              color: Colors.red,
              fontSize: 12,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoConfirmCard() {
    return AppointmentCardContainer(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: .spaceBetween,
        children: [
          Expanded(
            child: AppointmentTitleDescription(
              title: 'autoConfirmAppointments'.translate(context),
              isRequired: false,
              description:
                  'enableThisOptionToAutomaticallyConfirmAppointmentsWhenAClientBooksThem'
                      .translate(context),
            ),
          ),
          Container(
            width: 1,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            height: 56.rh(context),
            color: context.color.borderColor,
          ),
          AppointmentSwitch(
            value: _autoConfirm,
            onChanged: (value) => setState(() => _autoConfirm = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSetBufferTimeCard() {
    return AppointmentCardContainer(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          AppointmentTitleDescription(
            title: 'bufferTimeMinutes'.translate(context),
            isRequired: true,
            description: 'setTheBufferTimeInMinutesBeforeAnAppointmentStarts'
                .translate(context),
          ),
          const SizedBox(height: 12),
          AppointmentInputField(
            keyboardType: TextInputType.number,
            controller: _bufferTimeController,
          ),
          if (_bufferTimeError != null) ...[
            const SizedBox(height: 8),
            CustomText(
              _bufferTimeError!,
              color: Colors.red,
              fontSize: 12,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDefaultMeetingDurationCard() {
    return AppointmentCardContainer(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          AppointmentTitleDescription(
            title: 'meetingDurationMinutes'.translate(context),
            isRequired: true,
            description: 'setTheDefaultDurationOfAppointmentsInMinutes'
                .translate(context),
          ),
          const SizedBox(height: 12),
          AppointmentInputField(
            keyboardType: TextInputType.number,
            controller: _meetingDurationController,
          ),
          if (_meetingDurationError != null) ...[
            const SizedBox(height: 8),
            CustomText(
              _meetingDurationError!,
              color: Colors.red,
              fontSize: 12,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAutoCancelCard() {
    return AppointmentCardContainer(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          AppointmentTitleDescription(
            title: 'autoCancelAfterMinutes'.translate(context),
            isRequired: true,
            description:
                'setTheNumberOfMinutesAfterAnAppointmentThatItWillBeAutomaticallyCancelledIfNoResponseIsReceived'
                    .translate(context),
          ),
          const SizedBox(height: 12),
          AppointmentInputField(
            keyboardType: TextInputType.number,
            controller: _autoCancelController,
          ),
          if (_autoCancelError != null) ...[
            const SizedBox(height: 8),
            CustomText(
              _autoCancelError!,
              color: Colors.red,
              fontSize: 12,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCancellationMessageCard() {
    return AppointmentCardContainer(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          AppointmentTitleDescription(
            title: 'cancellationMessage'.translate(context),
            isRequired: false,
          ),
          const SizedBox(height: 12),
          AppointmentInputField(
            keyboardType: TextInputType.text,
            controller: _autoCancelMessageController,
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildMinAdvanceBookingTimeCard() {
    return AppointmentCardContainer(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          AppointmentTitleDescription(
            title: 'minAdvanceBookingTimeMinutes'.translate(context),
            isRequired: true,
            description:
                'setTheMinimumNumberOfMinutesInAdvanceThatAClientMustBookAnAppointmentWithYou'
                    .translate(context),
          ),
          const SizedBox(height: 12),
          AppointmentInputField(
            keyboardType: TextInputType.number,
            controller: _minAdvanceBookingController,
          ),
          if (_minAdvanceBookingError != null) ...[
            const SizedBox(height: 8),
            CustomText(
              _minAdvanceBookingError!,
              color: Colors.red,
              fontSize: 12,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMaxBookingsPerDayCard() {
    return AppointmentCardContainer(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          AppointmentTitleDescription(
            title: 'maxBookingsPerDay'.translate(context),
            isRequired: false,
            description: 'setTheMaximumNumberOfAppointmentsYouCanHavePerDay'
                .translate(context),
          ),
          const SizedBox(height: 12),
          AppointmentInputField(
            keyboardType: TextInputType.number,
            controller: _dailyLimitController,
          ),
          if (_dailyLimitError != null) ...[
            const SizedBox(height: 8),
            CustomText(
              _dailyLimitError!,
              color: Colors.red,
              fontSize: 12,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectMeetingCard() {
    // CheckBox in row
    return AppointmentCardContainer(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          AppointmentTitleDescription(
            title: 'selectMeetingType'.translate(context),
            isRequired: true,
            description: 'selectTheTypesOfMeetingsYouAreAvailableFor'.translate(
              context,
            ),
          ),
          const SizedBox(height: 12),
          UiUtils.getDivider(context),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildCheckBox('inPerson'.translate(context), 'in_person'),
              _buildCheckBox('virtual'.translate(context), 'virtual'),
              _buildCheckBox('phone'.translate(context), 'phone'),
            ],
          ),
          if (_availabilityTypeError != null) ...[
            const SizedBox(height: 8),
            CustomText(
              _availabilityTypeError!,
              color: Colors.red,
              fontSize: 12,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckBox(String label, String value) {
    final isSelected = _selectedAvailabilityType.contains(value);
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              if (_selectedAvailabilityType.contains(value)) {
                _selectedAvailabilityType.remove(value);
              } else {
                _selectedAvailabilityType.add(value);
              }
              // Clear error when user makes a selection
              _availabilityTypeError = null;
            });
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? context.color.tertiaryColor
                  : context.color.secondaryColor,
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isSelected
                    ? context.color.tertiaryColor
                    : context.color.textColorDark,
              ),
            ),
            child: Icon(
              Icons.check,
              color: context.color.secondaryColor,
            ),
          ),
        ),
        const SizedBox(width: 11),
        CustomText(label),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildTimezoneDropdown() {
    return AppointmentCardContainer(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          CustomText(
            'timezone'.translate(context),
            color: context.color.textColorDark,
            fontSize: context.font.sm,
            fontWeight: .w500,
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: context.color.borderColor),
              borderRadius: BorderRadius.circular(8),
              color: context.color.primaryColor,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value:
                    AppointmentHelper.timezoneOptions.contains(
                      _selectedTimezone,
                    )
                    ? _selectedTimezone
                    : null,
                dropdownColor: context.color.secondaryColor,
                isExpanded: true,
                items: AppointmentHelper.timezoneOptions.map((timezone) {
                  return DropdownMenuItem<String>(
                    value: timezone,
                    child: CustomText(
                      timezone,
                      color: context.color.textColorDark,
                      fontSize: context.font.sm,
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedTimezone = value);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavePreferencesButton() {
    return Positioned(
      bottom: 16.rh(context),
      left: 0,
      right: 0,
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: _validateForm,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.color.tertiaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child:
              context.watch<UpdateBookingPreferencesCubit>().state
                  is UpdateBookingPreferencesInProgress
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    color: context.color.buttonColor,
                    strokeWidth: 2,
                  ),
                )
              : CustomText(
                  'saveConfiguration'.translate(context),
                  color: context.color.buttonColor,
                  fontSize: context.font.md,
                  fontWeight: .w600,
                ),
        ),
      ),
    );
  }

  Future<void> _saveConfiguration() async {
    try {
      await context
          .read<UpdateBookingPreferencesCubit>()
          .updateBookingPreferences(
            meetingDurationMinutes: _meetingDurationController.text,
            leadTimeMinutes: _minAdvanceBookingController.text,
            bufferTimeMinutes: _bufferTimeController.text,
            autoConfirm: _autoConfirm ? '1' : '0',
            cancelRescheduleBufferMinutes:
                _cancelRescheduleBufferController.text,
            autoCancelAfterMinutes: _autoCancelController.text,
            autoCancelMessage: _autoCancelMessageController.text,
            dailyBookingLimit: _dailyLimitController.text,
            availableMeetingTypes: _selectedAvailabilityType.join(','),
            antiSpamEnabled: '0',
            timezone: _selectedTimezone,
          );

      HelperUtils.showSnackBarMessage(
        context,
        'configurationSavedSuccessfully',
        type: .success,
      );
      await fetchBookingPreferences(isFromInitial: false);
    } on Exception catch (_) {
      HelperUtils.showSnackBarMessage(
        context,
        'configurationSavedFailed',
        type: .error,
      );
      await fetchBookingPreferences(isFromInitial: false);
    }
  }
}
