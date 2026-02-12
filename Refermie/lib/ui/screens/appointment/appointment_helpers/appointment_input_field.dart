import 'package:ebroker/ui/screens/widgets/custom_text_form_field.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

/// Reusable input field component for appointment screens
class AppointmentInputField extends StatelessWidget {
  const AppointmentInputField({
    required this.controller,
    required this.keyboardType,
    this.maxLines = 1,
    this.hintText,
    super.key,
  });

  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return CustomTextFormField(
      controller: controller,
      keyboard: keyboardType,
      maxLine: maxLines,
      hintText: hintText,
      fillColor: context.color.primaryColor,
    );
  }
}
