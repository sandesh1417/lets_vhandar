import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lets_vhandar/core/constants/r_session.dart';
import 'package:lets_vhandar/core/local/shared_preferences_services.dart';
import 'package:lets_vhandar/core/router/app_router.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lets_vhandar/features/auth/login/domain/login_state.dart';
import 'package:lets_vhandar/features/auth/login/models/user_model.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

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
          await SessionPreferences().setToken(token: accessToken);
          final user = data.user;
          if (user != null) {
            await SessionPreferences().setUser(user: user);
          }
          Rsession.token = accessToken;
        }
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          isGuest: false,
          user: data.user,
        );
        if (!context.mounted) return;
        CustomSnackbar.success(context, message: "Login Successful");
        // Navigate using GoRouter
        context.go(LVRoute.dashboardScreen.route);
        break;
      case Error(failure: final failure):
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        if (context.mounted) {
          CustomSnackbar.error(context, message: failure.message);
        }
        break;
    }
  }

  Future<void> enterGuestMode(BuildContext context) async {
    await SessionPreferences().setGuestMode(isGuest: true);
    Rsession.isGuest = true;
    state = state.copyWith(isGuest: true, isLoggedIn: false);
    if (context.mounted) {
      context.go(LVRoute.dashboardScreen.route);
    }
  }

  Future<void> restoreSession() async {
    final token = await SessionPreferences().getToken();
    final user = await SessionPreferences().getUser();
    if (token != null && token.isNotEmpty) {
      Rsession.token = token;
      state = state.copyWith(isLoggedIn: true, isGuest: false, user: user);
    } else {
      final isGuest = await SessionPreferences().getGuestMode();
      if (isGuest) {
        Rsession.isGuest = true;
        state = state.copyWith(isGuest: true);
      }
    }
  }

  Future<void> refreshProfile() async {
    final id = state.user?.id;
    if (id == null || id.isEmpty) return;
    final result = await _authRepository.getUserProfile(id);
    switch (result) {
      case Success(value: final data):
        final fresh = data.user;
        if (fresh != null) {
          await SessionPreferences().setUser(user: fresh);
          state = state.copyWith(user: fresh);
        }
        break;
      case Error():
        // Keep existing cached user on failure
        break;
    }
  }

  Future<void> logout() async {
    await SessionPreferences().clearSession();
    Rsession.token = null;
    Rsession.isGuest = false;
    state = const LoginState();
  }

  Future<bool> updateProfile(
      BuildContext context, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true);
    final result = await _authRepository.updateProfile(data);
    switch (result) {
      case Success():
        final current = state.user;
        if (current != null) {
          // Use containsKey so explicit null clears the field locally
          final updatedMap = current.toMap()
            ..addAll({
              if (data.containsKey('name')) 'name': data['name'],
              if (data.containsKey('email')) 'email': data['email'],
              if (data.containsKey('gender')) 'gender': data['gender'],
              if (data.containsKey('birthDate')) 'birthDate': data['birthDate'],
              if (data.containsKey('businessDetail'))
                'businessDetail': data['businessDetail'],
            });
          final updated = UserModel.fromMap(updatedMap);
          await SessionPreferences().setUser(user: updated);
          state = state.copyWith(isLoading: false, user: updated);
        } else {
          state = state.copyWith(isLoading: false);
        }
        if (context.mounted) {
          CustomSnackbar.success(context,
              message: 'Profile updated successfully');
        }
        return true;
      case Error(failure: final failure):
        state = state.copyWith(isLoading: false, errorMessage: failure.message);
        if (context.mounted) {
          CustomSnackbar.error(context, message: failure.message);
        }
        return false;
    }
  }

  Future<void> deleteAccount(BuildContext context) async {
    state = state.copyWith(isLoading: true);
    final result = await _authRepository.deleteAccount();
    switch (result) {
      case Success(value: final data):
        await logout();
        if (!context.mounted) return;
        CustomSnackbar.success(context,
            message: data.message ?? "Account deleted successfully");
        context.go(LVRoute.loginScreen.route);
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
