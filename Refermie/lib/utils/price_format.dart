import 'package:ebroker/settings.dart';
import 'package:ebroker/utils/hive_utils.dart';
import 'package:flutter/material.dart';

extension StringPriceFormat on String {
  String priceFormat({
    required BuildContext context,
    bool? enabled,
  }) {
    final currencyCode = AppSettings.currencyCode;
    final currencySymbol = AppSettings.currencySymbol.isNotEmpty
        ? AppSettings.currencySymbol
        : _getDefaultSymbol(currencyCode);
    final locale = HiveUtils.getLanguageCode();

    try {
      final numericValue = double.parse(this);

      // When enabled is true, use custom abbreviation formatting
      if ((enabled ?? false) && currencyCode.isNotEmpty) {
        final config = CurrencyAbbreviationConfig._getRulesForCurrency(
          currencyCode.toUpperCase(),
        );

        for (final rule in config) {
          if (numericValue >= rule.threshold) {
            final dividedValue = numericValue / rule.threshold;
            var formattedValue = '';
            if (dividedValue == dividedValue.toInt()) {
              formattedValue = dividedValue.toStringAsFixed(0);
            } else {
              formattedValue = dividedValue.toStringAsFixed(2);
            }
            return '$currencySymbol $formattedValue ${rule.suffix}';
          }
        }
      }

      // Custom currency formatting without NumberFormat
      return _formatCurrency(numericValue, currencySymbol, locale);
    } on Exception catch (e) {
      debugPrint('Error formatting price: $e');
      return this;
    }
  }

  String _formatCurrency(double value, String symbol, String locale) {
    final isNegative = value < 0;
    final absoluteValue = value.abs();

    // Format the number with 2 decimal places
    final formattedNumber = _formatNumber(absoluteValue, locale);

    // Handle negative values
    final prefix = isNegative ? '-' : '';

    // Different currency symbol placement based on locale/currency
    if (_isSymbolAfterAmount(locale)) {
      return '$prefix $formattedNumber $symbol';
    } else {
      return '$prefix $symbol $formattedNumber';
    }
  }

  String _formatNumber(double value, String locale) {
    // Convert to string with 2 decimal places
    final parts = value.toStringAsFixed(2).split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];

    // Add thousand separators based on locale
    final separator = _getThousandSeparator(locale);
    final formattedInteger = _addThousandSeparators(integerPart, separator);

    // Use locale-specific decimal separator
    final decimalSeparator = _getDecimalSeparator(locale);

    if (decimalPart == '00') {
      return formattedInteger;
    }
    return '$formattedInteger$decimalSeparator$decimalPart';
  }

  String _addThousandSeparators(String number, String separator) {
    if (number.length <= 3) return number;

    final reversed = number.split('').reversed.join();
    final chunks = <String>[];

    for (var i = 0; i < reversed.length; i += 3) {
      final end = (i + 3 > reversed.length) ? reversed.length : i + 3;
      chunks.add(reversed.substring(i, end));
    }

    return chunks.join(separator).split('').reversed.join();
  }

  String _getThousandSeparator(String locale) {
    // European locales typically use space or period
    if (locale.startsWith('de') ||
        locale.startsWith('fr') ||
        locale.startsWith('it') ||
        locale.startsWith('es')) {
      return ' ';
    }
    // Indian numbering system
    if (locale.startsWith('hi') || locale.startsWith('bn')) {
      return ',';
    }
    // Default to comma for most locales including en-US
    return ',';
  }

  String _getDecimalSeparator(String locale) {
    // European locales typically use comma as decimal separator
    if (locale.startsWith('de') ||
        locale.startsWith('fr') ||
        locale.startsWith('it') ||
        locale.startsWith('es')) {
      return ',';
    }
    // Default to period for most locales
    return '.';
  }

  bool _isSymbolAfterAmount(String locale) {
    // Some locales place currency symbol after the amount
    return locale.startsWith('fr') ||
        locale.startsWith('de') ||
        locale.startsWith('it') ||
        locale.startsWith('es');
  }

  String _getDefaultSymbol(String currencyCode) {
    const symbols = {
      'USD': r'$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'INR': '₹',
      'CNY': '¥',
      'KRW': '₩',
      'BDT': '৳',
      'NPR': '₨',
      'PKR': '₨',
      'LKR': '₨',
    };
    return symbols[currencyCode.toUpperCase()] ?? r'$';
  }
}

class CurrencyAbbreviationConfig {
  CurrencyAbbreviationConfig(this.rules);
  final List<AbbreviationRule> rules;

  static List<AbbreviationRule> _getRulesForCurrency(String currencyCode) {
    // Use const for better performance
    const southAsianCurrencies = ['INR', 'BDT', 'NPR', 'PKR', 'LKR'];
    const eastAsianCurrencies = ['JPY', 'CNY', 'KRW'];

    if (southAsianCurrencies.contains(currencyCode)) {
      return const [
        AbbreviationRule(10000000, 'Cr'),
        AbbreviationRule(100000, 'L'),
        AbbreviationRule(1000, 'K'),
      ];
    } else if (eastAsianCurrencies.contains(currencyCode)) {
      return const [
        AbbreviationRule(100000000, '億'),
        AbbreviationRule(10000, '万'),
      ];
    } else {
      // Western system (default)
      return const [
        AbbreviationRule(1000000000, 'B'),
        AbbreviationRule(1000000, 'M'),
        AbbreviationRule(1000, 'K'),
      ];
    }
  }
}

class AbbreviationRule {
  const AbbreviationRule(this.threshold, this.suffix);
  final int threshold;
  final String suffix;
}
