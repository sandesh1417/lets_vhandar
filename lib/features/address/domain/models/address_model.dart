class AddressModel {
  final String? id;
  final double? lat;
  final double? long;
  final String? userId;
  final String? name;
  final String? description;
  final String? addressType;
  final String? landMark;
  final String? locality;
  final String? phoneNumber;
  final String? houseNumber;
  final String? floor;
  final String? createdAt;
  final String? updatedAt;

  AddressModel({
    this.id,
    this.lat,
    this.long,
    this.userId,
    this.name,
    this.description,
    this.addressType,
    this.landMark,
    this.locality,
    this.phoneNumber,
    this.houseNumber,
    this.floor,
    this.createdAt,
    this.updatedAt,
  });

  factory AddressModel.fromMap(Map<String, dynamic> json) => AddressModel(
        id: json['_id'] as String?,
        lat: (json['lat'] as num?)?.toDouble(),
        long: (json['long'] as num?)?.toDouble(),
        userId: json['userId'] as String?,
        name: json['name'] as String?,
        description: json['description'] as String?,
        addressType: json['addressType'] as String?,
        landMark: json['landMark'] as String?,
        locality: json['locality'] as String?,
        phoneNumber: json['phoneNumber'] as String?,
        houseNumber: json['houseNumber'] as String?,
        floor: json['floor'] as String?,
        createdAt: json['createdAt'] as String?,
        updatedAt: json['updatedAt'] as String?,
      );

  Map<String, dynamic> toMap() => {
        '_id': id,
        'lat': lat,
        'long': long,
        'userId': userId,
        'name': name,
        'description': description,
        'addressType': addressType,
        'landMark': landMark,
        'locality': locality,
        'phoneNumber': phoneNumber,
        'houseNumber': houseNumber,
        'floor': floor,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  /// Icon for each address type
  String get displayName {
    if (name != null && name!.isNotEmpty) return name!;
    return addressType?.toUpperCase() ?? 'Address';
  }
}
