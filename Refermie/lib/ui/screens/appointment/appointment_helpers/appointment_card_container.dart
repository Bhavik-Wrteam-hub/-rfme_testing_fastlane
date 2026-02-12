import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

/// Reusable card container used across appointment screens
class AppointmentCardContainer extends StatelessWidget {
  const AppointmentCardContainer({
    required this.child,
    this.padding,
    this.margin,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: context.color.secondaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: context.color.borderColor),
      ),
      child: child,
    );
  }
}
