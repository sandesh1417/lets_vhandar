import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/auth/domain/repositories/auth_repository.dart';
import 'package:lets_vhandar/features/auth/login/domain/login_state.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

final passwordVisibilityProvider = StateProvider<bool>((ref) => true);

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(locator<AuthRepository>());
});

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepository _authRepository;

  LoginNotifier(this._authRepository) : super(const LoginState());

  Future<void> login(
      BuildContext context, String phoneNumber, String password) async {
    state = state.copyWithChange(isLoading: true, clearError: true);

    final result = await _authRepository.login(phoneNumber, password);

    switch (result) {
      case Success(value: final data):
        state = state.copyWith(isLoading: false, isLoggedIn: true);
        CustomSnackbar.success(context,
            message: data.message ?? "Login Successful");
        // Navigate using GoRouter
        // context.go(LVRoute.dashboardScreen.route);
        // For now just showing success, navigation should be handled in UI listener or here if context available
        break;
      case Error(failure: final failure):
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        CustomSnackbar.error(context, message: failure.message);
        break;
    }
  }
}
