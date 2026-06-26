import 'package:package_info_plus/package_info_plus.dart';

/// App metadata read once from the platform at startup ([initialize] is called
/// in `main()` before `runApp`) and then exposed synchronously. Reading it
/// synchronously matters for the splash screen, which paints immediately — a
/// FutureProvider would flicker an empty version on first frame.
class AppInfo {
  AppInfo._();

  /// Marketing version, e.g. "1.0.1" (the part before `+` in pubspec).
  static String version = '';

  /// Build number, e.g. "8" (the part after `+` in pubspec).
  static String buildNumber = '';

  /// "1.0.1+8" — version plus build number when available.
  static String get versionWithBuild =>
      buildNumber.isEmpty ? version : '$version+$buildNumber';

  static Future<void> initialize() async {
    final info = await PackageInfo.fromPlatform();
    version = info.version;
    buildNumber = info.buildNumber;
  }
}
