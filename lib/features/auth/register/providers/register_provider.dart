// lib/core/features/auth/providers/registration_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/api/api_services.dart';
import 'package:lets_vhandar/features/auth/register/domain/register_state.dart';
import 'package:lets_vhandar/features/auth/register/services/register_service.dart';

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

class RegistrationNotifier extends StateNotifier<RegistrationState> {
  final RegisterServices _registerService;

  RegistrationNotifier(this._registerService) : super(const RegistrationState());

  Future<void> sendOtp(String phoneNumber, String phoneCode) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final response = await _registerService.sendOtp(phoneNumber, phoneCode);

    if (response.status == "200" || response.success == "true") {
      state = state.copyWith(
        isLoading: false,
        isOtpSent: true,
        phoneNumber: phoneNumber,
        phoneCode: phoneCode,
        // If you need to store OTP for testing/development
        // otpData: response.data
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: response.message ?? 'Failed to send OTP',
      );
    }
  }

  // Future<void> verifyOtp(String otp) async {
  //   if (state.phoneNumber == null || state.phoneCode == null) {
  //     state = state.copyWith(errorMessage: 'Phone details not available');
  //     return;
  //   }

  //   state = state.copyWith(isLoading: true, errorMessage: null);

  //   final response = await _registerService.verifyOtp(
  //     state.phoneNumber!,
  //     state.phoneCode!,
  //     otp,
  //   );

  //   if (response.status == "200" || response.success == "true") {
  //     state = state.copyWith(
  //       isLoading: false,
  //       isVerified: true,
  //       // userData: response.data?.user,
  //       // authToken: response.data?.token,
  //     );
  //   } else {
  //     state = state.copyWith(
  //       isLoading: false,
  //       errorMessage: response.message ?? 'Failed to verify OTP',
  //     );
  //   }
  // }

  void reset() {
    state = const RegistrationState();
  }
}
