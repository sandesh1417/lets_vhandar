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
  final String? brandId;
  final List<dynamic>? tags;
  final int? sortOrder;
  final String? description;
  final int? quantity;
  final List<String>? categoryIds;
  final List<String>? subCategoryIds;
  final bool? isVegeterian;
  final double? pricePerUnit;
  final double? businessPricePerUnit;
  final String? type;
  final String? flavor;
  final String? ingredients;
  final String? keyFeatures;
  final String? shelfLife;
  final String? manufacturerDetails;
  final String? countryOfOrigin;
  final String? fssaiLicense;
  final String? keyword;
  final String? customerCareDetails;
  final String? returnPolicy;
  final String? expiryDate;
  final String? seller;
  final String? sellerFssai;
  final String? disclaimer;
  final ProductDiscount? discount;
  final String? sku;
  final bool? productShownToNormalCustomer;
  final List<ProductImage>? images;
  final List<String>? warehouseIds;
  final dynamic packs;
  final bool? productShownToBusinessCustomer;
  final String? productCode;
  final String? permalink;
  final String? packagingtype;
  final String? storageTips;
  final String? nutrientValue;
  final String? storageTemperature;
  final String? marketedBy;
  final int? quantityAlert;
  final String? status;
  final dynamic businessDiscount;
  final dynamic maximumQuantityOrder;
  final dynamic minimumQuantityOrder;
  final dynamic businessMaximumQuantityOrder;
  final dynamic businessMinimumQuantityOrder;
  final bool? isVatAdded;
  final bool? isFeatured;
  final List<ProductImage>? featuredImages;
  final List<dynamic>? relatedProducts;
  final bool? hasVariant;
  final String? parentId;
  final String? slug;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ProductData({
    this.id,
    this.name,
    this.unit,
    this.unitValue,
    this.brandId,
    this.tags,
    this.sortOrder,
    this.description,
    this.quantity,
    this.categoryIds,
    this.subCategoryIds,
    this.isVegeterian,
    this.pricePerUnit,
    this.businessPricePerUnit,
    this.type,
    this.flavor,
    this.ingredients,
    this.keyFeatures,
    this.shelfLife,
    this.manufacturerDetails,
    this.countryOfOrigin,
    this.fssaiLicense,
    this.keyword,
    this.customerCareDetails,
    this.returnPolicy,
    this.expiryDate,
    this.seller,
    this.sellerFssai,
    this.disclaimer,
    this.discount,
    this.sku,
    this.productShownToNormalCustomer,
    this.images,
    this.warehouseIds,
    this.packs,
    this.productShownToBusinessCustomer,
    this.productCode,
    this.permalink,
    this.packagingtype,
    this.storageTips,
    this.nutrientValue,
    this.storageTemperature,
    this.marketedBy,
    this.quantityAlert,
    this.status,
    this.businessDiscount,
    this.maximumQuantityOrder,
    this.minimumQuantityOrder,
    this.businessMaximumQuantityOrder,
    this.businessMinimumQuantityOrder,
    this.isVatAdded,
    this.isFeatured,
    this.featuredImages,
    this.relatedProducts,
    this.hasVariant,
    this.parentId,
    this.slug,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductData.fromMap(Map<String, dynamic> json) => ProductData(
        id: json["_id"],
        name: json["name"],
        unit: json["unit"],
        unitValue: json["unitValue"]?.toDouble(),
        brandId: json["brandId"],
        tags: json["tags"],
        sortOrder: json["sortOrder"],
        description: json["description"],
        quantity: json["quantity"],
        categoryIds: json["categoryIds"] == null
            ? []
            : List<String>.from(json["categoryIds"]!.map((x) => x)),
        subCategoryIds: json["subCategoryIds"] == null
            ? []
            : List<String>.from(json["subCategoryIds"]!.map((x) => x)),
        isVegeterian: json["isVegeterian"],
        pricePerUnit: json["pricePerUnit"]?.toDouble(),
        businessPricePerUnit: json["businessPricePerUnit"]?.toDouble(),
        type: json["type"],
        flavor: json["flavor"],
        ingredients: json["ingredients"],
        keyFeatures: json["keyFeatures"],
        shelfLife: json["shelfLife"],
        manufacturerDetails: json["manufacturerDetails"],
        countryOfOrigin: json["countryOfOrigin"],
        fssaiLicense: json["fssaiLicense"],
        keyword: json["keyword"],
        customerCareDetails: json["customerCareDetails"],
        returnPolicy: json["returnPolicy"],
        expiryDate: json["expiryDate"],
        seller: json["seller"],
        sellerFssai: json["sellerFssai"],
        disclaimer: json["disclaimer"],
        discount: json["discount"] == null
            ? null
            : ProductDiscount.fromMap(json["discount"]),
        sku: json["sku"],
        productShownToNormalCustomer: json["productShownToNormalCustomer"],
        images: json["images"] == null
            ? []
            : List<ProductImage>.from(
                json["images"]!.map((x) => ProductImage.fromMap(x))),
        warehouseIds: json["warehouseIds"] == null
            ? []
            : List<String>.from(json["warehouseIds"]!.map((x) => x)),
        packs: json["packs"],
        productShownToBusinessCustomer: json["productShownToBusinessCustomer"],
        productCode: json["productCode"],
        permalink: json["permalink"],
        packagingtype: json["packagingtype"],
        storageTips: json["storageTips"],
        nutrientValue: json["nutrientValue"],
        storageTemperature: json["storageTemperature"],
        marketedBy: json["marketedBy"],
        quantityAlert: json["quantityAlert"],
        status: json["status"],
        businessDiscount: json["businessDiscount"],
        maximumQuantityOrder: json["maximumQuantityOrder"],
        minimumQuantityOrder: json["minimumQuantityOrder"],
        businessMaximumQuantityOrder: json["businessMaximumQuantityOrder"],
        businessMinimumQuantityOrder: json["businessMinimumQuantityOrder"],
        isVatAdded: json["isVatAdded"],
        isFeatured: json["isFeatured"],
        featuredImages: json["featuredImages"] == null
            ? []
            : List<ProductImage>.from(
                json["featuredImages"]!.map((x) => ProductImage.fromMap(x))),
        relatedProducts: json["relatedProducts"],
        hasVariant: json["hasVariant"] ?? false,
        parentId: json["parentId"],
        slug: json["slug"],
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
        "unit": unit,
        "unitValue": unitValue,
        "brandId": brandId,
        "tags": tags,
        "sortOrder": sortOrder,
        "description": description,
        "quantity": quantity,
        "categoryIds": categoryIds,
        "subCategoryIds": subCategoryIds,
        "isVegeterian": isVegeterian,
        "pricePerUnit": pricePerUnit,
        "businessPricePerUnit": businessPricePerUnit,
        "type": type,
        "flavor": flavor,
        "ingredients": ingredients,
        "keyFeatures": keyFeatures,
        "shelfLife": shelfLife,
        "manufacturerDetails": manufacturerDetails,
        "countryOfOrigin": countryOfOrigin,
        "fssaiLicense": fssaiLicense,
        "keyword": keyword,
        "customerCareDetails": customerCareDetails,
        "returnPolicy": returnPolicy,
        "expiryDate": expiryDate,
        "seller": seller,
        "sellerFssai": sellerFssai,
        "disclaimer": disclaimer,
        "discount": discount?.toMap(),
        "sku": sku,
        "productShownToNormalCustomer": productShownToNormalCustomer,
        "images": images?.map((x) => x.toMap()).toList(),
        "warehouseIds": warehouseIds,
        "packs": packs,
        "productShownToBusinessCustomer": productShownToBusinessCustomer,
        "productCode": productCode,
        "permalink": permalink,
        "packagingtype": packagingtype,
        "storageTips": storageTips,
        "nutrientValue": nutrientValue,
        "storageTemperature": storageTemperature,
        "marketedBy": marketedBy,
        "quantityAlert": quantityAlert,
        "status": status,
        "businessDiscount": businessDiscount,
        "maximumQuantityOrder": maximumQuantityOrder,
        "minimumQuantityOrder": minimumQuantityOrder,
        "businessMaximumQuantityOrder": businessMaximumQuantityOrder,
        "businessMinimumQuantityOrder": businessMinimumQuantityOrder,
        "isVatAdded": isVatAdded,
        "isFeatured": isFeatured,
        "featuredImages": featuredImages?.map((x) => x.toMap()).toList(),
        "relatedProducts": relatedProducts,
        "hasVariant": hasVariant,
        "parentId": parentId,
        "slug": slug,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
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
