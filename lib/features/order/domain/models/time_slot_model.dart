// ─── Time Slot Model ──────────────────────────────────────────────────────────

class TimeSlotResponse {
  final TimeSlotData? data;
  final String? status;

  TimeSlotResponse({this.data, this.status});

  factory TimeSlotResponse.fromMap(Map<String, dynamic> json) =>
      TimeSlotResponse(
        data: json["data"] == null ? null : TimeSlotData.fromMap(json["data"]),
        status: json["status"],
      );
}

class TimeSlotData {
  final List<TimeSlot>? data;

  TimeSlotData({this.data});

  factory TimeSlotData.fromMap(Map<String, dynamic> json) => TimeSlotData(
        data: json["data"] == null
            ? []
            : List<TimeSlot>.from(
                json["data"]!.map((x) => TimeSlot.fromMap(x))),
      );
}

class TimeSlot {
  final String? id;
  final String? slotName;
  final String? startTime;
  final String? endTime;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TimeSlot({
    this.id,
    this.slotName,
    this.startTime,
    this.endTime,
    this.createdAt,
    this.updatedAt,
  });

  factory TimeSlot.fromMap(Map<String, dynamic> json) => TimeSlot(
        id: json["_id"],
        slotName: json["slotName"],
        startTime: json["startTime"],
        endTime: json["endTime"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );

  @override
  String toString() => '$slotName ($startTime - $endTime)';
}
