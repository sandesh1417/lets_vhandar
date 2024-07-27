import 'package:shared_preferences/shared_preferences.dart';

class SessionPrefences {
  static Future<SharedPreferences> _initSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs;
  }

  Future<void> setToken({required String token}) async {
    SharedPreferences prefs = await _initSharedPreferences();
    // var encryptedToken = encryptText(token);
    prefs.setString('apple', token);
  }

  Future<String?> getToken() async {
    SharedPreferences prefs = await _initSharedPreferences();
    String? token = prefs.getString('apple');
    return token;
    // if (encryptedToken != null) {
    //   // var decryptedToken = decryptText(encryptedToken);
    //   // return decryptedToken;
    // } else {
    //   return null;
    // }
  }

  // Future<void> setSession({required LoginModal userSession}) async {
  //   SharedPreferences prefs = await _initSharedPreferences();

  //   prefs.setString('session', jsonEncode(userSession));
  // }

  // Future<LoginModal?> getSession() async {
  //   SharedPreferences prefs = await _initSharedPreferences();
  //   String? sessionString = prefs.getString('session');
  //   if (sessionString != null) {
  //     LoginModal session = LoginModal.fromJson(jsonDecode(sessionString));
  //     return session;
  //   } else {
  //     return null;
  //   }
  // }

  Future<bool> clearSession() async {
    SharedPreferences prefs = await _initSharedPreferences();
    return prefs.remove('apple');
  }
}
