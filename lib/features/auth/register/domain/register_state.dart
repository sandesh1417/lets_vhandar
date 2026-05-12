// lib/core/features/auth/state/registration_state.dart

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:vhandar/features/auth/register/modals/register_modal.dart';

part 'register_state.freezed.dart';

@freezed
class RegistrationState with _$RegistrationState {
  const factory RegistrationState({
    @Default(false) bool isLoading,
    @Default(false) bool isOtpSent,
    @Default(false) bool isVerified,
    @Default(false) bool isRegistered,
    RegisterModal? newUserRegisterInfo,
    String? errorMessage,
    String? message,
    String? phoneNumber,
    String? phoneCode,
    // OtpData? otpData,
    // UserData? userData,
    String? authToken,
  }) = _RegistrationState;
}
