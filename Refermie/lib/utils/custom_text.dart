import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/responsive_size.dart';
import 'package:flutter/material.dart';

class CustomText extends StatelessWidget {
  const CustomText(
    this.text, {
    super.key,
    this.color,
    this.showLineThrough = false,
    this.fontWeight,
    this.fontStyle,
    this.fontSize,
    this.textAlign,
    this.maxLines = 10,
    this.showUnderline = false,
    this.underlineOrLineColor,
    this.letterSpacing,
    this.textBaseline,
    this.isRichText = false,
    this.textSpan,
  });

  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? fontSize;
  final TextAlign? textAlign;
  final int maxLines;
  final bool showLineThrough;
  final bool showUnderline;
  final Color? underlineOrLineColor;
  final double? letterSpacing;
  final TextBaseline? textBaseline;
  final bool isRichText;
  final InlineSpan? textSpan;

  @override
  Widget build(BuildContext context) {
    final decoration = showLineThrough
        ? TextDecoration.lineThrough
        : showUnderline
        ? TextDecoration.underline
        : null;

    final style = TextStyle(
      color: color ?? context.color.textColorDark,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      fontSize: fontSize?.rf(context),
      decoration: decoration,
      decorationColor: underlineOrLineColor,
      height: 1.3,
      letterSpacing: letterSpacing,
      textBaseline: textBaseline,
    );

    return isRichText
        ? Text.rich(
            textSpan!,
            maxLines: maxLines,
            overflow: .ellipsis,
            softWrap: true,
          )
        : Text(
            text,
            maxLines: maxLines,
            overflow: .ellipsis,
            softWrap: true,
            style: style,
            textAlign: textAlign,
          );
  }
}
