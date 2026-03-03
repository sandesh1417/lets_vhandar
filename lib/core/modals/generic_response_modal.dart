import 'dart:convert';

class GenericResponseModal {
  final String? message;
  final String? status;
  final int? statusCode;
  final String? success;
  final Map<String, dynamic>? data;

  GenericResponseModal({
    this.message,
    this.status,
    this.statusCode,
    this.success,
    this.data,
  });

  GenericResponseModal copyWith({
    String? message,
    String? status,
    int? statusCode,
    String? success,
    Map<String, dynamic>? data,
  }) =>
      GenericResponseModal(
        message: message ?? this.message,
        status: status ?? this.status,
        statusCode: statusCode ?? this.statusCode,
        success: success ?? this.success,
        data: data ?? this.data,
      );

  factory GenericResponseModal.fromJson(String str) =>
      GenericResponseModal.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory GenericResponseModal.fromMap(Map<String, dynamic> json) =>
      GenericResponseModal(
        message: json["message"],
        status: json["status"],
        statusCode: json["statusCode"],
        success: json["success"],
        data: json["data"] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json["data"])
            : null,
      );

  Map<String, dynamic> toMap() => {
        "message": message,
        "status": status,
        "success": success,
        "statusCode": statusCode,
        "data": data,
      };
}
