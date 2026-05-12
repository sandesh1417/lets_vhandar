import 'package:vhandar/features/auth/login/models/user_model.dart';

class UserProfileResponse {
  final String? status;
  final UserModel? user;

  UserProfileResponse({
    this.status,
    this.user,
  });

  factory UserProfileResponse.fromMap(Map<String, dynamic> json) {
    return UserProfileResponse(
      status: json['status'] as String?,
      user: json['data'] != null
          ? UserModel.fromMap(json['data'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'status': status,
        'data': user?.toMap(),
      };
}
