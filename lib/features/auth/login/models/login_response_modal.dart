import 'package:vhandar/features/auth/login/models/token_model.dart';
import 'package:vhandar/features/auth/login/models/user_model.dart';

class LoginResponseModal {
  final String? status;
  final TokenModel? token;
  final UserModel? user;

  LoginResponseModal({
    this.status,
    this.token,
    this.user,
  });

  LoginResponseModal copyWith({
    String? status,
    TokenModel? token,
    UserModel? user,
  }) =>
      LoginResponseModal(
        status: status ?? this.status,
        token: token ?? this.token,
        user: user ?? this.user,
      );

  factory LoginResponseModal.fromMap(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    return LoginResponseModal(
      status: json['status'] as String?,
      token: data?['token'] is Map<String, dynamic>
          ? TokenModel.fromMap(data!['token'] as Map<String, dynamic>)
          : null,
      user: data?['user'] is Map<String, dynamic>
          ? UserModel.fromMap(data!['user'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'status': status,
        'data': {
          'token': token?.toMap(),
          'user': user?.toMap(),
        },
      };
}
