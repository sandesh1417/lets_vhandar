import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vhandar/di/service_locator.dart';
import 'package:vhandar/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:vhandar/features/auth/login/models/user_model.dart';

final userProfileProvider =
    FutureProvider.family<UserModel, String>((ref, id) async {
  final authRepo = locator<AuthRepositoryImpl>();
  final result = await authRepo.getUserProfile(id);

  return result.when(
    success: (response) => response.user!,
    failure: (failure) => throw failure,
  );
});