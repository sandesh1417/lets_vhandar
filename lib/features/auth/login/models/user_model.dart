bool? _parseBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  if (v is int) return v != 0;
  if (v is String) return v.toLowerCase() == 'true';
  return null;
}

class UserModel {
  final String? id;
  final String? name;
  final String? phoneNumber;
  final String? phoneCode;
  final String? email;
  final String? role;
  final String? status;
  final String? photoURL;
  final String? gender;
  final String? birthDate;
  final String? referalCode;
  final int? age;
  final int? vandarPoints;
  final double? totalMoneySave;
  final bool? isCreatedByAdmin;
  final bool? isBusiness;
  final bool? deleteRequest;
  final Map<String, dynamic>? businessDetail;
  final List<dynamic>? familyRequests;
  final List<dynamic>? addresses;
  final String? createdAt;
  final String? updatedAt;

  UserModel({
    this.id,
    this.name,
    this.phoneNumber,
    this.phoneCode,
    this.email,
    this.role,
    this.status,
    this.photoURL,
    this.gender,
    this.birthDate,
    this.referalCode,
    this.age,
    this.vandarPoints,
    this.totalMoneySave,
    this.isCreatedByAdmin,
    this.isBusiness,
    this.deleteRequest,
    this.businessDetail,
    this.familyRequests,
    this.addresses,
    this.createdAt,
    this.updatedAt,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? phoneCode,
    String? email,
    String? role,
    String? status,
    String? photoURL,
    String? gender,
    String? birthDate,
    String? referalCode,
    int? age,
    int? vandarPoints,
    double? totalMoneySave,
    bool? isCreatedByAdmin,
    bool? isBusiness,
    bool? deleteRequest,
    Map<String, dynamic>? businessDetail,
    List<dynamic>? familyRequests,
    List<dynamic>? addresses,
    String? createdAt,
    String? updatedAt,
  }) =>
      UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        phoneNumber: phoneNumber ?? this.phoneNumber,
        phoneCode: phoneCode ?? this.phoneCode,
        email: email ?? this.email,
        role: role ?? this.role,
        status: status ?? this.status,
        photoURL: photoURL ?? this.photoURL,
        gender: gender ?? this.gender,
        birthDate: birthDate ?? this.birthDate,
        referalCode: referalCode ?? this.referalCode,
        age: age ?? this.age,
        vandarPoints: vandarPoints ?? this.vandarPoints,
        totalMoneySave: totalMoneySave ?? this.totalMoneySave,
        isCreatedByAdmin: isCreatedByAdmin ?? this.isCreatedByAdmin,
        isBusiness: isBusiness ?? this.isBusiness,
        deleteRequest: deleteRequest ?? this.deleteRequest,
        businessDetail: businessDetail ?? this.businessDetail,
        familyRequests: familyRequests ?? this.familyRequests,
        addresses: addresses ?? this.addresses,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );

  factory UserModel.fromMap(Map<String, dynamic> json) => UserModel(
        id: json['_id'] as String?,
        name: json['name'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        phoneCode: json['phoneCode'] as String?,
        email: json['email'] as String?,
        role: json['role'] as String?,
        status: json['status'] as String?,
        photoURL: json['photoURL'] as String?,
        gender: json['gender'] as String?,
        birthDate: json['birthDate'] as String?,
        referalCode: json['referalCode'] as String?,
        age: json['age'] as int?,
        vandarPoints: json['vandarPoints'] as int?,
        totalMoneySave: (json['totalMoneySave'] as num?)?.toDouble(),
        isCreatedByAdmin: json['isCreatedByAdmin'] as bool?,
        isBusiness: _parseBool(json['isBusiness']),
        deleteRequest: json['deleteRequest'] as bool?,
        businessDetail: json['businessDetail'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['businessDetail'])
            : null,
        familyRequests: json['familyRequests'] is List
            ? List<dynamic>.from(json['familyRequests'])
            : null,
        addresses: json['addresses'] is List
            ? List<dynamic>.from(json['addresses'])
            : null,
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String?,
      );

  Map<String, dynamic> toMap() => {
        '_id': id,
        'name': name,
        'phoneNumber': phoneNumber,
        'phoneCode': phoneCode,
        'email': email,
        'role': role,
        'status': status,
        'photoURL': photoURL,
        'gender': gender,
        'birthDate': birthDate,
        'referalCode': referalCode,
        'age': age,
        'vandarPoints': vandarPoints,
        'totalMoneySave': totalMoneySave,
        'isCreatedByAdmin': isCreatedByAdmin,
        'isBusiness': isBusiness,
        'deleteRequest': deleteRequest,
        'businessDetail': businessDetail,
        'familyRequests': familyRequests,
        'addresses': addresses,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
