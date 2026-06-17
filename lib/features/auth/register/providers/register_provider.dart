// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lets_vhandar/features/auth/register/domain/register_state.dart';
import 'package:lets_vhandar/features/auth/register/modals/register_modal.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

// Registration Provider
final registrationProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  return RegistrationNotifier(locator<AuthRepositoryImpl>());
});
final newUserInfoProvider = StateProvider<RegisterModal?>((ref) => null);

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final AuthRepositoryImpl _authRepository;

  RegistrationNotifier(this._authRepository) : super(const RegistrationState());

  /// **Send OTP**
  Future<void> sendOtp(BuildContext context,
      {required String phoneNumber,
      required String phoneCode,
      VoidCallback? onSuccess}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.sendOtp(phoneNumber, phoneCode);

    switch (result) {
      case Success(value: final data):
        state = state.copyWith(
          isLoading: false,
          isOtpSent: true,
          phoneNumber: phoneNumber,
          phoneCode: phoneCode,
        );
        CustomSnackbar.success(context,
            message: data.message ?? 'OPT successfully send');
        onSuccess?.call();
        break;
      case Error(failure: final failure):
        CustomSnackbar.error(context,
            message: failure.message);
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        break;
    }
  }

  /// **Send OTP for business registration** — hits /send-otp/register?isBusiness=true
  Future<void> sendOtpForBusiness(BuildContext context,
      {required String phoneNumber,
      required String phoneCode,
      VoidCallback? onSuccess}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result =
        await _authRepository.sendOtpForBusiness(phoneNumber, phoneCode);

    switch (result) {
      case Success(value: final data):
        state = state.copyWith(
          isLoading: false,
          isOtpSent: true,
          phoneNumber: phoneNumber,
          phoneCode: phoneCode,
        );
        CustomSnackbar.success(context,
            message: data.message ?? 'OTP successfully sent');
        onSuccess?.call();
        break;
      case Error(failure: final failure):
        CustomSnackbar.error(context, message: failure.message);
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        break;
    }
  }

  /// **Register User**
  Future<void> registerWithOtp(
    BuildContext context, {
    required String otp,
    required String password,
    required String confirmPassword,
    required String name,
    required String phoneNumber,
    String? phoneCode,
    String? referalCode,
    VoidCallback? onSuccess,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.register(
      phoneNumber: phoneNumber,
      phoneCode: phoneCode,
      otp: otp,
      password: password,
      confirmPassword: confirmPassword,
      name: name,
      referalCode: referalCode,
    );

    switch (result) {
      case Success(value: final data):
        state = state.copyWith(
          isLoading: false,
          isRegistered: true,
        );
        CustomSnackbar.success(context,
            message: data.message ?? 'Registration successful');
        onSuccess?.call();
        break;
      case Error(failure: final failure):
        CustomSnackbar.error(context, message: failure.message);
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        break;
    }
  }

  Future<void> registerBusinessWithOtp(
    BuildContext context, {
    required String otp,
    required String phoneNumber,
    required String email,
    required String password,
    required String confirmPassword,
    required String businessName,
    required String businessCategory,
    required String panNumber,
    required String vatNumber,
    String? phoneCode,
    double? lat,
    double? long,
    String? address,
    VoidCallback? onSuccess,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.registerBusiness(
      phoneNumber: phoneNumber,
      phoneCode: phoneCode ?? '+977',
      otp: otp,
      email: email,
      password: password,
      confirmPassword: confirmPassword,
      businessName: businessName,
      businessCategory: businessCategory,
      name: businessName,
      panNumber: panNumber,
      vatNumber: vatNumber,
      lat: lat,
      long: long,
      address: address,
    );

    switch (result) {
      case Success(value: final data):
        state = state.copyWith(isLoading: false, isRegistered: true);
        CustomSnackbar.success(context,
            message: data.message ?? 'Business registered successfully');
        onSuccess?.call();
        break;
      case Error(failure: final failure):
        CustomSnackbar.error(context, message: failure.message);
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        break;
    }
  }

  void reset() {
    state = const RegistrationState();
  }
}
