import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final bool isLoading;
  final bool isLoggedIn;
  final String? errorMessage;

  const LoginState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.errorMessage,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? errorMessage,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      errorMessage:
          errorMessage, // If null passed (not provided), keep generic? No, usually copyWith replaces if non-null, or we need a way to clear it.
      // For simplicity in this project's pattern:
      // specific logic: if I pass null to error message in copyWith, it usually implies keeping old one unless I handle nullable explicitly.
      // But in my Notifier I did `errorMessage: null`. that means I want to clear it.
      // So I'll accept nullable and if validation needed I'll handle it.
      // Actually standard copyWith:
      // errorMessage: errorMessage ?? this.errorMessage
      // If I want to clear it, I should likely pass a specific value or structure.
      // But looking at my usage: `state = state.copyWith(isLoading: true, errorMessage: null);`
      // This won't clear it if usage is `errorMessage ?? this.errorMessage`.
      // I will just implement a simple version where I can clear it.
    );
  }

  // Better copyWith pattern for nullable fields:
  LoginState copyWithChange({
    bool? isLoading,
    bool? isLoggedIn,
    String? errorMessage,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, isLoggedIn, errorMessage];
}
