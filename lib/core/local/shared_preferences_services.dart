import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lets_vhandar/features/auth/login/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionPreferences {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(),
  );
  static const _tokenKey = 'auth_token';

  static Future<SharedPreferences> _prefs() async =>
      SharedPreferences.getInstance();

  Future<void> setToken({required String token}) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: _tokenKey);
  }

  Future<void> setUser({required UserModel user}) async {
    final prefs = await _prefs();
    await prefs.setString('user_data', jsonEncode(user.toMap()));
  }

  Future<UserModel?> getUser() async {
    final prefs = await _prefs();
    final userString = prefs.getString('user_data');
    if (userString != null) {
      return UserModel.fromMap(jsonDecode(userString));
    }
    return null;
  }

  Future<void> setGuestMode({required bool isGuest}) async {
    final prefs = await _prefs();
    await prefs.setBool('guest_mode', isGuest);
  }

  Future<bool> getGuestMode() async {
    final prefs = await _prefs();
    return prefs.getBool('guest_mode') ?? false;
  }

  Future<void> clearSession() async {
    await _secureStorage.delete(key: _tokenKey);
    final prefs = await _prefs();
    await prefs.remove('user_data');
    await prefs.remove('guest_mode');
  }

  Future<void> saveRememberMe({
    required String phone,
    required String password,
  }) async {
    await _secureStorage.write(key: 'remember_phone', value: phone);
    await _secureStorage.write(key: 'remember_password', value: password);
    final prefs = await _prefs();
    await prefs.setBool('remember_me', true);
  }

  Future<Map<String, String?>> getRememberMe() async {
    final prefs = await _prefs();
    final enabled = prefs.getBool('remember_me') ?? false;
    if (!enabled) return {'phone': null, 'password': null};
    return {
      'phone': await _secureStorage.read(key: 'remember_phone'),
      'password': await _secureStorage.read(key: 'remember_password'),
    };
  }

  Future<void> clearRememberMe() async {
    await _secureStorage.delete(key: 'remember_phone');
    await _secureStorage.delete(key: 'remember_password');
    final prefs = await _prefs();
    await prefs.remove('remember_me');
  }

  Future<void> setLayoutPreference(bool isVertical) async {
    final prefs = await _prefs();
    await prefs.setBool('is_vertical_layout', isVertical);
  }

  Future<bool> getLayoutPreference() async {
    final prefs = await _prefs();
    return prefs.getBool('is_vertical_layout') ?? true;
  }
}
