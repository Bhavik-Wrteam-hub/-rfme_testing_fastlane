import 'package:ebroker/utils/custom_text.dart';
import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:ebroker/utils/ui_utils.dart';
import 'package:flutter/material.dart';

class Widgets {
  static bool isLoaderShowing = false;

  static Future<void> showLoader(BuildContext? context) async {
    if (context == null || !context.mounted || isLoaderShowing) return;

    try {
      isLoaderShowing = true;

      await showDialog<dynamic>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return SafeArea(
            child: PopScope(
              canPop: false,
              onPopInvokedWithResult: (didPop, _) async {
                if (didPop) return;
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: Center(
                child: UiUtils.progress(
                  normalProgressColor: context.color.tertiaryColor,
                ),
              ),
            ),
          );
        },
      );
    } on Exception catch (e) {
      debugPrint('Error showing loader: $e');
      isLoaderShowing = false;
    }
  }

  static void hideLoader(BuildContext? context) {
    if (context == null || !context.mounted || !isLoaderShowing) return;

    try {
      isLoaderShowing = false;
      // Use Navigator.of(context, rootNavigator: true) to ensure we're
      // closing the dialog regardless of nested navigator contexts
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    } on Exception catch (e) {
      debugPrint('Error hiding loader: $e');
      isLoaderShowing = false;
    }
  }

  // Keeping old method for backward compatibility
  static void hideLoder(BuildContext? context) {
    hideLoader(context);
  }

  static Center noDataFound(String errorMsg) {
    return Center(child: CustomText(errorMsg));
  }
}
