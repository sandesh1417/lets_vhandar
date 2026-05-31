import 'dart:convert';

class SubCategoryModal {
  final SubCategoryContainer? data;
  final String? status;

  SubCategoryModal({
    this.data,
    this.status,
  });

  factory SubCategoryModal.fromJson(String str) =>
      SubCategoryModal.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory SubCategoryModal.fromMap(Map<String, dynamic> json) =>
      SubCategoryModal(
        data: json["data"] == null
            ? null
            : SubCategoryContainer.fromMap(json["data"]),
        status: json["status"],
      );

  Map<String, dynamic> toMap() => {
        "data": data?.toMap(),
        "status": status,
      };
}

class SubCategoryContainer {
  final List<SubCategoryData>? data;
  final SubCategoryPagination? pagination;

  SubCategoryContainer({
    this.data,
    this.pagination,
  });

  factory SubCategoryContainer.fromMap(Map<String, dynamic> json) =>
      SubCategoryContainer(
        data: json["data"] == null
            ? []
            : List<SubCategoryData>.from(
                json["data"]!.map((x) => SubCategoryData.fromMap(x))),
        pagination: json["pagination"] == null
            ? null
            : SubCategoryPagination.fromMap(json["pagination"]),
      );

  Map<String, dynamic> toMap() => {
        "data":
            data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
        "pagination": pagination?.toMap(),
      };
}

class SubCategoryData {
  final String? id;
  final String? name;
  final String? description;
  final int? sortOrder;
  final List<SubCategoryImage>? images;
  final String? slug;

  SubCategoryData({
    this.id,
    this.name,
    this.description,
    this.sortOrder,
    this.images,
    this.slug,
  });

  factory SubCategoryData.fromMap(Map<String, dynamic> json) => SubCategoryData(
        id: json["_id"],
        name: json["name"],
        description: json["description"] ?? json["desc"] ?? json["details"],
        sortOrder: json["sortOrder"],
        images: json["images"] == null
            ? []
            : List<SubCategoryImage>.from(
                json["images"]!.map((x) => SubCategoryImage.fromMap(x))),
        slug: json["slug"],
      );

  Map<String, dynamic> toMap() => {
        "_id": id,
        "name": name,
        "description": description,
        "sortOrder": sortOrder,
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toMap())),
        "slug": slug,
      };
}

class SubCategoryImage {
  final String? url;
  final String? path;

  SubCategoryImage({
    this.url,
    this.path,
  });

  factory SubCategoryImage.fromMap(Map<String, dynamic> json) =>
      SubCategoryImage(
        url: json["url"],
        path: json["path"],
      );

  Map<String, dynamic> toMap() => {
        "url": url,
        "path": path,
      };
}

class SubCategoryPagination {
  final int? total;
  final int? page;
  final int? limit;
  final bool? firstPage;
  final bool? isLastPage;

  SubCategoryPagination({
    this.total,
    this.page,
    this.limit,
    this.firstPage,
    this.isLastPage,
  });

  factory SubCategoryPagination.fromMap(Map<String, dynamic> json) =>
      SubCategoryPagination(
        total: json["total"],
        page: json["page"],
        limit: json["limit"],
        firstPage: json["firstPage"],
        isLastPage: json["isLastPage"],
      );

  Map<String, dynamic> toMap() => {
        "total": total,
        "page": page,
        "limit": limit,
        "firstPage": firstPage,
        "isLastPage": isLastPage,
      };
}
