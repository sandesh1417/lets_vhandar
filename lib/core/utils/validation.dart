// import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

extension ValidateExtension on String {
  bool get isEmailValid => RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z][a-zA-Z]+").hasMatch(this);

  bool get isPasswordValid => RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(this);
}

// final MaskTextInputFormatter dateFormatter =
//     MaskTextInputFormatter(mask: '####-##-##', filter: {"#": RegExp(r'[0-9]')});

class TFValidators {
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone is required';
    }
    if (value.length < 10) {
      return 'Please enter 10 digits';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!value.isEmailValid) {
      return 'Enter a valid email address';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirm Password is required';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static bool doPasswordsMatch(String password, String confirmPassword) {
    return password == confirmPassword && confirmPassword.isNotEmpty;
  }

  static String? validateConfirmPasswordRealTime(String? value, String password, bool isConfirmPasswordTouched) {
    if (!isConfirmPasswordTouched) {
      return null; // Don't show validation until user starts typing in confirm password
    }
    if (value == null || value.isEmpty) {
      return 'Confirm Password is required';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }

  static String? validateBusinessName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Business Name is required';
    }
    return null;
  }

  static String? validatePanNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'PAN Number is required';
    }
    return null;
  }

  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    return null;
  }
}
