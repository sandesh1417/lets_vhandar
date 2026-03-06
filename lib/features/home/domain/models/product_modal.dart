import 'dart:convert';

class ProductModal {
  final ProductContainer? data;
  final String? status;

  ProductModal({
    this.data,
    this.status,
  });

  factory ProductModal.fromJson(String str) =>
      ProductModal.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory ProductModal.fromMap(Map<String, dynamic> json) => ProductModal(
        data: json["data"] == null
            ? null
            : ProductContainer.fromMap(json["data"]),
        status: json["status"],
      );

  Map<String, dynamic> toMap() => {
        "data": data?.toMap(),
        "status": status,
      };
}

class ProductContainer {
  final List<ProductData>? data;
  final int? total;
  final int? page;
  final int? limit;

  ProductContainer({
    this.data,
    this.total,
    this.page,
    this.limit,
  });

  factory ProductContainer.fromMap(Map<String, dynamic> json) =>
      ProductContainer(
        data: json["data"] == null
            ? []
            : List<ProductData>.from(
                json["data"]!.map((x) => ProductData.fromMap(x))),
        total: json["total"],
        page: json["page"],
        limit: json["limit"],
      );

  Map<String, dynamic> toMap() => {
        "data":
            data == null ? [] : List<dynamic>.from(data!.map((x) => x.toMap())),
        "total": total,
        "page": page,
        "limit": limit,
      };
}

class ProductData {
  final String? id;
  final String? name;
  final String? unit;
  final double? unitValue;
  final String? description;
  final int? quantity;
  final List<String>? categoryIds;
  final double? pricePerUnit;
  final ProductDiscount? discount;
  final List<ProductImage>? images;
  final List<ProductImage>? featuredImages;
  final String? productCode;
  final String? status;
  final bool? isFeatured;
  final String? slug;
  final String? keyFeatures;
  final String? shelfLife;
  final String? returnPolicy;
  final String? disclaimer;
  final String? customerCareDetails;
  final bool? hasVariant;
  final String? parentId;

  ProductData({
    this.id,
    this.name,
    this.unit,
    this.unitValue,
    this.description,
    this.quantity,
    this.categoryIds,
    this.pricePerUnit,
    this.discount,
    this.images,
    this.featuredImages,
    this.productCode,
    this.status,
    this.isFeatured,
    this.slug,
    this.keyFeatures,
    this.shelfLife,
    this.returnPolicy,
    this.disclaimer,
    this.customerCareDetails,
    this.hasVariant,
    this.parentId,
  });

  factory ProductData.fromMap(Map<String, dynamic> json) => ProductData(
        id: json["_id"],
        name: json["name"],
        unit: json["unit"],
        unitValue: json["unitValue"]?.toDouble(),
        description: json["description"],
        quantity: json["quantity"],
        categoryIds: json["categoryIds"] == null
            ? []
            : List<String>.from(json["categoryIds"]!.map((x) => x)),
        pricePerUnit: json["pricePerUnit"]?.toDouble(),
        discount: json["discount"] == null
            ? null
            : ProductDiscount.fromMap(json["discount"]),
        images: json["images"] == null
            ? []
            : List<ProductImage>.from(
                json["images"]!.map((x) => ProductImage.fromMap(x))),
        featuredImages: json["featuredImages"] == null
            ? []
            : List<ProductImage>.from(
                json["featuredImages"]!.map((x) => ProductImage.fromMap(x))),
        productCode: json["productCode"],
        status: json["status"],
        isFeatured: json["isFeatured"],
        slug: json["slug"],
        keyFeatures: json["keyFeatures"],
        shelfLife: json["shelfLife"],
        returnPolicy: json["returnPolicy"],
        disclaimer: json["disclaimer"],
        customerCareDetails: json["customerCareDetails"],
        hasVariant: json["hasVariant"] ?? false,
        parentId: json["parentId"],
      );

  Map<String, dynamic> toMap() => {
        "_id": id,
        "name": name,
        "unit": unit,
        "unitValue": unitValue,
        "description": description,
        "quantity": quantity,
        "categoryIds": categoryIds == null
            ? []
            : List<dynamic>.from(categoryIds!.map((x) => x)),
        "pricePerUnit": pricePerUnit,
        "discount": discount?.toMap(),
        "images": images == null
            ? []
            : List<dynamic>.from(images!.map((x) => x.toMap())),
        "featuredImages": featuredImages == null
            ? []
            : List<dynamic>.from(featuredImages!.map((x) => x.toMap())),
        "productCode": productCode,
        "status": status,
        "isFeatured": isFeatured,
        "slug": slug,
        "keyFeatures": keyFeatures,
        "shelfLife": shelfLife,
        "returnPolicy": returnPolicy,
        "disclaimer": disclaimer,
        "customerCareDetails": customerCareDetails,
        "hasVariant": hasVariant,
        "parentId": parentId,
      };

  double get actualPrice {
    if (pricePerUnit == null) return 0;
    if (discount == null) return pricePerUnit!;
    if (discount!.type == "flat") {
      return pricePerUnit! - (discount!.value ?? 0);
    } else if (discount!.type == "percentage") {
      return pricePerUnit! * (1 - (discount!.value ?? 0) / 100);
    }
    return pricePerUnit!;
  }
}

class ProductDiscount {
  final String? type;
  final double? value;

  ProductDiscount({
    this.type,
    this.value,
  });

  factory ProductDiscount.fromMap(Map<String, dynamic> json) => ProductDiscount(
        type: json["type"],
        value: json["value"]?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        "type": type,
        "value": value,
      };
}

class ProductImage {
  final String? url;
  final String? path;

  ProductImage({
    this.url,
    this.path,
  });

  factory ProductImage.fromMap(Map<String, dynamic> json) => ProductImage(
        url: json["url"],
        path: json["path"],
      );

  Map<String, dynamic> toMap() => {
        "url": url,
        "path": path,
      };
}
