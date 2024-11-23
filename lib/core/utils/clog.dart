import 'dart:developer';

import 'package:flutter/foundation.dart';

cLog(String message) {
  String greenColor = '\u001b[1;32m';
  if (kDebugMode) {
    log("$greenColor=======================================================================================================================================");
    log("$greenColor CLUB RUNNER LOG $message");
    log("$greenColor=======================================================================================================================================");
  }
}
