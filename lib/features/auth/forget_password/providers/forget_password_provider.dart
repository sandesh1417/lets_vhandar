import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lets_vhandar/features/auth/forget_password/domain/forget_password_state.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

final forgetPasswordProvider =
    StateNotifierProvider<ForgetPasswordNotifier, ForgetPasswordState>((ref) {
  return ForgetPasswordNotifier(locator<AuthRepositoryImpl>());
});

class ForgetPasswordNotifier extends StateNotifier<ForgetPasswordState> {
  final AuthRepositoryImpl _authRepository;

  ForgetPasswordNotifier(this._authRepository) : super(const ForgetPasswordState());

  Future<void> sendOtp(
    BuildContext context, {
    required String phoneNumber,
    required String phoneCode,
    VoidCallback? onSuccess,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.sendOtpForgetPassword(phoneNumber, phoneCode);

    result.when(
      success: (data) {
        state = state.copyWith(
          isLoading: false,
          isOtpSent: true,
          phoneNumber: phoneNumber,
          phoneCode: phoneCode,
        );
        CustomSnackbar.success(context, message: data.message ?? 'OTP successfully sent');
        onSuccess?.call();
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        CustomSnackbar.error(context, message: failure.message);
      },
    );
  }

  Future<void> verifyOtp(
    BuildContext context, {
    required String phoneNumber,
    required String otp,
    String? phoneCode,
    VoidCallback? onSuccess,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.verifyOtp(
      phoneNumber: phoneNumber,
      otp: otp,
      phoneCode: phoneCode,
    );

    result.when(
      success: (data) {
        state = state.copyWith(isLoading: false);
        CustomSnackbar.success(context, message: data.message ?? 'OTP Verified');
        onSuccess?.call();
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        CustomSnackbar.error(context, message: failure.message);
      },
    );
  }

  Future<void> resetPassword(
    BuildContext context, {
    required String otp,
    required String password,
    required String confirmPassword,
    required String phoneNumber,
    String? phoneCode,
    VoidCallback? onSuccess,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = await _authRepository.resetPassword(
      phoneNumber: phoneNumber,
      phoneCode: phoneCode,
      otp: otp,
      password: password,
      confirmPassword: confirmPassword,
    );

    result.when(
      success: (data) {
        state = state.copyWith(
          isLoading: false,
          isResetSuccessful: true,
        );
        CustomSnackbar.success(context, message: data.message ?? 'Password reset successfully');
        onSuccess?.call();
      },
      failure: (failure) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: failure.message,
        );
        CustomSnackbar.error(context, message: failure.message);
      },
    );
  }

  void reset() {
    state = const ForgetPasswordState();
  }
}
