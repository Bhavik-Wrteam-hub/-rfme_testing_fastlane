import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

/// Reusable switch component used across appointment screens
class AppointmentSwitch extends StatelessWidget {
  const AppointmentSwitch({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Switch(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackOutlineColor: const WidgetStatePropertyAll(
          Colors.transparent,
        ),
        thumbIcon: const WidgetStatePropertyAll(
          Icon(Icons.circle, color: Colors.white),
        ),
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: Colors.grey,
        activeTrackColor: context.color.tertiaryColor,
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
