// ─── Place Order Response ─────────────────────────────────────────────────────

class PlaceOrderResponse {
  final OrderData? data;
  final String? status;

  PlaceOrderResponse({this.data, this.status});

  factory PlaceOrderResponse.fromMap(Map<String, dynamic> json) =>
      PlaceOrderResponse(
        data: json["data"] == null ? null : OrderData.fromMap(json["data"]),
        status: json["status"],
      );
}

// ─── Order List (search) Response ────────────────────────────────────────────

class OrderListResponse {
  final OrderListData? data;
  final String? status;

  OrderListResponse({this.data, this.status});

  factory OrderListResponse.fromMap(Map<String, dynamic> json) =>
      OrderListResponse(
        data: json["data"] == null ? null : OrderListData.fromMap(json["data"]),
        status: json["status"],
      );
}

class OrderListData {
  final List<OrderData>? data;
  final OrderPagination? pagination;

  OrderListData({this.data, this.pagination});

  factory OrderListData.fromMap(Map<String, dynamic> json) => OrderListData(
        data: json["data"] == null
            ? []
            : List<OrderData>.from(
                json["data"]!.map((x) => OrderData.fromMap(x))),
        pagination: json["pagination"] == null
            ? null
            : OrderPagination.fromMap(json["pagination"]),
      );
}

class OrderPagination {
  final num? total;
  final dynamic page;
  final dynamic limit;
  final bool? firstPage;
  final bool? isLastPage;

  OrderPagination(
      {this.total, this.page, this.limit, this.firstPage, this.isLastPage});

  factory OrderPagination.fromMap(Map<String, dynamic> json) => OrderPagination(
        total: json["total"],
        page: json["page"],
        limit: json["limit"],
        firstPage: json["firstPage"],
        isLastPage: json["isLastPage"],
      );
}

// ─── Order Data ───────────────────────────────────────────────────────────────

class OrderData {
  final String? id;
  final String? orderId;
  final num? totalAmount;
  final num? totalDiscount;
  final num? totalVatAmount;
  final num? totalPayableAmount;
  final num? deliveryCharge;
  final num? handlingCharge;
  final num? totalSavedAmount;
  final num? couponDiscount;
  final num? dueAmount;
  final String? userId;
  final String? cartId;
  final String? paymentStatus;
  final String? paymentMethod;
  final String? status;
  final String? deliveryTime;
  final String? appliedCouponCode;
  final dynamic deliveryTimeSlot;
  final OrderLocation? location;
  final List<OrderProduct>? products;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  OrderData({
    this.id,
    this.orderId,
    this.totalAmount,
    this.totalDiscount,
    this.totalVatAmount,
    this.totalPayableAmount,
    this.deliveryCharge,
    this.handlingCharge,
    this.totalSavedAmount,
    this.couponDiscount,
    this.dueAmount,
    this.userId,
    this.cartId,
    this.paymentStatus,
    this.paymentMethod,
    this.status,
    this.deliveryTime,
    this.appliedCouponCode,
    this.deliveryTimeSlot,
    this.location,
    this.products,
    this.createdAt,
    this.updatedAt,
  });

  factory OrderData.fromMap(Map<String, dynamic> json) => OrderData(
        id: json["_id"],
        orderId: json["orderId"],
        totalAmount: json["totalAmount"],
        totalDiscount: json["totalDiscount"],
        totalVatAmount: json["totalVatAmount"],
        totalPayableAmount: json["totalPayableAmount"],
        deliveryCharge: json["deliveryCharge"],
        handlingCharge: json["handlingCharge"],
        totalSavedAmount: json["totalSavedAmount"],
        couponDiscount: json["couponDiscount"],
        dueAmount: json["dueAmount"],
        userId: json["userId"],
        cartId: json["cartId"],
        paymentStatus: json["paymentStatus"],
        paymentMethod: json["paymentMethod"],
        status: json["status"],
        deliveryTime: json["deliveryTime"],
        appliedCouponCode: json["appliedCouponCode"],
        deliveryTimeSlot: json["deliveryTimeSlot"],
        location: json["location"] == null
            ? null
            : OrderLocation.fromMap(json["location"]),
        products: json["products"] == null
            ? []
            : List<OrderProduct>.from(
                json["products"]!.map((x) => OrderProduct.fromMap(x))),
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );
}

class OrderLocation {
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

  OrderLocation({
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
  });

  factory OrderLocation.fromMap(Map<String, dynamic> json) => OrderLocation(
        lat: json["lat"]?.toDouble(),
        long: json["long"]?.toDouble(),
        userId: json["userId"],
        name: json["name"],
        description: json["description"],
        addressType: json["addressType"],
        landMark: json["landMark"],
        locality: json["locality"],
        phoneNumber: json["phoneNumber"],
        houseNumber: json["houseNumber"],
        floor: json["floor"],
      );
}

class OrderProduct {
  final String? id;
  final String? name;
  final String? unit;
  final num? unitValue;
  final num? pricePerUnit;
  final num? totalPrice;
  final num? netPrice;
  final int? count;
  final dynamic discount;
  final bool? isVatAdded;
  final List<dynamic>? images;

  OrderProduct({
    this.id,
    this.name,
    this.unit,
    this.unitValue,
    this.pricePerUnit,
    this.totalPrice,
    this.netPrice,
    this.count,
    this.discount,
    this.isVatAdded,
    this.images,
  });

  factory OrderProduct.fromMap(Map<String, dynamic> json) => OrderProduct(
        id: json["_id"],
        name: json["name"],
        unit: json["unit"],
        unitValue: json["unitValue"],
        pricePerUnit: json["pricePerUnit"],
        totalPrice: json["totalPrice"],
        netPrice: json["netPrice"],
        count: json["count"],
        discount: json["discount"],
        isVatAdded: json["isVatAdded"],
        images: json["images"],
      );

  /// Returns the first image URL string (handles both String and Map formats)
  String? get firstImageUrl {
    if (images == null || images!.isEmpty) return null;
    final first = images!.first;
    if (first is String) {
      if (first.startsWith('http')) return first;
      if (first.startsWith('/')) {
        return 'https://vhandar.sgp1.digitaloceanspaces.com/$first';
      }
      return 'https://vhandar.sgp1.digitaloceanspaces.com//$first';
    }
    if (first is Map) {
      final url = first['url'];
      if (url is String) {
        if (url.startsWith('http')) return url;
        if (url.startsWith('/')) {
          return 'https://vhandar.sgp1.digitaloceanspaces.com/$url';
        }
        return 'https://vhandar.sgp1.digitaloceanspaces.com//$url';
      }
    }
    return null;
  }
}
