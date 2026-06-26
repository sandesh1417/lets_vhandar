import 'package:shared_preferences/shared_preferences.dart';

/// Tiny SharedPreferences-backed string cache. Stores raw JSON strings under a
/// key; callers own (de)serialization (each model already has toJson/fromMap).
///
/// Used for stale-while-revalidate: category / subcategory screens paint
/// instantly from disk on cold start, then refresh from the network in the
/// background — so the user never stares at a spinner on a screen they've
/// already opened before.
class JsonCache {
  const JsonCache._();

  static Future<void> write(String key, String jsonStr) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, jsonStr);
  }

  static Future<String?> read(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<void> remove(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}
