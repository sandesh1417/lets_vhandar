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
