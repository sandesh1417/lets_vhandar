class ForgetPasswordState {
  final bool isLoading;
  final bool isOtpSent;
  final bool isResetSuccessful;
  final String? errorMessage;
  final String? phoneNumber;
  final String? phoneCode;

  const ForgetPasswordState({
    this.isLoading = false,
    this.isOtpSent = false,
    this.isResetSuccessful = false,
    this.errorMessage,
    this.phoneNumber,
    this.phoneCode,
  });

  ForgetPasswordState copyWith({
    bool? isLoading,
    bool? isOtpSent,
    bool? isResetSuccessful,
    String? errorMessage,
    String? phoneNumber,
    String? phoneCode,
  }) {
    return ForgetPasswordState(
      isLoading: isLoading ?? this.isLoading,
      isOtpSent: isOtpSent ?? this.isOtpSent,
      isResetSuccessful: isResetSuccessful ?? this.isResetSuccessful,
      errorMessage: errorMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      phoneCode: phoneCode ?? this.phoneCode,
    );
  }
}
