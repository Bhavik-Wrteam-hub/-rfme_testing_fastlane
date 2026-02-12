import 'dart:ui';

class AppSettingsDataModel {
  AppSettingsDataModel({
    required this.lightTertiary,
    required this.lightSecondary,
    required this.lightPrimary,
    required this.darkTertiary,
    required this.darkSecondary,
    required this.darkPrimary,
    this.placeholderLogo,
    this.appHomeScreen,
    this.darkModeLogo,
    this.isUserActive,
  });

  AppSettingsDataModel.fromJson(Map<String, dynamic> json)
    : lightTertiary = _colorFromHex(json['light_tertiary']?.toString() ?? ''),
      placeholderLogo = json['placeholder_logo']?.toString() ?? '',
      lightSecondary = _colorFromHex(json['light_secondary']?.toString() ?? ''),
      lightPrimary = _colorFromHex(json['light_primary']?.toString() ?? ''),
      darkTertiary = _colorFromHex(json['dark_tertiary']?.toString() ?? ''),
      darkSecondary = _colorFromHex(json['dark_secondary']?.toString() ?? ''),
      darkPrimary = _colorFromHex(json['dark_primary']?.toString() ?? ''),
      isUserActive = json['is_active'] as bool? ?? true,
      appHomeScreen = json['app_home_screen']?.toString() ?? '',
      darkModeLogo = json['dark_mode_logo']?.toString() ?? '';
  Color lightTertiary;
  String? placeholderLogo;
  Color lightSecondary;
  Color lightPrimary;
  Color darkTertiary;
  Color darkSecondary;
  Color darkPrimary;
  String? appHomeScreen;
  bool? isUserActive;
  String? darkModeLogo;
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['light_tertiary'] = _colorToHex(lightTertiary);
    data['placeholder_logo'] = placeholderLogo;
    data['light_secondary'] = _colorToHex(lightSecondary);
    data['light_primary'] = _colorToHex(lightPrimary);
    data['dark_tertiary'] = _colorToHex(darkTertiary);
    data['dark_secondary'] = _colorToHex(darkSecondary);
    data['dark_primary'] = _colorToHex(darkPrimary);
    data['app_home_screen'] = appHomeScreen;
    data['isUserActive'] = isUserActive;
    data['dark_mode_logo'] = darkModeLogo;
    return data;
  }

  // Helper function to convert color from hex string to Color
  static Color _colorFromHex(String hexColor) {
    final buffer = StringBuffer();
    if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
    buffer.write(hexColor.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  // Helper function to convert Color to hex string
  static String _colorToHex(Color color) {
    final red = (color.r * 255).toInt().toRadixString(16).substring(2);
    final green = (color.g * 255).toInt().toRadixString(16).substring(2);
    final blue = (color.b * 255).toInt().toRadixString(16).substring(2);

    return '#$red$green$blue';
  }
}
