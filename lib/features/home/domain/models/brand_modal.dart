import 'dart:convert';

class BrandModal {
  final List<BrandData>? data;
  final String? status;

  BrandModal({
    this.data,
    this.status,
  });

  factory BrandModal.fromJson(String str) =>
      BrandModal.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory BrandModal.fromMap(Map<String, dynamic> json) {
    final dataField = json["data"];
    List<dynamic> list = [];
    if (dataField is Map && dataField["data"] is List) {
      list = dataField["data"];
    } else if (dataField is List) {
      list = dataField;
    }

    return BrandModal(
      data: list.map((x) => BrandData.fromMap(x)).toList(),
      status: json["status"],
    );
  }

  Map<String, dynamic> toMap() => {
        "data":
            data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
        "status": status,
      };
}

class BrandData {
  final String? id;
  final String? name;
  final String? description;
  final List<BrandImage>? images;
  final int? sortOrder;
  final String? slug;

  BrandData({
    this.id,
    this.name,
    this.description,
    this.images,
    this.sortOrder,
    this.slug,
  });

  factory BrandData.fromMap(Map<String, dynamic> json) => BrandData(
        id: json["_id"],
        name: json["name"],
        description: json["description"],
        images: json["images"] == null
            ? []
            : List<BrandImage>.from(
                json["images"]!.map((x) => BrandImage.fromMap(x))),
        sortOrder: json["sortOrder"],
        slug: json["slug"],
      );

  Map<String, dynamic> toMap() => {
        "_id": id,
        "name": name,
        "description": description,
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toMap())),
        "sortOrder": sortOrder,
        "slug": slug,
      };
}

class BrandImage {
  final String? url;
  final String? path;

  BrandImage({
    this.url,
    this.path,
  });

  factory BrandImage.fromMap(Map<String, dynamic> json) => BrandImage(
        url: json["url"],
        path: json["path"],
      );

  Map<String, dynamic> toMap() => {
        "url": url,
        "path": path,
      };
}
