import 'dart:convert';
import 'package:vhandar/features/auth/login/models/user_model.dart';
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

  Future<void> setUser({required UserModel user}) async {
    SharedPreferences prefs = await _initSharedPreferences();
    prefs.setString('user_data', jsonEncode(user.toMap()));
  }

  Future<UserModel?> getUser() async {
    SharedPreferences prefs = await _initSharedPreferences();
    String? userString = prefs.getString('user_data');
    if (userString != null) {
      return UserModel.fromMap(jsonDecode(userString));
    }
    return null;
  }

  Future<void> clearSession() async {
    SharedPreferences prefs = await _initSharedPreferences();
    await prefs.remove('apple');
    await prefs.remove('user_data');
  }
}
