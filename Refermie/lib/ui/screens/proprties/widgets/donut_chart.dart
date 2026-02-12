import 'dart:math' show pi;

import 'package:ebroker/exports/main_export.dart';
import 'package:ebroker/utils/price_format.dart';
import 'package:flutter/material.dart';

class EMIDonutChart extends StatefulWidget {
  const EMIDonutChart({
    required this.principalAmount,
    required this.interestPayable,
    required this.monthlyEMI,
    super.key,
  });
  final double principalAmount;
  final double interestPayable;
  final double monthlyEMI;

  @override
  State<EMIDonutChart> createState() => _EMIDonutChartState();
}

class _EMIDonutChartState extends State<EMIDonutChart> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            Stack(
              alignment: Alignment.topCenter,
              children: [
                CustomPaint(
                  size: Size(constraints.maxWidth, constraints.maxWidth * 0.5),
                  painter: SemiCircleChartPainter(
                    context: context,
                    principalAmount: widget.principalAmount,
                    interestPayable: widget.interestPayable,
                    isRTL: Directionality.of(context) == .rtl,
                  ),
                ),
                PositionedDirectional(
                  top: constraints.maxWidth *
                      0.25, // Adjust position of center text
                  child: Column(
                    mainAxisSize: .min,
                    children: [
                      CustomText(
                        'totalAmount'.translate(context),
                        fontSize: context.font.md,
                        fontWeight: .w500,
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 4),
                      CustomText(
                        (widget.principalAmount + widget.interestPayable)
                            .toString()
                            .priceFormat(context: context),
                        fontSize: context.font.lg,
                        fontWeight: .bold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _LegendItem(
                  isLast: false,
                  color: context.color.tertiaryColor,
                  label: 'principalAmount'.translate(context),
                  value: widget.principalAmount.toString(),
                ),
                const Spacer(),
                _LegendItem(
                  isLast: true,
                  color: Colors.grey.shade700,
                  label: 'payableInterest'.translate(context),
                  value: widget.interestPayable.toString(),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class SemiCircleChartPainter extends CustomPainter {
  SemiCircleChartPainter({
    required this.principalAmount,
    required this.interestPayable,
    required this.context,
    required this.isRTL, // Add RTL parameter
  });

  final double principalAmount;
  final double interestPayable;
  final BuildContext context;
  final bool isRTL;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width * 0.45;
    final strokeWidth = size.width * 0.1;

    final total = principalAmount + interestPayable;
    final principalAngle = (principalAmount / total) * pi;
    final interestAngle = (interestPayable / total) * pi;

    // Determine the starting angle based on RTL setting
    final startAngle = isRTL ? 0.0 : -pi;
    // Determine the sweep direction based on RTL setting
    final sweepMultiplier = isRTL ? -1 : 1;

    // Draw background arc
    final bgPaint = Paint()
      ..color = context.color.secondaryColor
      ..style = .stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      pi * sweepMultiplier, // Flip the sweep direction for RTL
      false,
      bgPaint,
    );

    // Draw principal arc
    final principalPaint = Paint()
      ..color = context.color.tertiaryColor
      ..style = .stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      principalAngle * sweepMultiplier,
      false,
      principalPaint,
    );

    // Draw interest arc
    final interestPaint = Paint()
      ..color = Colors.grey.shade700
      ..style = .stroke
      ..strokeWidth = strokeWidth;

    final interestStartAngle = startAngle + (principalAngle * sweepMultiplier);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      interestStartAngle,
      interestAngle * sweepMultiplier,
      false,
      interestPaint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.value,
    required this.isLast,
  });
  final Color color;
  final String label;
  final String value;
  final bool isLast;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 4),
        Row(
          children: [
            if (isLast) ...[
              Column(
                crossAxisAlignment: .end,
                children: [
                  CustomText(
                    label,
                    fontSize: context.font.xs,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment:
                        isLast ? Alignment.centerRight : Alignment.centerLeft,
                    child: CustomText(
                      value.priceFormat(context: context),
                      fontSize: context.font.sm,
                      fontWeight: .bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 4),
              Container(
                width: 12.rw(context),
                height: 12.rh(context),
                decoration: BoxDecoration(
                  color: color,
                  shape: .circle,
                ),
              ),
              const SizedBox(width: 8),
            ],
            if (!isLast) ...[
              const SizedBox(width: 8),
              Container(
                width: 12.rw(context),
                height: 12.rh(context),
                decoration: BoxDecoration(
                  color: color,
                  shape: .circle,
                ),
              ),
              const SizedBox(width: 4),
              Column(
                crossAxisAlignment: .start,
                children: [
                  CustomText(
                    label,
                    fontSize: context.font.xs,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 2),
                  Align(
                    alignment:
                        isLast ? Alignment.centerRight : Alignment.centerLeft,
                    child: CustomText(
                      value.priceFormat(context: context),
                      fontSize: context.font.sm,
                      fontWeight: .bold,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ],
    );
  }
}
