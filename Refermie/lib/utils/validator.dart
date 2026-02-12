import 'package:ebroker/utils/extensions/extensions.dart';
import 'package:flutter/material.dart';

class Validator {
  Validator();

  static String slugIdPattern = r'^[a-zA-Z0-9-_]+$';
  static String? validateSlugId(BuildContext context, String? slugId) {
    if ((slugId ?? '').trim().isNotEmpty &&
        !RegExp(slugIdPattern).hasMatch(slugId ?? '')) {
      return 'enterValidSlugId'.translate(context);
    } else {
      return null;
    }
  }

  static String emailPattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static String? validateEmail(BuildContext context, String? email) {
    final trimmedEmail = email?.trim() ?? '';
    if (trimmedEmail.isEmpty) {
      return 'fieldMustNotBeEmpty'.translate(context);
    } else if (!RegExp(emailPattern).hasMatch(trimmedEmail)) {
      return 'enterValidEmail'.translate(context);
    } else {
      return null;
    }
  }

  static String? validateUrl(BuildContext context, String value) {
    // Regular expression for a simple URL validation
    // This may not cover all edge cases, but it's a basic example
    final urlRegExp = RegExp(
      r'^(http(s)?:\/\/)?([0-9a-zA-Z-]+\.)+[a-zA-Z]{2,}(:[0-9]+)?(\/.*)?$',
    );

    if (urlRegExp.hasMatch(value)) {
      return null; // Valid URL
    } else {
      return 'invalidUrl'.translate(context);
    }
  }

  static String? emptyValueValidation(
    BuildContext context,
    String? value, {
    String? errmsg = 'fieldMustNotBeEmpty',
  }) {
    return (value ?? '').trim().isEmpty ? errmsg?.translate(context) : null;
  }

  static String? validatePhoneNumber(BuildContext context, String? value) {
    final trimmedValue = value?.trim() ?? '';
    final middleSpaceTrimmedValue = trimmedValue.replaceAll(' ', '');
    final pattern = RegExp(r'^[0-9]{6,15}$');

    if (middleSpaceTrimmedValue.isEmpty) {
      return 'fieldMustNotBeEmpty'.translate(context);
    }

    if (!pattern.hasMatch(middleSpaceTrimmedValue)) {
      return 'enterValidPhoneNumber'.translate(
        context,
      ); // Handle invalid format
    }

    return null; // Input is valid, no error message
  }

  static String? validateName(
    BuildContext context,
    String? value, {
    String? errmsg = 'fieldMustNotBeEmpty',
  }) {
    final pattern = RegExp(r'^[a-zA-Z ]+$');
    if ((value ?? '').trim().isEmpty) {
      return errmsg?.translate(context);
    } else if (!pattern.hasMatch(value ?? '')) {
      return 'enterOnlyAlphabets'.translate(context);
    } else {
      return null;
    }
  }

  static String? nullCheckValidator(
    BuildContext context,
    String? value, {
    int? requiredLength,
  }) {
    if (value!.isEmpty) {
      return 'fieldMustNotBeEmpty'.translate(context);
    } else if (requiredLength != null) {
      if (value.length < requiredLength) {
        return '${'textMustBe'.translate(context)} $requiredLength ${'charactersLong'.translate(context)}';
      } else {
        return null;
      }
    }

    return null;
  }

  //byAnish
  static String? validatePassword(
    BuildContext context,
    String? password, {
    String? secondFieldValue,
  }) {
    if (password!.isEmpty) {
      return 'fieldMustNotBeEmpty'.translate(context);
    } else if (password.length < 6) {
      return 'passwordLengthError'.translate(context);
    }
    if (secondFieldValue != null) {
      if (password != secondFieldValue) {
        return 'bothPasswordsMustBeMatch'.translate(context);
      }
    }

    return null;
  }

  static String? validatePrice(BuildContext context, String? value) {
    if (value == null || value.isEmpty) {
      return 'fieldMustNotBeEmpty'.translate(context);
    }
    if ((double.tryParse(value) ?? 0) >= 9223372036854775807) {
      return 'pleaseEnterValidPrice'.translate(context);
    }
    return null;
  }
}
