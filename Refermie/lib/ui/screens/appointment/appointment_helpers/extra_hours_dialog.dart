import 'package:ebroker/data/cubits/appointment/delete/delete_extra_time_slot_cubit.dart';
import 'package:ebroker/data/cubits/appointment/post/manage_extra_time_slot_cubit.dart';
import 'package:ebroker/data/model/appointment/agent_time_schedule_model.dart';
import 'package:ebroker/data/model/appointment/booking_preferences_model.dart';
import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/ui/screens/appointment/appointment_helpers/appointment_widgets_export.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class ExtraTimeSlot {
  ExtraTimeSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.date,
  });
  final String id;
  final String startTime;
  final String endTime;
  final String date;

  ExtraTimeSlot copyWith({
    String? id,
    String? startTime,
    String? endTime,
    String? date,
  }) {
    return ExtraTimeSlot(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toJson() {
    final json = {
      'date': date,
      'start_time': startTime,
      'end_time': endTime,
    };

    if (id.isNotEmpty && !id.startsWith('temp_')) {
      json['id'] = id;
    }

    return json;
  }
}

class ExtraHoursDialog extends StatefulWidget {
  const ExtraHoursDialog({
    required this.selectedDate,
    required this.bookingPreferences,
    this.existingSlot,
    this.existingTimeSlots = const [],
    this.onSave,
    this.extraSlots = const [],
    super.key,
  });

  final DateTime selectedDate;
  final ExtraSlot? existingSlot;
  final BookingPreferencesModel bookingPreferences;
  final List<TimeSchedule> existingTimeSlots;
  final VoidCallback? onSave;
  final List<ExtraSlot> extraSlots;
  @override
  State<ExtraHoursDialog> createState() => _ExtraHoursDialogState();
}

class _ExtraHoursDialogState extends State<ExtraHoursDialog> {
  List<ExtraTimeSlot> _timeSlots = [];
  final List<String> _slotsToDelete = [];

  late int _bufferTimeMinutes;

  void _addTimeSlot() {
    final dateString = AppointmentHelper.getDateKey(widget.selectedDate);

    setState(() {
      _timeSlots.add(
        ExtraTimeSlot(
          id: '',
          startTime: '',
          endTime: '',
          date: dateString,
        ),
      );
    });
  }

  void _removeTimeSlot(String slotId) {
    setState(() {
      _timeSlots.removeWhere((slot) => slot.id == slotId);
    });
  }

  void _markSlotForDeletion(String slotId) {
    setState(() {
      if (!_slotsToDelete.contains(slotId)) {
        _slotsToDelete.add(slotId);
      }
    });
  }

  void _unmarkSlotForDeletion(String slotId) {
    setState(() {
      _slotsToDelete.remove(slotId);
    });
  }

  String _getButtonTitle() {
    final isEditingExistingSlot = widget.existingSlot != null;
    final hasNewSlots = _timeSlots.isNotEmpty;
    final hasDeletions = _slotsToDelete.isNotEmpty;

    if (isEditingExistingSlot && hasNewSlots && hasDeletions) {
      return 'updateAndDelete'.translate(context);
    } else if (isEditingExistingSlot && hasNewSlots) {
      return 'update'.translate(context);
    } else if (isEditingExistingSlot) {
      return 'update'.translate(context);
    } else if (hasNewSlots && hasDeletions) {
      return 'saveAndDelete'.translate(context);
    } else if (hasNewSlots) {
      return 'save'.translate(context);
    } else if (hasDeletions) {
      return 'delete'.translate(context);
    } else {
      return 'save'.translate(context);
    }
  }

  void _updateTimeSlot(String slotId, {String? startTime, String? endTime}) {
    if (startTime == null && endTime == null) return;

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
      } on Exception {
        // ignore
      }
    }

    setState(() {
      _timeSlots = _timeSlots.map((slot) {
        if (slot.id == slotId) {
          return slot.copyWith(
            startTime: startTime ?? slot.startTime,
            endTime: endTime ?? slot.endTime,
          );
        }
        return slot;
      }).toList();
    });
  }

  String _formatTimeFromApi(String apiTime) {
    try {
      return apiTime.length >= 5 ? apiTime.substring(0, 5) : apiTime;
    } on Exception catch (_) {
      return apiTime;
    }
  }

  ExtraTimeSlot _convertExtraSlotToTimeSlot(ExtraSlot extraSlot) {
    return ExtraTimeSlot(
      id: extraSlot.id,
      startTime: _formatTimeFromApi(extraSlot.startTime),
      endTime: _formatTimeFromApi(extraSlot.endTime),
      date: extraSlot.date,
    );
  }

  List<ExtraTimeSlot> _getExistingExtraSlots() {
    final dateString = AppointmentHelper.getDateKey(widget.selectedDate);
    return widget.extraSlots
        .where((slot) => slot.date == dateString)
        .map(_convertExtraSlotToTimeSlot)
        .toList();
  }

  @override
  void initState() {
    super.initState();

    _bufferTimeMinutes = int.parse(widget.bookingPreferences.bufferTimeMinutes);

    _timeSlots = [];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingSlot != null;
    return Builder(
      builder: (context) {
        return Dialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 22.rw(context)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: context.color.secondaryColor,
          child: Container(
            decoration: BoxDecoration(
              color: context.color.secondaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: .min,
              crossAxisAlignment: .start,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                UiUtils.getDivider(context),
                const SizedBox(height: 12),
                _buildDateSection(),
                const SizedBox(height: 12),
                UiUtils.getDivider(context),
                const SizedBox(height: 16),
                _buildTimeSection(),
                if (_timeSlots.isNotEmpty ||
                    _getExistingExtraSlots().isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildActionButtons(context, isEditing),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final isEditing = widget.existingSlot != null;
    return Row(
      children: [
        Expanded(
          child: CustomText(
            isEditing
                ? 'editExtraHours'.translate(context)
                : 'addExtraHours'.translate(context),
            color: context.color.textColorDark,
            fontSize: context.font.lg,
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
    );
  }

  Widget _buildDateSection() {
    return CustomText(
      AppointmentHelper.formatDate(
        widget.selectedDate,
        format: 'dd MMMM, yyyy',
      ),
      color: context.color.textColorDark,
      fontSize: context.font.md,
      fontWeight: .w500,
    );
  }

  Widget _buildTimeSection() {
    final existingSlots = _getExistingExtraSlots();

    final displayExistingSlots = existingSlots;

    final hasAnySlots =
        displayExistingSlots.isNotEmpty ||
        _timeSlots.isNotEmpty ||
        widget.existingSlot != null;

    return Column(
      children: [
        if (hasAnySlots) ...[
          if (displayExistingSlots.isNotEmpty) ...[
            ...displayExistingSlots.map(
              _buildExistingTimeSlot,
            ),
          ],
          if (_timeSlots.isNotEmpty) ...[
            ..._timeSlots.asMap().entries.map((entry) {
              final index = entry.key;
              final slot = entry.value;
              final isFirstSlot = index == 0;
              return Column(
                children: [
                  _buildTimeSlot(slot, isFirstSlot),
                  if (index < _timeSlots.length - 1) const SizedBox(height: 8),
                ],
              );
            }),
          ],
        ] else ...[
          _buildEmptyState(),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.color.primaryColor,
        border: Border.all(color: context.color.borderColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          CustomText(
            'noSchedulesOrTimeSlotsAvailableYet'.translate(context),
            color: context.color.textColorDark,
            fontSize: context.font.sm,
            textAlign: .center,
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          UiUtils.buildButton(
            context,
            autoWidth: true,
            onPressed: _addTimeSlot,
            buttonTitle: 'addSlot'.translate(context),
            fontSize: context.font.sm,
            height: 40.rh(context),
            prefixWidget: const Padding(
              padding: EdgeInsetsDirectional.only(end: 8),
              child: Icon(
                Icons.add_circle,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingTimeSlot(ExtraTimeSlot slot) {
    final isMarkedForDeletion = _slotsToDelete.contains(slot.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44.rh(context),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isMarkedForDeletion
                    ? Colors.red.withValues(alpha: 0.1)
                    : context.color.secondaryColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isMarkedForDeletion
                      ? Colors.red.withValues(alpha: 0.3)
                      : context.color.borderColor,
                ),
              ),
              child: CustomText(
                AppointmentHelper.formatTimeToAmPm(slot.startTime),
                color: isMarkedForDeletion
                    ? Colors.red
                    : context.color.textColorDark,
                fontSize: context.font.sm,
                fontWeight: .w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          CustomText(
            '-',
            color: isMarkedForDeletion
                ? Colors.red.withValues(alpha: 0.7)
                : context.color.textLightColor,
            fontSize: context.font.md,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 44.rh(context),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isMarkedForDeletion
                    ? Colors.red.withValues(alpha: 0.1)
                    : context.color.secondaryColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isMarkedForDeletion
                      ? Colors.red.withValues(alpha: 0.3)
                      : context.color.borderColor,
                ),
              ),
              child: CustomText(
                slot.startTime == ''
                    ? ''
                    : AppointmentHelper.formatTimeToAmPm(slot.endTime),
                color: isMarkedForDeletion
                    ? Colors.red
                    : context.color.textColorDark,
                fontSize: context.font.sm,
                fontWeight: .w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _addTimeSlot,
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
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              if (_slotsToDelete.contains(slot.id)) {
                _unmarkSlotForDeletion(slot.id);
              } else {
                _markSlotForDeletion(slot.id);
              }
            },
            child: Container(
              height: 44.rh(context),
              width: 44.rw(context),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _slotsToDelete.contains(slot.id)
                    ? Colors.orange.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(
                _slotsToDelete.contains(slot.id) ? Icons.undo : Icons.remove,
                color: _slotsToDelete.contains(slot.id)
                    ? Colors.orange
                    : Colors.red,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeSlot(ExtraTimeSlot slot, bool isFirstSlot) {
    return Row(
      children: [
        Expanded(
          child: AppointmentTimePicker(
            startTime: slot.startTime,
            endTime: slot.endTime,
            onChanged: (newStart, newEnd) {
              _updateTimeSlot(slot.id, startTime: newStart, endTime: newEnd);
            },
            selectedDate: widget.selectedDate,
          ),
        ),
        const SizedBox(width: 12),
        GestureDetector(
          onTap: _addTimeSlot,
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
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () => _removeTimeSlot(slot.id),
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
              size: 18,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context, bool isEditing) {
    return BlocBuilder<ManageExtraTimeSlotCubit, ManageExtraTimeSlotState>(
      builder: (context, state) {
        final isSaving = state is ManageExtraTimeSlotInProgress;
        return BlocBuilder<DeleteExtraTimeSlotCubit, DeleteExtraTimeSlotState>(
          builder: (context, deleteState) {
            final isDeleting = deleteState is DeleteExtraTimeSlotInProgress;
            final isLoading = isSaving || isDeleting;

            return Row(
              children: [
                Expanded(
                  child: UiUtils.buildButton(
                    context,
                    onPressed: isLoading ? () {} : () => Navigator.pop(context),
                    buttonTitle: 'cancelLbl'.translate(context),
                    fontSize: context.font.sm,
                    height: 40.rh(context),
                    buttonColor: context.color.secondaryColor,
                    textColor: context.color.tertiaryColor,
                    border: BorderSide(color: context.color.tertiaryColor),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: UiUtils.buildButton(
                    context,
                    onPressed: isLoading ? () {} : _saveExtraTimeSlot,
                    buttonTitle: _getButtonTitle(),
                    fontSize: context.font.sm,
                    height: 40.rh(context),
                    isInProgress: isLoading,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _saveExtraTimeSlot() async {
    try {
      final isEditingExistingSlot = widget.existingSlot != null;

      if (_timeSlots.isEmpty &&
          _slotsToDelete.isEmpty &&
          !isEditingExistingSlot) {
        HelperUtils.showSnackBarMessage(
          context,
          'noChangesToSave',
          type: .error,
        );
        return;
      }

      for (final slot in _timeSlots) {
        if (!AppointmentHelper.isValidTimeSlot(slot.startTime, slot.endTime)) {
          HelperUtils.showSnackBarMessage(
            context,
            'endTimeMustBeAfterStartTimeForAllSlots',
            type: .error,
          );
          return;
        }
      }

      for (final slot in _timeSlots) {
        if (_hasConflictWithExisting(slot.startTime, slot.endTime)) {
          await Fluttertoast.showToast(
            msg: 'timeConflictsWithExistingSlots'.translate(context),
          );
          return;
        }
        if (_hasConflictWithinNewSlots(slot.id, slot.startTime, slot.endTime)) {
          await Fluttertoast.showToast(
            msg: 'timeConflictsWithNewSlots'.translate(context),
          );
          return;
        }
      }

      if (_slotsToDelete.isNotEmpty) {
        await _deleteMarkedSlots();
      }

      if (_timeSlots.isNotEmpty || isEditingExistingSlot) {
        await _saveTimeSlots();
      }

      widget.onSave?.call();
      Navigator.pop(context, true);
    } on Exception catch (e) {
      HelperUtils.showSnackBarMessage(
        context,
        e.toString(),
        type: .error,
      );
    }
  }

  Future<void> _deleteMarkedSlots() async {
    final parameters = <String, dynamic>{};

    for (var i = 0; i < _slotsToDelete.length; i++) {
      parameters['slot_ids[$i]'] = _slotsToDelete[i];
    }

    await context.read<DeleteExtraTimeSlotCubit>().deleteExtraTimeSlot(
      parameters: parameters,
    );
  }

  Future<void> _saveTimeSlots() async {
    final parameters = <String, dynamic>{};

    for (var i = 0; i < _timeSlots.length; i++) {
      final slot = _timeSlots[i];
      final slotJson = slot.toJson();

      parameters['extra_time_slots[$i][date]'] = slotJson['date'];
      parameters['extra_time_slots[$i][start_time]'] = slotJson['start_time'];
      parameters['extra_time_slots[$i][end_time]'] = slotJson['end_time'];

      if (slotJson['id'] != null && slotJson['id'] != '') {
        parameters['extra_time_slots[$i][id]'] = slotJson['id'];
      }
    }

    await context.read<ManageExtraTimeSlotCubit>().manageExtraTimeSlots(
      parameters: parameters,
    );
  }

  bool _hasConflictWithinNewSlots(
    String slotId,
    String startTime,
    String endTime,
  ) {
    try {
      final timeFormat = DateFormat('HH:mm');
      final rangeStart = timeFormat.parse(startTime);
      final rangeEnd = timeFormat.parse(endTime);
      for (final other in _timeSlots) {
        if (other.id == slotId) continue;
        if (other.startTime.isEmpty || other.endTime.isEmpty) continue;
        final otherStart = timeFormat.parse(other.startTime);
        final otherEnd = timeFormat.parse(other.endTime);

        final otherStartWithBuffer = otherStart.subtract(
          Duration(minutes: _bufferTimeMinutes),
        );
        final otherEndWithBuffer = otherEnd.add(
          Duration(minutes: _bufferTimeMinutes),
        );

        if (rangeStart.isBefore(otherEndWithBuffer) &&
            rangeEnd.isAfter(otherStartWithBuffer)) {
          return true;
        }
      }
    } on Exception {
      return true;
    }
    return false;
  }

  bool _hasConflictWithExisting(String startTime, String endTime) {
    try {
      final timeFormat = DateFormat('HH:mm');
      final rangeStart = timeFormat.parse(startTime);
      final rangeEnd = timeFormat.parse(endTime);

      final dayString = AppointmentHelper.getDateKey(widget.selectedDate);
      final dayOfWeek = DateFormat(
        'EEEE',
      ).format(widget.selectedDate).toLowerCase();
      for (final schedule in widget.existingTimeSlots) {
        if (schedule.dayOfWeek.toLowerCase() != dayOfWeek ||
            schedule.isActive != '1') {
          continue;
        }
        final existingStart = timeFormat.parse(
          _formatTimeFromApi(schedule.startTime),
        );
        final existingEnd = timeFormat.parse(
          _formatTimeFromApi(schedule.endTime),
        );
        final existingStartWithBuffer = existingStart.subtract(
          Duration(minutes: _bufferTimeMinutes),
        );
        final existingEndWithBuffer = existingEnd.add(
          Duration(minutes: _bufferTimeMinutes),
        );
        if (rangeStart.isBefore(existingEndWithBuffer) &&
            rangeEnd.isAfter(existingStartWithBuffer)) {
          return true;
        }
      }

      for (final extra in widget.extraSlots) {
        if (extra.date != dayString) continue;
        final existingStart = timeFormat.parse(
          _formatTimeFromApi(extra.startTime),
        );
        final existingEnd = timeFormat.parse(
          _formatTimeFromApi(extra.endTime),
        );
        final existingStartWithBuffer = existingStart.subtract(
          Duration(minutes: _bufferTimeMinutes),
        );
        final existingEndWithBuffer = existingEnd.add(
          Duration(minutes: _bufferTimeMinutes),
        );
        if (rangeStart.isBefore(existingEndWithBuffer) &&
            rangeEnd.isAfter(existingStartWithBuffer)) {
          return true;
        }
      }
    } on Exception {
      return true;
    }
    return false;
  }
}
