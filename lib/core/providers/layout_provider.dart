import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/local/shared_preferences_services.dart';

final appLayoutProvider = StateNotifierProvider<AppLayoutNotifier, bool>((ref) {
  return AppLayoutNotifier();
});

class AppLayoutNotifier extends StateNotifier<bool> {
  AppLayoutNotifier() : super(true) {
    _loadPreference();
  }

  final _prefs = SessionPrefences();

  Future<void> _loadPreference() async {
    state = await _prefs.getLayoutPreference();
  }

  Future<void> toggleLayout() async {
    state = !state;
    await _prefs.setLayoutPreference(state);
  }

  Future<void> setLayout(bool isVertical) async {
    state = isVertical;
    await _prefs.setLayoutPreference(state);
  }
}
