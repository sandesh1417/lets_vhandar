// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/api/api_services.dart';
import 'package:lets_vhandar/features/auth/register/domain/register_state.dart';
import 'package:lets_vhandar/features/auth/register/modals/register_modal.dart';
import 'package:lets_vhandar/features/auth/register/services/register_service.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

// API Provider
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

// Register Service Provider
final registerServiceProvider = Provider<RegisterServices>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RegisterServices(apiService);
});

// Registration Provider
final registrationProvider = StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  final registerService = ref.watch(registerServiceProvider);
  return RegistrationNotifier(registerService);
});
final newUserInfoProvider = StateProvider<RegisterModal?>((ref) => null);

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final RegisterServices _registerService;

  RegistrationNotifier(this._registerService) : super(const RegistrationState());

  /// **Send OTP**
  Future<void> sendOtp(BuildContext context, {required String phoneNumber, required String phoneCode}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _registerService.sendOtp(phoneNumber, phoneCode);

    if (result.statusCode == 200) {
      state = state.copyWith(
        isLoading: false,
        isOtpSent: true,
        phoneNumber: phoneNumber,
        phoneCode: phoneCode,
      );
      CustomSnackbar.success(context, message: result.message ?? 'OPT successfully send');
    } else {
      CustomSnackbar.error(context, message: result.message ?? 'OPT sending failed');

      context.pop();
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Error (${result.statusCode}): ${result.message}",
      );
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

    final result = await _registerService.register(
      phoneNumber: phoneNumber,
      phoneCode: phoneCode,
      otp: otp,
      password: password,
      confirmPassword: confirmPassword,
      name: name,
      referalCode: referalCode,
    );

    if (result.statusCode == 200 || result.statusCode == 201) {
      state = state.copyWith(
        isLoading: false,
        isRegistered: true,
      );
      CustomSnackbar.success(context, message: result.message ?? 'Registration successful');
    } else {
      final errorMessage = result.message ?? 'Registration failed';
      CustomSnackbar.error(context, message: errorMessage);

      state = state.copyWith(
        isLoading: false,
        // errorMessage: "Error (${result.statusCode}): ${result.message}",
      );
    }
  }

  void reset() {
    state = const RegistrationState();
  }
}
