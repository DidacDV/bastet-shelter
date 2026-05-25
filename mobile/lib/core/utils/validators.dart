import 'package:bastetshelter/core/localization/app_localizations.dart';
import 'package:bastetshelter/core/navigation_service.dart';

class Validators {
  static String _t(String key, String fallback) {
    final context = NavigationService.instance.navigationKey.currentContext;
    return context?.l10n.t(key) ?? fallback;
  }

  static String _tp(String key, String fallback, Map<String, String> params) {
    var value = _t(key, fallback);
    for (final entry in params.entries) {
      value = value.replaceAll('{${entry.key}}', entry.value);
    }
    return value;
  }

  static String? validEmail(String val) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(val)) {
      return _t('validation.validEmail', 'Please enter a valid email address');
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return _t('validation.emailRequired', 'Please enter your email');
    }
    return validEmail(value);
  }

  static String? validateEmailNoRequired(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return validEmail(value);
  }

  static String? validatePassword(String? value) {
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return _tp('validation.required', 'Please enter your {field}', {
        'field': fieldName,
      });
    }
    return null;
  }

  static String? validatePositiveNumber(
    String? value, {
    String fieldName = 'value',
  }) {
    if (value == null || value.isEmpty) {
      return _tp('validation.requiredArticle', 'Please enter a {field}', {
        'field': fieldName,
      });
    }
    final parsed = double.tryParse(value);
    if (parsed == null) {
      return _t('validation.validNumber', 'Please enter a valid number');
    }
    if (parsed <= 0) {
      return _tp(
        'validation.greaterThanZero',
        '{field} must be greater than 0',
        {'field': fieldName},
      );
    }
    return null;
  }

  static String? validateDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    if (end.isBefore(start)) {
      return _t(
        'validation.endAfterStart',
        'End date must be after start date',
      );
    }
    return null;
  }
}
