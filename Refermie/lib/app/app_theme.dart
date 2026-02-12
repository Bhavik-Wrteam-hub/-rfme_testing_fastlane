import 'package:ebroker/ui/theme/theme.dart';
import 'package:flutter/material.dart';

final commonThemeData = ThemeData(
  useMaterial3: true,
  fontFamily: 'PrimaryFont',
  splashColor: Colors.transparent,
  splashFactory: NoSplash.splashFactory,
  textSelectionTheme: TextSelectionThemeData(
    selectionColor: tertiaryColor_.withValues(alpha: 0.3),
    cursorColor: tertiaryColor_,
    selectionHandleColor: tertiaryColor_,
  ),
);

final Map<Brightness, ThemeData> appThemeData = {
  .light: commonThemeData.copyWith(
    navigationBarTheme: const NavigationBarThemeData(
      backgroundColor: primaryColor_,
      elevation: 0,
    ),
    brightness: .light,
    cardColor: tertiaryColor_,
    scrollbarTheme: const ScrollbarThemeData(radius: Radius.circular(8)),
    colorScheme: ColorScheme.fromSeed(seedColor: tertiaryColor_),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(tertiaryColor_),
      trackColor: .resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return tertiaryColor_.withValues(alpha: 0.3);
        }
        return primaryColorDark;
      }),
    ),
  ),
  .dark: commonThemeData.copyWith(
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: primaryColorDark,
      elevation: 0,
    ),
    brightness: .dark,
    cardColor: tertiaryColor_.withValues(alpha: 0.7),
    scrollbarTheme: const ScrollbarThemeData(radius: Radius.circular(8)),
    colorScheme: .fromSeed(
      brightness: .dark,
      seedColor: tertiaryColor_,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: const WidgetStatePropertyAll(tertiaryColor_),
      trackColor: .resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return tertiaryColor_.withValues(alpha: 0.3);
        }
        return primaryColor_.withValues(alpha: 0.2);
      }),
    ),
  ),
};
