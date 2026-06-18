// import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

extension ValidateExtension on String {
  bool get isEmailValid => RegExp(
          r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z][a-zA-Z]+")
      .hasMatch(this);

  bool get isPasswordValid =>
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$')
          .hasMatch(this);
}

// final MaskTextInputFormatter dateFormatter =
//     MaskTextInputFormatter(mask: '####-##-##', filter: {"#": RegExp(r'[0-9]')});

/// Single source of truth for form field validation across the app.
///
/// All validators return `null` when valid and a user-facing error string
/// otherwise. Error copy is standardized here — do not duplicate validator
/// logic or re-word these messages per screen.
class AppValidators {
  AppValidators._();

  /// Standard copy for an empty required field.
  static const String requiredMessage = 'This field is required';

  /// Generic "required" validator. Trims whitespace before checking.
  static String? required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return requiredMessage;
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }
    if (value.length != 10) {
      return 'Enter a valid 10-digit number';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }
    if (!value.isEmailValid) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }
    if (!RegExp(r'^\d{6}$').hasMatch(value.trim())) {
      return 'Enter a valid 6-digit pincode';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return requiredMessage;
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateBusinessName(String? value) => required(value);

  static String? validatePanNumber(String? value) => required(value);

  static String? validateName(String? value) => required(value);
}
