class RegisterModal {
  final String? password;
  final String? confirmPassword;
  final String? name;
  final String? referalCode;
  final String? phoneNumber;
  final String? phoneCode;
  final String? otp;

  RegisterModal({
    this.password,
    this.confirmPassword,
    this.name,
    this.referalCode,
    this.phoneNumber,
    this.phoneCode,
    this.otp,
  });

  RegisterModal copyWith({
    String? password,
    String? confirmPassword,
    String? name,
    String? referalCode,
    String? phoneNumber,
    String? phoneCode,
    String? otp,
  }) =>
      RegisterModal(
        password: password ?? this.password,
        confirmPassword: confirmPassword ?? this.confirmPassword,
        name: name ?? this.name,
        referalCode: referalCode ?? this.referalCode,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        phoneCode: phoneCode ?? this.phoneCode,
        otp: otp ?? this.otp,
      );
}
