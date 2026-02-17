// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/auth/domain/repositories/auth_repository.dart';
import 'package:lets_vhandar/features/auth/register/domain/register_state.dart';
import 'package:lets_vhandar/features/auth/register/modals/register_modal.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

// Registration Provider
final registrationProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  return RegistrationNotifier(locator<AuthRepository>());
});
final newUserInfoProvider = StateProvider<RegisterModal?>((ref) => null);

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final AuthRepository _authRepository;

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
            message: failure.message ?? 'OPT sending failed');
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

  void reset() {
    state = const RegistrationState();
  }
}
