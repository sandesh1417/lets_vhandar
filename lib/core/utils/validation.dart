// import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

extension ValidateExtension on String {
  bool get isEmailValid => RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z][a-zA-Z]+").hasMatch(this);

  bool get isPasswordValid => RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$').hasMatch(this);
}

// final MaskTextInputFormatter dateFormatter =
//     MaskTextInputFormatter(mask: '####-##-##', filter: {"#": RegExp(r'[0-9]')});

class LoginValidators {
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone is required';
    }

    if (value.length < 10) {
      return 'Please enter 10 digits';
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
}
