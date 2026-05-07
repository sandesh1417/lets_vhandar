import 'package:lets_vhandar/features/address/domain/models/address_model.dart';

class AddressPagination {
  final int? total;
  final int? page;
  final int? limit;
  final bool? firstPage;
  final bool? isLastPage;

  AddressPagination({
    this.total,
    this.page,
    this.limit,
    this.firstPage,
    this.isLastPage,
  });

  factory AddressPagination.fromMap(Map<String, dynamic> json) =>
      AddressPagination(
        total: json['total'] as int?,
        page: json['page'] as int?,
        limit: json['limit'] as int?,
        firstPage: json['firstPage'] as bool?,
        isLastPage: json['isLastPage'] as bool?,
      );
}

class AddressResponse {
  final String? status;
  final List<AddressModel> addresses;
  final AddressPagination? pagination;

  AddressResponse({
    this.status,
    required this.addresses,
    this.pagination,
  });

  factory AddressResponse.fromMap(Map<String, dynamic> json) {
    final dynamic rawData = json['data'];
    List<dynamic> dataList = [];
    Map<String, dynamic>? paginationMap;

    if (rawData is List) {
      dataList = rawData;
    } else if (rawData is Map<String, dynamic>) {
      dataList = rawData['data'] as List? ?? [];
      paginationMap = rawData['pagination'] as Map<String, dynamic>?;
    }

    return AddressResponse(
      status: json['status'] as String?,
      addresses: dataList
          .map((e) => AddressModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      pagination: paginationMap != null
          ? AddressPagination.fromMap(paginationMap)
          : null,
    );
  }
}
