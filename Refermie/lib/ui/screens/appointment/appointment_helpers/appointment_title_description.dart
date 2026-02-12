import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

/// Reusable title and description component for appointment screens
class AppointmentTitleDescription extends StatelessWidget {
  const AppointmentTitleDescription({
    required this.title,
    required this.isRequired,
    this.description,
    super.key,
  });

  final String title;
  final bool isRequired;
  final String? description;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          children: [
            CustomText(
              title,
              color: context.color.textColorDark,
              fontSize: context.font.sm,
              fontWeight: .w500,
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              const CustomText('*', color: Colors.red),
            ],
          ],
        ),
        if (description != null && description!.isNotEmpty) ...[
          const SizedBox(height: 4),
          CustomText(
            description!,
            color: context.color.textColorDark,
            fontSize: context.font.xs,
            fontWeight: .w400,
          ),
        ],
      ],
    );
  }
}
