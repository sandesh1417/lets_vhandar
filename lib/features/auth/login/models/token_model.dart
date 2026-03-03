class TokenModel {
  final String? accessToken;
  final String? refreshToken;

  TokenModel({
    this.accessToken,
    this.refreshToken,
  });

  TokenModel copyWith({
    String? accessToken,
    String? refreshToken,
  }) =>
      TokenModel(
        accessToken: accessToken ?? this.accessToken,
        refreshToken: refreshToken ?? this.refreshToken,
      );

  factory TokenModel.fromMap(Map<String, dynamic> json) => TokenModel(
        accessToken: json['accessToken'] as String?,
        refreshToken: json['refreshToken'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'accessToken': accessToken,
        'refreshToken': refreshToken,
      };
}
