import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhandar/core/utils/result.dart';
import 'package:vhandar/di/service_locator.dart';
import 'package:vhandar/features/address/data/address_repository.dart';
import 'package:vhandar/features/address/domain/models/address_model.dart';

// --- State class ---
class AddressState {
  final List<AddressModel> addresses;
  final AddressModel? selected;
  final bool isLoading;
  final bool isFetched;
  final String? error;

  const AddressState({
    this.addresses = const [],
    this.selected,
    this.isLoading = false,
    this.isFetched = false,
    this.error,
  });

  AddressState copyWith({
    List<AddressModel>? addresses,
    AddressModel? selected,
    bool clearSelected = false,
    bool? isLoading,
    bool? isFetched,
    String? error,
  }) {
    return AddressState(
      addresses: addresses ?? this.addresses,
      selected: clearSelected ? null : (selected ?? this.selected),
      isLoading: isLoading ?? this.isLoading,
      isFetched: isFetched ?? this.isFetched,
      error: error,
    );
  }
}

// --- Notifier ---
class AddressNotifier extends StateNotifier<AddressState> {
  final AddressRepository _repo;

  AddressNotifier(this._repo) : super(const AddressState());

  Future<void> loadAddresses(String userId) async {
    state = state.copyWith(isLoading: true);
    final result = await _repo.getAddresses(userId);
    result.when(
      success: (response) {
        state = state.copyWith(
          isLoading: false,
          isFetched: true,
          addresses: response.addresses,
          // Auto-select first address if none selected
          selected: state.selected ??
              (response.addresses.isNotEmpty ? response.addresses.first : null),
        );
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          isFetched: true,
          error: failure.message,
        );
      },
    );
  }

  Future<bool> addAddress({
    required String userId,
    required double lat,
    required double long,
    required String description,
    required String addressType,
    String? name,
    String? landMark,
    String? locality,
    String? floor,
    String? phoneNumber,
    String? houseNumber,
  }) async {
    final result = await _repo.addAddress(
      userId: userId,
      lat: lat,
      long: long,
      description: description,
      addressType: addressType,
      name: name,
      landMark: landMark,
      locality: locality,
      floor: floor,
      phoneNumber: phoneNumber,
      houseNumber: houseNumber,
    );
    switch (result) {
      case Success():
        await loadAddresses(userId);
        return true;
      case Error(failure: final f):
        state = state.copyWith(error: f.message);
        return false;
    }
  }

  void selectAddress(AddressModel address) {
    state = state.copyWith(selected: address);
  }

  Future<bool> updateAddress({
    required String userId,
    required String addressId,
    required double lat,
    required double long,
    required String description,
    required String addressType,
    String? name,
    String? landMark,
    String? locality,
    String? floor,
    String? phoneNumber,
    String? houseNumber,
  }) async {
    final result = await _repo.updateAddress(
      addressId: addressId,
      lat: lat,
      long: long,
      description: description,
      addressType: addressType,
      name: name,
      landMark: landMark,
      locality: locality,
      floor: floor,
      phoneNumber: phoneNumber,
      houseNumber: houseNumber,
    );
    switch (result) {
      case Success():
        await loadAddresses(userId);
        return true;
      case Error(failure: final f):
        state = state.copyWith(error: f.message);
        return false;
    }
  }
  Future<bool> deleteAddress({
    required String userId,
    required String addressId,
  }) async {
    final result = await _repo.deleteAddress(addressId);
    switch (result) {
      case Success():
        await loadAddresses(userId);
        return true;
      case Error(failure: final f):
        state = state.copyWith(error: f.message);
        return false;
    }
  }
}

// --- Provider ---
final addressProvider =
    StateNotifierProvider<AddressNotifier, AddressState>((ref) {
  return AddressNotifier(locator<AddressRepository>());
});
