import 'dart:convert';

class WarehouseResponse {
  final WarehouseData? data;
  final String? status;

  WarehouseResponse({this.data, this.status});

  factory WarehouseResponse.fromJson(String str) =>
      WarehouseResponse.fromMap(json.decode(str));

  factory WarehouseResponse.fromMap(Map<String, dynamic> json) =>
      WarehouseResponse(
        data: json["data"] == null ? null : WarehouseData.fromMap(json["data"]),
        status: json["status"],
      );
}

class WarehouseData {
  final List<Warehouse>? data;
  final Pagination? pagination;

  WarehouseData({this.data, this.pagination});

  factory WarehouseData.fromMap(Map<String, dynamic> json) => WarehouseData(
        data: json["data"] == null
            ? []
            : List<Warehouse>.from(
                json["data"]!.map((x) => Warehouse.fromMap(x))),
        pagination: json["pagination"] == null
            ? null
            : Pagination.fromMap(json["pagination"]),
      );
}

class Warehouse {
  final String? id;
  final String? name;
  final double? lat;
  final double? long;
  final String? description;
  final num? deliveryRadius;
  final String? startTime;
  final String? endTime;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Warehouse({
    this.id,
    this.name,
    this.lat,
    this.long,
    this.description,
    this.deliveryRadius,
    this.startTime,
    this.endTime,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Warehouse.fromMap(Map<String, dynamic> json) => Warehouse(
        id: json["_id"],
        name: json["name"],
        lat: json["lat"]?.toDouble(),
        long: json["long"]?.toDouble(),
        description: json["description"],
        deliveryRadius: json["deliveryRadius"],
        startTime: json["startTime"],
        endTime: json["endTime"],
        status: json["status"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );
}

class Pagination {
  final num? total;
  final String? page;
  final String? limit;
  final bool? firstPage;
  final bool? isLastPage;

  Pagination({
    this.total,
    this.page,
    this.limit,
    this.firstPage,
    this.isLastPage,
  });

  factory Pagination.fromMap(Map<String, dynamic> json) => Pagination(
        total: json["total"],
        page: json["page"],
        limit: json["limit"],
        firstPage: json["firstPage"],
        isLastPage: json["isLastPage"],
      );
}
