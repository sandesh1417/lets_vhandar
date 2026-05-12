import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:vhandar/core/constants/r_session.dart';
import 'package:vhandar/core/local/shared_preferences_services.dart';
import 'package:vhandar/core/router/app_router.dart';
import 'package:vhandar/core/utils/result.dart';
import 'package:vhandar/di/service_locator.dart';
import 'package:vhandar/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vhandar/features/auth/login/domain/login_state.dart';
import 'package:vhandar/widgets/custom_snackbar.dart';

final passwordVisibilityProvider = StateProvider<bool>((ref) => true);

final loginProvider = StateNotifierProvider<LoginNotifier, LoginState>((ref) {
  return LoginNotifier(locator<AuthRepositoryImpl>());
});

class LoginNotifier extends StateNotifier<LoginState> {
  final AuthRepositoryImpl _authRepository;

  LoginNotifier(this._authRepository) : super(const LoginState());

  Future<void> login(
      BuildContext context, String phoneNumber, String password) async {
    state = state.copyWithChange(isLoading: true, clearError: true);

    final result = await _authRepository.login(phoneNumber, password);

    switch (result) {
      case Success(value: final data):
        final accessToken = data.token?.accessToken;
        if (accessToken != null && accessToken.isNotEmpty) {
          await SessionPrefences().setToken(token: accessToken);
          if (data.user != null) {
            await SessionPrefences().setUser(user: data.user!);
          }
          Rsession.token = accessToken;
        }
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          user: data.user,
        );
        CustomSnackbar.success(context, message: "Login Successful");
        // Navigate using GoRouter
        if (context.mounted) {
          context.go(LVRoute.dashboardScreen.route);
        }
        break;
      case Error(failure: final failure):
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        if (context.mounted) {
          CustomSnackbar.error(context, message: failure.message);
        }
        break;
    }
  }

  Future<void> restoreSession() async {
    final token = await SessionPrefences().getToken();
    final user = await SessionPrefences().getUser();
    if (token != null && token.isNotEmpty) {
      Rsession.token = token;
      state = state.copyWith(isLoggedIn: true, user: user);
    }
  }

  Future<void> logout() async {
    await SessionPrefences().clearSession();
    Rsession.token = null;
    state = const LoginState();
  }

  Future<void> deleteAccount(BuildContext context) async {
    state = state.copyWith(isLoading: true);
    final result = await _authRepository.deleteAccount();
    switch (result) {
      case Success(value: final data):
        CustomSnackbar.success(context,
            message: data.message ?? "Account deleted successfully");
        await logout();
        if (context.mounted) {
          context.go(LVRoute.loginScreen.route);
        }
        break;
      case Error(failure: final failure):
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        if (context.mounted) {
          CustomSnackbar.error(context, message: failure.message);
        }
        break;
    }
  }
}
