import 'dart:async';

import 'package:flutter/widgets.dart';

/// App-wide "is the user scrolling right now?" signal.
///
/// A single [NotificationListener] at the app root feeds this (see `MyApp`),
/// so any widget can react to scrolling without each screen wiring up its own
/// controller. It flips to `true` on the first scroll event and back to
/// `false` a short debounce after scrolling stops.
class AppScrollActivity {
  AppScrollActivity._();

  static final ValueNotifier<bool> isScrolling = ValueNotifier<bool>(false);

  static Timer? _idleTimer;

  /// How long after the last scroll event we consider scrolling "stopped".
  static const _idleAfter = Duration(milliseconds: 240);

  /// Call on every [ScrollNotification].
  static void notify() {
    if (!isScrolling.value) isScrolling.value = true;
    _idleTimer?.cancel();
    _idleTimer = Timer(_idleAfter, () {
      isScrolling.value = false;
    });
  }
}
