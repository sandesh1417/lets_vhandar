import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lets_vhandar/features/my_list/domain/models/saved_list_model.dart';

const _kStorageKey = 'vhandar_saved_lists';

class MyListState {
  final List<SavedList> lists;
  final bool isLoading;

  const MyListState({this.lists = const [], this.isLoading = false});

  MyListState copyWith({List<SavedList>? lists, bool? isLoading}) =>
      MyListState(
        lists: lists ?? this.lists,
        isLoading: isLoading ?? this.isLoading,
      );
}

class MyListNotifier extends StateNotifier<MyListState> {
  MyListNotifier() : super(const MyListState()) {
    _load();
  }

  Future<void> _load() async {
    state = state.copyWith(isLoading: true);
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_kStorageKey);
    if (raw != null) {
      final decoded = jsonDecode(raw) as List<dynamic>;
      state = MyListState(
        lists: decoded
            .map((e) => SavedList.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
      );
    } else {
      state = const MyListState();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _kStorageKey,
      jsonEncode(state.lists.map((l) => l.toMap()).toList()),
    );
  }

  Future<SavedList> createList(String name) async {
    final list = SavedList(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      createdAt: DateTime.now(),
    );
    state = state.copyWith(lists: [...state.lists, list]);
    await _persist();
    return list;
  }

  Future<void> deleteList(String listId) async {
    state = state.copyWith(
      lists: state.lists.where((l) => l.id != listId).toList(),
    );
    await _persist();
  }

  Future<void> renameList(String listId, String name) async {
    state = state.copyWith(
      lists: state.lists
          .map((l) => l.id == listId ? l.copyWith(name: name) : l)
          .toList(),
    );
    await _persist();
  }

  Future<void> addProduct(String listId, SavedProduct product) async {
    state = state.copyWith(
      lists: state.lists.map((l) {
        if (l.id != listId) return l;
        final already = l.products.any((p) => p.id == product.id);
        if (already) return l;
        return l.copyWith(products: [...l.products, product]);
      }).toList(),
    );
    await _persist();
  }

  Future<void> removeProduct(String listId, String productId) async {
    state = state.copyWith(
      lists: state.lists.map((l) {
        if (l.id != listId) return l;
        return l.copyWith(
          products: l.products.where((p) => p.id != productId).toList(),
        );
      }).toList(),
    );
    await _persist();
  }

  SavedList? getList(String listId) {
    try {
      return state.lists.firstWhere((l) => l.id == listId);
    } catch (_) {
      return null;
    }
  }

  bool isProductInList(String listId, String productId) {
    final list = getList(listId);
    return list?.products.any((p) => p.id == productId) ?? false;
  }
}

final myListProvider =
    StateNotifierProvider<MyListNotifier, MyListState>((ref) {
  return MyListNotifier();
});
