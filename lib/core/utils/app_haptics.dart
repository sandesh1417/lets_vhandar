import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';

/// Centralised haptics.
///
/// On Android, Flutter's [HapticFeedback] maps to `View.performHapticFeedback`,
/// which is silently suppressed when the device's system "Touch vibration /
/// Haptic feedback" setting is off — so users feel nothing. To guarantee a
/// buzz on key moments we drive the vibration motor directly via the
/// `vibration` package (needs the VIBRATE permission), and fall back to the
/// platform [HapticFeedback] when the motor isn't available (e.g. iOS, where
/// native haptics are the right call anyway).
class AppHaptics {
  AppHaptics._();

  static bool _checked = false;
  static bool _hasVibrator = false;
  static bool _hasAmplitude = false;

  /// Detect device capabilities once. Only caches on success, so a transient
  /// failure (e.g. plugin not yet registered) is retried on the next call.
  static Future<void> _ensureCaps() async {
    if (_checked) return;
    try {
      _hasVibrator = await Vibration.hasVibrator();
      _hasAmplitude = await Vibration.hasAmplitudeControl();
      _checked = true;
      if (kDebugMode) {
        debugPrint('[AppHaptics] hasVibrator=$_hasVibrator '
            'hasAmplitude=$_hasAmplitude');
      }
    } catch (e) {
      // Most commonly MissingPluginException → the app wasn't fully rebuilt
      // after adding the vibration plugin. Don't cache; fall back for now.
      if (kDebugMode) debugPrint('[AppHaptics] capability check failed: $e');
      _hasVibrator = false;
      _hasAmplitude = false;
    }
  }

  /// Vibrate for [ms] at [amplitude] (1–255), falling back to the platform
  /// haptic chosen by [fallback] when the motor isn't usable.
  static Future<void> _buzz(
    int ms,
    int amplitude,
    Future<void> Function() fallback,
  ) async {
    await _ensureCaps();
    if (_hasVibrator) {
      try {
        if (_hasAmplitude) {
          await Vibration.vibrate(duration: ms, amplitude: amplitude);
        } else {
          await Vibration.vibrate(duration: ms);
        }
        return;
      } catch (e) {
        if (kDebugMode) debugPrint('[AppHaptics] vibrate failed: $e');
      }
    }
    await fallback();
  }

  // ── Intensities ──────────────────────────────────────────────────────────
  // Durations are tuned to be actually perceptible on real devices (sub-30ms
  // buzzes are easy to miss). light < medium < heavy.

  /// A light tick — navigation, tab switch, selection, toggles.
  static Future<void> light() => _buzz(35, 150, HapticFeedback.selectionClick);

  /// A medium confirmation — committed actions (add to cart, apply coupon).
  static Future<void> medium() => _buzz(55, 190, HapticFeedback.mediumImpact);

  /// A strong buzz — celebratory endpoints (order placed).
  static Future<void> heavy() => _buzz(80, 255, HapticFeedback.heavyImpact);

  /// A distinct "error" double-pulse — reads as negative/rejected, unlike the
  /// single buzzes above. Use on submit-time failures (form validation, a
  /// rejected action) — NOT on per-keystroke inline validation, or it spams.
  static Future<void> error() async {
    await _ensureCaps();
    if (_hasVibrator) {
      try {
        // [wait, buzz, gap, buzz] — two quick pulses.
        await Vibration.vibrate(pattern: const [0, 35, 90, 55]);
        return;
      } catch (e) {
        if (kDebugMode) debugPrint('[AppHaptics] error pattern failed: $e');
      }
    }
    await HapticFeedback.heavyImpact();
  }

  // ── Semantic aliases (read better at call sites) ─────────────────────────
  static Future<void> addToCart() => medium();
  static Future<void> success() => heavy();
}
