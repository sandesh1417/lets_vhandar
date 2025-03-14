import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/api/api_services.dart';
import 'package:lets_vhandar/features/auth/register/domain/register_state.dart';
import 'package:lets_vhandar/features/auth/register/modals/register_modal.dart';
import 'package:lets_vhandar/features/auth/register/services/register_service.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

// Provider for the API service
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider for the registration service
final registerServiceProvider = Provider<RegisterServices>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return RegisterServices(apiService);
});

// Provider for the registration state
final registrationProvider = StateNotifierProvider<RegistrationNotifier, RegistrationState>((ref) {
  final registerService = ref.watch(registerServiceProvider);
  return RegistrationNotifier(registerService);
});

final newUserInfoProvider = StateProvider<RegisterModal?>((ref) => null);

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final RegisterServices _registerService;

  RegistrationNotifier(this._registerService) : super(const RegistrationState());

  // Step 1: Send OTP
  Future<void> sendOtp(String phoneNumber, String phoneCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _registerService.sendOtp(phoneNumber, phoneCode);

    if (response.status == "SUCCESS" || response.success == "true") {
      state = state.copyWith(
        isLoading: false,
        isOtpSent: true,
        phoneNumber: phoneNumber,
        phoneCode: phoneCode,
        // otpData: response.data,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Failed to send OTP',
      );
    }
  }

  // Step 2: Register with OTP
  Future<void> registerWithOtp(
    BuildContext context, {
    required String otp,
    required String password,
    required String confirmPassword,
    required String name,
    String? phoneCode,
    required String phoneNumber,
    String? referalCode,
  }) async {
    // if (state.phoneNumber == null || state.phoneCode == null) {
    //   state = state.copyWith(errorMessage: 'Phone details not available');
    //   return;
    // }

    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _registerService.register(
      phoneNumber: phoneNumber,
      phoneCode: phoneCode,
      otp: otp,
      password: password,
      confirmPassword: confirmPassword,
      name: name,
      referalCode: referalCode,
    );

    if (response.status == "SUCCESS" || response.success == "true") {
      state = state.copyWith(
        isLoading: false,
        isRegistered: true,
        message: response.message ?? 'Registration successful',
      );
    } else {
      final errorMessage = response.message ?? 'Registration failed';

      // Show the error message in a snackbar
      CustomSnackbar.error(context, message: errorMessage);

      state = state.copyWith(
        isLoading: false,
        errorMessage: errorMessage,
      );
    }
  }

  void reset() {
    state = const RegistrationState();
  }
}
