import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardIndexProvider = StateProvider<int>((ref) => 0);

// Tracks which tabs have been built — must be marked before switching index
final visitedTabsProvider = StateProvider<Set<int>>((ref) => {0});
