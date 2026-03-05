import 'dart:convert';

class BannerModal {
  final List<BannerData>? data;
  final String? status;

  BannerModal({
    this.data,
    this.status,
  });

  factory BannerModal.fromJson(String str) =>
      BannerModal.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BannerModal.fromMap(Map<String, dynamic> json) => BannerModal(
        data: json["data"] == null
            ? []
            : List<BannerData>.from(
                json["data"]!.map((x) => BannerData.fromMap(x))),
        status: json["status"],
      );

  Map<String, dynamic> toMap() => {
        "data":
            data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
        "status": status,
      };
}

class BannerData {
  final String? id;
  final String? name;
  final String? link;
  final List<BannerImage>? images;
  final bool? isCustomer;
  final bool? isBusiness;
  final dynamic sortOrder;
  final String? status;
  final String? type;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BannerData({
    this.id,
    this.name,
    this.link,
    this.images,
    this.isCustomer,
    this.isBusiness,
    this.sortOrder,
    this.status,
    this.type,
    this.createdAt,
    this.updatedAt,
  });

  factory BannerData.fromMap(Map<String, dynamic> json) => BannerData(
        id: json["_id"],
        name: json["name"],
        link: json["link"],
        images: json["images"] == null
            ? []
            : List<BannerImage>.from(
                json["images"]!.map((x) => BannerImage.fromMap(x))),
        isCustomer: json["isCustomer"],
        isBusiness: json["isBusiness"],
        sortOrder: json["sortOrder"],
        status: json["status"],
        type: json["type"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  Map<String, dynamic> toMap() => {
        "_id": id,
        "name": name,
        "link": link,
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toMap())),
        "isCustomer": isCustomer,
        "isBusiness": isBusiness,
        "sortOrder": sortOrder,
        "status": status,
        "type": type,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
      };
}

class BannerImage {
  final String? url;
  final String? path;

  BannerImage({
    this.url,
    this.path,
  });

  factory BannerImage.fromMap(Map<String, dynamic> json) => BannerImage(
        url: json["url"],
        path: json["path"],
      );

  Map<String, dynamic> toMap() => {
        "url": url,
        "path": path,
      };
}
