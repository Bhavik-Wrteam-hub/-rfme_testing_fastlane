import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/helper_utils.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Time selector that lets users pick both start and end time using a time picker
class AppointmentTimePicker extends StatelessWidget {
  const AppointmentTimePicker({
    required this.startTime,
    required this.endTime,
    required this.onChanged,
    this.selectedDate,
    super.key,
  });

  final String startTime; // in 'HH:mm'
  final String endTime; // in 'HH:mm'
  final void Function(String startTime, String endTime) onChanged;
  final DateTime? selectedDate;

  String _formatTime(String time) {
    try {
      final timeFormat24 = DateFormat('HH:mm');
      final timeFormat12 = DateFormat('h:mm a');
      final parsedTime = timeFormat24.parse(time);
      return timeFormat12.format(parsedTime);
    } on Exception {
      return time;
    }
  }

  Future<String?> _pickTime(BuildContext context, String initial) async {
    try {
      final timeFormat24 = DateFormat('HH:mm');
      final initialDate = timeFormat24.parse(initial);
      final initialOfDay = TimeOfDay(
        hour: initialDate.hour,
        minute: initialDate.minute,
      );
      final picked = await showTimePicker(
        context: context,
        initialTime: initialOfDay,
        helpText: '',
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: false),
            child: child ?? const SizedBox.shrink(),
          );
        },
      );
      if (picked == null) return null;
      final hh = picked.hour.toString().padLeft(2, '0');
      final mm = picked.minute.toString().padLeft(2, '0');
      return '$hh:$mm';
    } on Exception {
      return null;
    }
  }

  bool _isEndAfterStart(String start, String end) {
    try {
      final f = DateFormat('HH:mm');
      return f.parse(end).isAfter(f.parse(start));
    } on Exception {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await _pickTime(
                context,
                startTime.isEmpty ? '09:00' : startTime,
              );
              if (picked == null) return;
              final newStart = picked;
              // If end time is not chosen yet, just update start and keep end empty
              if (endTime.isEmpty) {
                onChanged(newStart, '');
                return;
              }
              // Validate only when both values are present
              if (!_isEndAfterStart(newStart, endTime)) {
                HelperUtils.showSnackBarMessage(
                  context,
                  'endTimeMustBeAfterStartTime',
                  type: .error,
                );
                return;
              }
              onChanged(newStart, endTime);
            },
            child: Container(
              height: 44.rh(context),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.color.primaryColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.color.borderColor),
              ),
              child: CustomText(
                startTime.isEmpty ? '—' : _formatTime(startTime),
                color: context.color.textColorDark,
                fontSize: context.font.sm,
                fontWeight: .w500,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        CustomText(
          '-',
          color: context.color.textLightColor,
          fontSize: context.font.md,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () async {
              final picked = await _pickTime(
                context,
                endTime.isEmpty
                    ? (startTime.isEmpty ? '09:00' : startTime)
                    : endTime,
              );
              if (picked == null) return;
              // If start time is not chosen yet, set start and keep end empty
              if (startTime.isEmpty) {
                onChanged(picked, '');
                return;
              }
              // Validate only when start is present
              if (!_isEndAfterStart(startTime, picked)) {
                HelperUtils.showSnackBarMessage(
                  context,
                  'endTimeMustBeAfterStartTime',
                  type: .error,
                );
                return;
              }
              onChanged(startTime, picked);
            },
            child: Container(
              height: 44.rh(context),
              alignment: Alignment.center,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: context.color.primaryColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: context.color.borderColor),
              ),
              child: CustomText(
                endTime.isEmpty ? '—' : _formatTime(endTime),
                color: context.color.textColorDark,
                fontSize: context.font.sm,
                fontWeight: .w500,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
