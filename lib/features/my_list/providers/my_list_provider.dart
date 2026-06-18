import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/constants/r_session.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/my_list/data/my_list_repository.dart';
import 'package:lets_vhandar/features/my_list/domain/models/saved_list_model.dart';

class MyListState {
  final List<SavedList> lists;
  final bool isLoading;
  final String? error;

  const MyListState({
    this.lists = const [],
    this.isLoading = false,
    this.error,
  });

  MyListState copyWith({
    List<SavedList>? lists,
    bool? isLoading,
    String? error,
  }) =>
      MyListState(
        lists: lists ?? this.lists,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class MyListNotifier extends StateNotifier<MyListState> {
  final MyListRepository _repo;

  MyListNotifier(this._repo) : super(const MyListState()) {
    load();
  }

  Future<void> load() async {
    if (Rsession.isGuest || Rsession.token == null) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await _repo.fetchLists();
    result.when(
      success: (lists) => state = MyListState(lists: lists),
      failure: (f) =>
          state = state.copyWith(isLoading: false, error: f.message),
    );
  }

  Future<SavedList?> createList(String name) async {
    final result = await _repo.createList(name);
    switch (result) {
      case Success(value: final created):
        state = state.copyWith(lists: [...state.lists, created]);
        return created;
      case Error(failure: final f):
        state = state.copyWith(error: f.message);
        return null;
    }
  }

  Future<void> deleteList(String listId) async {
    final result = await _repo.deleteList(listId);
    switch (result) {
      case Success():
        state = state.copyWith(
          lists: state.lists.where((l) => l.id != listId).toList(),
        );
      case Error(failure: final f):
        state = state.copyWith(error: f.message);
    }
  }

  Future<void> renameList(String listId, String name) async {
    final result = await _repo.renameList(listId, name);
    switch (result) {
      case Success():
        state = state.copyWith(
          lists: state.lists
              .map((l) => l.id == listId ? l.copyWith(name: name) : l)
              .toList(),
        );
      case Error(failure: final f):
        state = state.copyWith(error: f.message);
    }
  }

  /// Returns `true` if added, `false` if already present.
  Future<bool> addProduct(String listId, SavedProduct product) async {
    final list = state.lists.firstWhere(
      (l) => l.id == listId,
      orElse: () => SavedList(id: listId, name: '', createdAt: DateTime.now()),
    );
    if (list.products.any((p) => p.id == product.id)) return false;

    final result = await _repo.addProduct(listId, product.id);
    switch (result) {
      case Success():
        state = state.copyWith(
          lists: state.lists.map((l) {
            if (l.id != listId) return l;
            return l.copyWith(products: [...l.products, product]);
          }).toList(),
        );
        return true;
      case Error(failure: final f):
        state = state.copyWith(error: f.message);
        return false;
    }
  }

  Future<void> removeProduct(String listId, String productId) async {
    final result = await _repo.removeProduct(listId, productId);
    switch (result) {
      case Success():
        state = state.copyWith(
          lists: state.lists.map((l) {
            if (l.id != listId) return l;
            return l.copyWith(
              products: l.products.where((p) => p.id != productId).toList(),
            );
          }).toList(),
        );
      case Error(failure: final f):
        state = state.copyWith(error: f.message);
    }
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
  return MyListNotifier(locator<MyListRepository>());
});
