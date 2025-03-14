import 'dart:convert';

class GenericResponseModal {
  final String? message;
  final String? status;
  final int? statusCode;
  final String? success;

  GenericResponseModal({
    this.message,
    this.status,
    this.statusCode,
    this.success,
  });

  GenericResponseModal copyWith({
    String? message,
    String? status,
    int? statusCode,
    String? success,
  }) =>
      GenericResponseModal(
        message: message ?? this.message,
        status: status ?? this.status,
        statusCode: statusCode ?? this.statusCode,
        success: success ?? this.success,
      );

  factory GenericResponseModal.fromJson(String str) => GenericResponseModal.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GenericResponseModal.fromMap(Map<String, dynamic> json) => GenericResponseModal(
        message: json["message"],
        status: json["status"],
        statusCode: json["statusCode"],
        success: json["success"],
      );

  Map<String, dynamic> toMap() => {
        "message": message,
        "status": status,
        "success": success,
      };
}
