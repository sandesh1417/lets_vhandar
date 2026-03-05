import 'dart:convert';

class CategoryModal {
  final List<CategoryData>? data;
  final String? status;

  CategoryModal({
    this.data,
    this.status,
  });

  factory CategoryModal.fromJson(String str) =>
      CategoryModal.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory CategoryModal.fromMap(Map<String, dynamic> json) {
    // Handle the nested "data" structure in the response
    final dataField = json["data"];
    List<dynamic> list = [];
    if (dataField is Map && dataField["data"] is List) {
      list = dataField["data"];
    } else if (dataField is List) {
      list = dataField;
    }

    return CategoryModal(
      data: list.map((x) => CategoryData.fromMap(x)).toList(),
      status: json["status"],
    );
  }

  Map<String, dynamic> toMap() => {
        "data":
            data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
        "status": status,
      };
}

class CategoryData {
  final String? id;
  final String? name;
  final bool? showAtHomepage;
  final List<String>? subCategories;
  final List<CategoryImage>? images;
  final int? sortOrder;
  final String? status;
  final String? slug;
  final String? subCategorySlug;

  CategoryData({
    this.id,
    this.name,
    this.showAtHomepage,
    this.subCategories,
    this.images,
    this.sortOrder,
    this.status,
    this.slug,
    this.subCategorySlug,
  });

  factory CategoryData.fromMap(Map<String, dynamic> json) => CategoryData(
        id: json["_id"],
        name: json["name"],
        showAtHomepage: json["showAtHomepage"],
        subCategories: json["subCategories"] == null
            ? []
            : List<String>.from(json["subCategories"]!.map((x) => x)),
        images: json["images"] == null
            ? []
            : List<CategoryImage>.from(
                json["images"]!.map((x) => CategoryImage.fromMap(x))),
        sortOrder: json["sortOrder"],
        status: json["status"],
        slug: json["slug"],
        subCategorySlug: json["subCategorySlug"],
      );

  Map<String, dynamic> toMap() => {
        "_id": id,
        "name": name,
        "showAtHomepage": showAtHomepage,
        "subCategories": subCategories == null
            ? []
            : List<dynamic>.from(subCategories!.map((x) => x)),
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toMap())),
        "sortOrder": sortOrder,
        "status": status,
        "slug": slug,
        "subCategorySlug": subCategorySlug,
      };
}

class CategoryImage {
  final String? url;
  final String? path;

  CategoryImage({
    this.url,
    this.path,
  });

  factory CategoryImage.fromMap(Map<String, dynamic> json) => CategoryImage(
        url: json["url"],
        path: json["path"],
      );

  Map<String, dynamic> toMap() => {
        "url": url,
        "path": path,
      };
}
