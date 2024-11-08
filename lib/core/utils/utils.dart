import 'package:flutter/services.dart';

splitName({required String fullName}) {
  List<String> parts = fullName.split(" ");
  String firstName = parts[0];
  String lastName = parts[1];
  return [firstName, lastName];
}

class TenDigitInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Allow only up to 10 digits
    if (newValue.text.length > 10) {
      return oldValue;
    }

    // Check if the new input contains only digits
    final RegExp regex = RegExp(r'^\d{0,10}$');
    if (regex.hasMatch(newValue.text)) {
      return newValue;
    }

    // If it doesn't match, keep the old value
    return oldValue;
  }
}
