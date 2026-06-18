import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kHistoryKey = 'search_history';
const _kMaxHistory = 8;

final searchHistoryProvider =
    NotifierProvider<SearchHistoryNotifier, List<String>>(
  SearchHistoryNotifier.new,
);

class SearchHistoryNotifier extends Notifier<List<String>> {
  @override
  List<String> build() {
    _load();
    return [];
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getStringList(_kHistoryKey) ?? [];
  }

  Future<void> add(String query) async {
    final q = query.trim();
    if (q.length < 2) return;
    final updated =
        [q, ...state.where((e) => e != q)].take(_kMaxHistory).toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kHistoryKey, updated);
  }

  Future<void> remove(String query) async {
    final updated = state.where((e) => e != query).toList();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_kHistoryKey, updated);
  }

  Future<void> clearAll() async {
    state = [];
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kHistoryKey);
  }
}
