// ─── Transaction Model ────────────────────────────────────────────────────────
// The API currently returns {"data":[],"status":"SUCCESS"} — modelled generically
// so it can be extended when the response shape is populated.

class TransactionResponse {
  final List<TransactionData> data;
  final String? status;

  TransactionResponse({this.data = const [], this.status});

  factory TransactionResponse.fromMap(Map<String, dynamic> json) {
    final rawData = json["data"];
    List<TransactionData> parsedData = [];

    if (rawData is List) {
      parsedData = rawData
          .whereType<Map<String, dynamic>>()
          .map((x) => TransactionData.fromMap(x))
          .toList();
    }

    return TransactionResponse(data: parsedData, status: json["status"]);
  }
}

class TransactionData {
  final String? id;
  final String? orderId;
  final String? status;
  final num? amount;
  final String? paymentMethod;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransactionData({
    this.id,
    this.orderId,
    this.status,
    this.amount,
    this.paymentMethod,
    this.createdAt,
    this.updatedAt,
  });

  factory TransactionData.fromMap(Map<String, dynamic> json) => TransactionData(
        id: json["_id"],
        orderId: json["orderId"],
        status: json["status"],
        amount: json["amount"],
        paymentMethod: json["paymentMethod"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );
}
