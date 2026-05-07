import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lets_vhandar/core/utils/result.dart';
import 'package:lets_vhandar/di/service_locator.dart';
import 'package:lets_vhandar/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:lets_vhandar/widgets/custom_snackbar.dart';

final changePasswordProvider = StateNotifierProvider<ChangePasswordNotifier, AsyncValue<void>>((ref) {
  return ChangePasswordNotifier(locator<AuthRepositoryImpl>());
});

class ChangePasswordNotifier extends StateNotifier<AsyncValue<void>> {
  final AuthRepositoryImpl _authRepository;

  ChangePasswordNotifier(this._authRepository) : super(const AsyncValue.data(null));

  Future<void> changePassword(
    BuildContext context, {
    required String userId,
    required String oldPassword,
    required String password,
    required String confirmPassword,
    VoidCallback? onSuccess,
  }) async {
    state = const AsyncValue.loading();

    final result = await _authRepository.changePassword(
      userId: userId,
      oldPassword: oldPassword,
      password: password,
      confirmPassword: confirmPassword,
    );

    result.when(
      success: (data) {
        state = const AsyncValue.data(null);
        CustomSnackbar.success(context, message: data.message ?? 'Password changed successfully');
        onSuccess?.call();
      },
      failure: (failure) {
        state = AsyncValue.error(failure.message ?? 'Failed to change password', StackTrace.current);
        CustomSnackbar.error(context, message: failure.message ?? 'Failed to change password');
      },
    );
  }
}
