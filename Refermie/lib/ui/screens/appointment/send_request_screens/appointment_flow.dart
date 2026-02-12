import 'package:ebroker/data/cubits/appointment/post/create_appointment_request_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/update_appointment_status_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/update_meeting_type_cubit.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/customer_data.dart';
import 'package:ebroker/data/model/agent/agents_properties_models/properties_data.dart';
import 'package:ebroker/data/model/appointment/appointment_model.dart';
import 'package:ebroker/data/model/category.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/appointment/send_request_screens/confirmation_step.dart';
import 'package:ebroker/ui/screens/appointment/send_request_screens/date_time_selection_step.dart';
import 'package:ebroker/ui/screens/appointment/send_request_screens/property_selection_step.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

enum AppointmentStep { propertySelection, dateTimeSelection, confirmation }

class AppointmentFlow extends StatefulWidget {
  const AppointmentFlow({
    required this.agentDetails,
    required this.isAdmin,
    this.isRescheduleMode = false,
    this.existingAppointment,
    this.onRescheduleComplete,
    this.preSelectedProperty,
    super.key,
  });

  final CustomerData agentDetails;
  final bool isAdmin;
  final bool isRescheduleMode;
  final AppointmentModel? existingAppointment;
  final VoidCallback? onRescheduleComplete;
  final PropertiesData? preSelectedProperty;

  static Route<dynamic> route(RouteSettings routeSettings) {
    final arguments = routeSettings.arguments as Map<String, dynamic>?;
    final agentDetails = arguments?['agentDetails'] as CustomerData?;
    final isAdmin = arguments?['isAdmin'] as bool? ?? false;
    final preSelectedProperty =
        arguments?['preSelectedProperty'] as PropertiesData?;

    return CupertinoPageRoute(
      builder: (_) => AppointmentFlow(
        agentDetails: agentDetails!,
        isAdmin: isAdmin,
        preSelectedProperty: preSelectedProperty,
      ),
    );
  }

  @override
  State<AppointmentFlow> createState() => _AppointmentFlowState();
}

class AppointmentData {
  // For reschedule reason

  AppointmentData({
    this.property,
    this.selectedDate,
    this.selectedStartTime,
    this.selectedEndTime,
    this.meetingType,
    this.message,
    this.reason,
  });

  // Factory constructor for reschedule mode
  factory AppointmentData.fromAppointment(AppointmentModel appointment) {
    final property = appointment.property;
    final propertiesData = property != null
        ? PropertiesData(
            id: property.id ?? 0,
            slugId: property.slugId ?? '',
            city: property.city ?? '',
            state: property.state ?? '',
            country: property.country ?? '',
            price: property.price ?? '',
            categoryId: property.category?.id?.toString() ?? '',
            propertyType: property.propertyType ?? '',
            title: property.title ?? '',
            translatedTitle: property.translatedTitle ?? '',
            translatedDescription: property.translatedDescription ?? '',
            titleImage: property.titleImage ?? '',
            isPremium: property.isPremium?.toString() ?? '',
            address: property.address ?? '',
            addedBy: property.addedBy ?? '',
            promoted: property.promoted ?? false,
            isFavourite: property.isFavourite ?? '',
            category: Category(
              id: property.category?.id ?? 0,
              category: property.category?.category ?? '',
              image: property.category?.image ?? '',
              parameterTypes: [],
              translatedName: property.category?.translatedName ?? '',
            ),
            rentduration: property.rentduration ?? '',
          )
        : null;

    return AppointmentData(
      property: propertiesData,
      selectedDate: DateTime.tryParse(appointment.date),
      selectedStartTime: appointment.startAt,
      selectedEndTime: appointment.endAt,
      meetingType: appointment.meetingType,
      message: appointment.notes,
    );
  }
  PropertiesData? property;
  DateTime? selectedDate;
  String? selectedStartTime;
  String? selectedEndTime;
  String? meetingType;
  String? message;
  String? reason;

  bool get isPropertySelected => property != null;
  bool get isDateTimeSelected =>
      selectedDate != null &&
      selectedStartTime != null &&
      selectedEndTime != null &&
      meetingType != null;

  bool get isComplete => isPropertySelected && isDateTimeSelected;
}

class _AppointmentFlowState extends State<AppointmentFlow> {
  late AppointmentStep _currentStep;
  late AppointmentData _appointmentData;

  late DateTime _focusedDay;

  late final DateTime _firstDay;
  late final DateTime _lastDay;

  @override
  void initState() {
    super.initState();

    // Initialize based on reschedule mode or pre-selected property
    if (widget.isRescheduleMode && widget.existingAppointment != null) {
      _appointmentData = AppointmentData.fromAppointment(
        widget.existingAppointment!,
      );
      _currentStep =
          AppointmentStep.dateTimeSelection; // Skip property selection
      _focusedDay = _appointmentData.selectedDate ?? DateTime.now();
    } else if (widget.preSelectedProperty != null) {
      // Property is pre-selected, skip property selection step
      _appointmentData = AppointmentData(property: widget.preSelectedProperty);
      _currentStep = AppointmentStep.dateTimeSelection;
      _focusedDay = DateTime.now();
      _appointmentData.selectedDate = _focusedDay;
    } else {
      _appointmentData = AppointmentData();
      _currentStep = AppointmentStep.propertySelection;
      _focusedDay = DateTime.now();
      _appointmentData.selectedDate = _focusedDay;

      // Fetch agent's properties for pagination
    }

    _firstDay = DateTime.now();
    _lastDay = DateTime.now().add(const Duration(days: 365));
  }

  Future<void> _nextStep() async {
    switch (_currentStep) {
      case AppointmentStep.propertySelection:
        if (_appointmentData.isPropertySelected) {
          setState(() => _currentStep = AppointmentStep.dateTimeSelection);
        } else {
          HelperUtils.showSnackBarMessage(
            context,
            'pleaseSelectProperty',
            type: .error,
          );
        }

      case AppointmentStep.dateTimeSelection:
        if (_appointmentData.isDateTimeSelected) {
          setState(() => _currentStep = AppointmentStep.confirmation);
        } else {
          String errorKey;
          if (_appointmentData.selectedDate == null) {
            errorKey = 'pleaseSelectDate';
          } else if (_appointmentData.selectedStartTime == null ||
              _appointmentData.selectedEndTime == null) {
            errorKey = 'pleaseSelectTimeSlot';
          } else if (_appointmentData.meetingType == null) {
            errorKey = 'pleaseSelectMeetingType';
          } else {
            errorKey = 'pleaseSelectDateTimeAndType';
          }

          HelperUtils.showSnackBarMessage(
            context,
            errorKey,
            messageDuration: 1,
            type: .error,
          );
        }

      case AppointmentStep.confirmation:
        await _submitAppointment();
    }
  }

  void _previousStep() {
    switch (_currentStep) {
      case AppointmentStep.propertySelection:
        Navigator.of(context).pop();
      case AppointmentStep.dateTimeSelection:
        // In reschedule mode or when property is pre-selected, go back to previous screen
        if (widget.isRescheduleMode || widget.preSelectedProperty != null) {
          Navigator.of(context).pop();
        } else {
          setState(() => _currentStep = AppointmentStep.propertySelection);
        }
      case AppointmentStep.confirmation:
        setState(() => _currentStep = AppointmentStep.dateTimeSelection);
    }
  }

  Future<void> _submitAppointment() async {
    try {
      final formattedDate = DateFormat(
        'yyyy-MM-dd',
      ).format(_appointmentData.selectedDate!);

      if (widget.isRescheduleMode && widget.existingAppointment != null) {
        // Require non-empty reason when rescheduling
        if ((_appointmentData.reason ?? '').trim().isEmpty) {
          HelperUtils.showSnackBarMessage(
            context,
            'reasonRequired',
            messageDuration: 1,
            type: .error,
          );
          return;
        }
        // Handle reschedule
        await context
            .read<UpdateAppointmentStatusCubit>()
            .updateAppointmentStatus(
              appointmentId: widget.existingAppointment!.id.toString(),
              status: 'rescheduled',
              reason: _appointmentData.reason ?? '',
              date: formattedDate,
              startTime: _appointmentData.selectedStartTime ?? '',
              endTime: _appointmentData.selectedEndTime ?? '',
            );

        if (widget.existingAppointment!.meetingType !=
            _appointmentData.meetingType) {
          await context.read<UpdateMeetingTypeCubit>().updateMeetingType(
            appointmentId: widget.existingAppointment!.id.toString(),
            meetingType: _appointmentData.meetingType ?? '',
          );
        }

        // Call the completion callback if provided
        widget.onRescheduleComplete?.call();
      } else {
        // Handle new appointment creation
        await context
            .read<CreateAppointmentRequestCubit>()
            .createAppointmentRequest(
              date: formattedDate,
              meetingType: _appointmentData.meetingType ?? '',
              notes: _appointmentData.message ?? '',
              propertyId: _appointmentData.property?.id.toString() ?? '',
              startTime: _appointmentData.selectedStartTime ?? '',
              endTime: _appointmentData.selectedEndTime ?? '',
            );
      }

      Navigator.pop(context);
    } on Exception catch (_) {}
  }

  String get _appBarTitle {
    if (widget.isRescheduleMode) {
      return switch (_currentStep) {
        AppointmentStep.dateTimeSelection => 'rescheduleAppointment'.translate(
          context,
        ),
        AppointmentStep.confirmation => 'confirmation'.translate(context),
        AppointmentStep.propertySelection => 'chooseProperty'.translate(
          context,
        ), // This shouldn't be reached in reschedule mode
      };
    } else {
      return switch (_currentStep) {
        AppointmentStep.propertySelection => 'chooseProperty'.translate(
          context,
        ),
        AppointmentStep.dateTimeSelection => 'selectDateAndTime'.translate(
          context,
        ),
        AppointmentStep.confirmation => 'confirmation'.translate(context),
      };
    }
  }

  String get _nextButtonText {
    return _currentStep == AppointmentStep.confirmation
        ? (widget.isRescheduleMode
              ? 'reschedule'.translate(context)
              : 'submitBtnLbl'.translate(context))
        : 'continue'.translate(context);
  }

  String _getStepCounterText() {
    final isPropertyPreSelected = widget.preSelectedProperty != null;

    if (widget.isRescheduleMode) {
      return '${_currentStep == AppointmentStep.dateTimeSelection ? '01' : '02'}/02';
    } else if (isPropertyPreSelected) {
      // When property is pre-selected, we skip property selection (2 steps total)
      return '${_currentStep == AppointmentStep.dateTimeSelection ? '01' : '02'}/02';
    } else {
      // Normal flow with all 3 steps
      return '${_currentStep == AppointmentStep.propertySelection
          ? '01'
          : _currentStep == AppointmentStep.dateTimeSelection
          ? '02'
          : '03'}/03';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      appBar: CustomAppBar(
        title: _appBarTitle,
        actions: [
          CustomText(
            _getStepCounterText(),
          ),
        ],
      ),
      body: _buildCurrentStepBody(),
      bottomNavigationBar: _AppointmentBottomBar(
        onPrevious: _previousStep,
        onNext: _nextStep,
        nextButtonText: _nextButtonText,
      ),
    );
  }

  Widget _buildCurrentStepBody() {
    return switch (_currentStep) {
      AppointmentStep.propertySelection => PropertySelectionStep(
        selectedProperty: _appointmentData.property,
        onPropertySelected: (property) {
          setState(() => _appointmentData.property = property);
        },
        agentId: widget.agentDetails.id.toString(),
        isAdmin: widget.isAdmin,
      ),
      AppointmentStep.dateTimeSelection => DateTimeSelectionStep(
        appointmentData: _appointmentData,
        focusedDay: _focusedDay,
        firstDay: _firstDay,
        lastDay: _lastDay,
        onDaySelected: _onDaySelected,
        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
        onTimeSlotChanged: (startTime, endTime) {
          setState(() {
            _appointmentData.selectedStartTime = startTime;
            _appointmentData.selectedEndTime = endTime;
          });
        },
        onMeetingTypeChanged: (type) {
          setState(() => _appointmentData.meetingType = type);
        },
        agentId: widget.agentDetails.id.toString(),
        isAdmin: widget.isAdmin,
      ),
      AppointmentStep.confirmation => ConfirmationStep(
        appointmentData: _appointmentData,
        agentDetails: widget.agentDetails,
        onMessageChanged: (message) {
          setState(() => _appointmentData.message = message);
        },
        onChangePressed: () {
          setState(() => _currentStep = AppointmentStep.dateTimeSelection);
        },
        isRescheduleMode: widget.isRescheduleMode,
        onReasonChanged: widget.isRescheduleMode
            ? (reason) {
                setState(() => _appointmentData.reason = reason);
              }
            : null,
      ),
    };
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_appointmentData.selectedDate, selectedDay)) {
      setState(() {
        _appointmentData.selectedDate = selectedDay;
        _focusedDay = focusedDay;
        _appointmentData.selectedStartTime = null;
        _appointmentData.selectedEndTime = null;
      });
    }
  }
}

class _AppointmentBottomBar extends StatelessWidget {
  const _AppointmentBottomBar({
    required this.onPrevious,
    required this.onNext,
    required this.nextButtonText,
  });

  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final String nextButtonText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        border: Border(top: BorderSide(color: context.color.borderColor)),
      ),
      child: Row(
        children: [
          Expanded(
            child: UiUtils.buildButton(
              context,
              height: 48.rh(context),
              fontSize: context.font.md,
              onPressed: onPrevious,
              padding: const EdgeInsets.symmetric(vertical: 12),
              textColor: context.color.tertiaryColor,
              buttonColor: context.color.secondaryColor,
              border: BorderSide(color: context.color.tertiaryColor),
              buttonTitle: 'previouslbl'.translate(context),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: UiUtils.buildButton(
              context,
              height: 48.rh(context),
              fontSize: context.font.md,
              onPressed: onNext,
              padding: const EdgeInsets.symmetric(vertical: 12),
              buttonTitle: nextButtonText,
            ),
          ),
        ],
      ),
    );
  }
}
