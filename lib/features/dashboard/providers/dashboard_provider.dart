import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardIndexProvider = StateProvider<int>((ref) => 0);

// Tracks which tabs have been built — must be marked before switching index
final visitedTabsProvider = StateProvider<Set<int>>((ref) => {0});

// Incremented each time the user taps the tab that is already active.
// Each tab watches tabReactivateProvider(itsIndex) and scrolls to top / refreshes.
final tabReactivateProvider =
    StateProvider.family<int, int>((ref, tabIndex) => 0);
