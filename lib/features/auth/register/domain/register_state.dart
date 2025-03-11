// lib/core/features/auth/state/registration_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_state.freezed.dart';

@freezed
class RegistrationState with _$RegistrationState {
  const factory RegistrationState({
    @Default(false) bool isLoading,
    @Default(false) bool isOtpSent,
    @Default(false) bool isVerified,
    String? errorMessage,
    String? phoneNumber,
    String? phoneCode,
    // OtpData? otpData,
    // UserData? userData,
    String? authToken,
  }) = _RegistrationState;
}
