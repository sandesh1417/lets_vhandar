import 'package:equatable/equatable.dart';

import 'package:vhandar/features/auth/login/models/user_model.dart';

class LoginState extends Equatable {
  final bool isLoading;
  final bool isLoggedIn;
  final String? errorMessage;
  final UserModel? user;

  const LoginState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.errorMessage,
    this.user,
  });

  LoginState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    String? errorMessage,
    UserModel? user,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }

  LoginState copyWithChange({
    bool? isLoading,
    bool? isLoggedIn,
    String? errorMessage,
    UserModel? user,
    bool clearError = false,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [isLoading, isLoggedIn, errorMessage, user];
}
