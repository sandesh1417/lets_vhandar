import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lets_vhandar/features/auth/login/models/user_model.dart';

part 'login_state.freezed.dart';

@freezed
class LoginState with _$LoginState {
  const factory LoginState.initial() = _Initial;
  const factory LoginState.loading() = _Loading;
  const factory LoginState.authenticated(UserModel user) = _Loginenticated;
  const factory LoginState.error(String message) = _Error;
}
