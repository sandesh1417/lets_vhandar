import 'dart:developer';

import 'package:lets_vhandar/core/api/api_client.dart';
import 'package:lets_vhandar/core/config/api_endpoints.dart';
import 'package:lets_vhandar/core/error/failure.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/features/my_list/domain/models/saved_list_model.dart';

class MyListRepository {
  final ApiClient _apiClient;

  MyListRepository(this._apiClient);

  Future<Result<List<SavedList>, Failure>> fetchLists() async {
    try {
      final result = await _apiClient.get(ApiUrl.shoppingLists);
      switch (result) {
        case Success(value: final data):
          final raw = data['data'];
          final List<dynamic> items;
          if (raw is List) {
            items = raw;
          } else if (raw is Map && raw['data'] is List) {
            items = raw['data'] as List<dynamic>;
          } else {
            log('[MyListRepo] unexpected fetchLists shape: $raw');
            items = [];
          }
          return Success(
            items
                .map((e) => SavedList.fromApi(Map<String, dynamic>.from(e)))
                .toList(),
          );
        case Error(failure: final f):
          throw f;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<SavedList, Failure>> createList(String name) async {
    try {
      final result = await _apiClient.post(
        ApiUrl.shoppingLists,
        data: {'name': name, 'description': '', 'productIds': []},
      );
      switch (result) {
        case Success(value: final data):
          final raw = data['data'];
          if (raw == null) {
            return const Error(ServerFailure('Failed to create list: empty response'));
          }
          return Success(SavedList.fromApi(Map<String, dynamic>.from(raw)));
        case Error(failure: final f):
          throw f;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<bool, Failure>> deleteList(String listId) async {
    try {
      final result = await _apiClient.delete(ApiUrl.shoppingListById(listId));
      switch (result) {
        case Success():
          return const Success(true);
        case Error(failure: final f):
          throw f;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  // Always send full body — backend replaces the whole document.
  Future<Result<bool, Failure>> renameList(
    String listId,
    String name, {
    String? description,
    required List<String> productIds,
  }) async {
    try {
      final result = await _apiClient.patch(
        ApiUrl.shoppingListById(listId),
        data: {
          'name': name,
          'description': description ?? '',
          'productIds': productIds,
        },
      );
      switch (result) {
        case Success():
          return const Success(true);
        case Error(failure: final f):
          throw f;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  // Append newProductId to existingProductIds and PATCH the full list.
  Future<Result<bool, Failure>> addProduct(
    String listId,
    String listName,
    String? description,
    List<String> existingProductIds,
    String newProductId,
  ) async {
    try {
      final newIds = [...existingProductIds, newProductId];
      final result = await _apiClient.patch(
        ApiUrl.shoppingListById(listId),
        data: {
          'name': listName,
          'description': description ?? '',
          'productIds': newIds,
        },
      );
      switch (result) {
        case Success():
          return const Success(true);
        case Error(failure: final f):
          throw f;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }

  Future<Result<bool, Failure>> removeProduct(
      String listId, String productId) async {
    try {
      final result = await _apiClient.patch(
        ApiUrl.shoppingListRemoveProduct(listId, productId),
      );
      switch (result) {
        case Success():
          return const Success(true);
        case Error(failure: final f):
          throw f;
      }
    } on Failure catch (e) {
      return Error(e);
    } catch (e) {
      return Error(ServerFailure(e.toString()));
    }
  }
}
