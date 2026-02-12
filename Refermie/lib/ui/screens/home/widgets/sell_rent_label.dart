import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class SellRentLabel extends StatelessWidget {
  const SellRentLabel({required this.propertyType, super.key});
  final String propertyType;

  @override
  Widget build(BuildContext context) {
    final color =
        (propertyType.toLowerCase() == 'rent' ||
            propertyType.toLowerCase() == 'rented')
        ? Colors.amber
        : Colors.blue;
    return Container(
      height: 24.rh(context),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(48),
      ),
      child: CustomText(
        propertyType.toLowerCase().translate(context),
        fontWeight: .w500,
        fontSize: context.font.xxs,
        color: color,
      ),
    );
  }
}
