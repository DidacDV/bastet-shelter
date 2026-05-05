class Validators {
  static String? validEmail(String val) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegExp.hasMatch(val)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your email';
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
      return 'Please enter your $fieldName';
    }
    return null;
  }

  static String? validatePositiveNumber(
    String? value, {
    String fieldName = 'value',
  }) {
    if (value == null || value.isEmpty) return 'Please enter a $fieldName';
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Please enter a valid number';
    if (parsed <= 0) return '$fieldName must be greater than 0';
    return null;
  }

  static String? validateDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return null;
    if (end.isBefore(start)) return 'End date must be after start date';
    return null;
  }
}
