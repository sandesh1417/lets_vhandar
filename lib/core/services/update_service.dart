import 'dart:convert';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

enum UpdateType { optional, forced }

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  UpdateType _updateType = UpdateType.optional;
  UpdateType get updateType => _updateType;

  Future<void> initialize() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 5),
      ));

      await remoteConfig.setDefaults(const {
        'update_config':
            '{"force_versions":[],"min_supported_version":"0.0.0"}',
      });

      await remoteConfig.fetchAndActivate();

      final raw = remoteConfig.getString('update_config');
      final config = jsonDecode(raw) as Map<String, dynamic>;

      final packageInfo = await PackageInfo.fromPlatform();
      final current = packageInfo.version;

      final forceVersions = (config['force_versions'] as List).cast<String>();
      final minVersion =
          (config['min_supported_version'] as String?) ?? '0.0.0';
      if (forceVersions.contains(current) ||
          _isVersionBelow(current, minVersion)) {
        _updateType = UpdateType.forced;
      } else {
        _updateType = UpdateType.optional;
      }
    } catch (e) {
      // Fail open — never block the user if Remote Config is unreachable.
      debugPrint('[UpdateService] Fetch failed, defaulting to optional: $e');
      _updateType = UpdateType.optional;
    }
  }

  // Returns true when [current] is strictly less than [min].
  bool _isVersionBelow(String current, String min) {
    final c = _parse(current);
    final m = _parse(min);
    for (int i = 0; i < 3; i++) {
      final cv = i < c.length ? c[i] : 0;
      final mv = i < m.length ? m[i] : 0;
      if (cv < mv) return true;
      if (cv > mv) return false;
    }
    return false; // equal is not below
  }

  List<int> _parse(String version) {
    // Strip build metadata / pre-release (e.g. "1.2.3+4" → "1.2.3").
    final clean = version.split('+').first.split('-').first;
    return clean.split('.').map((s) => int.tryParse(s) ?? 0).toList();
  }
}
