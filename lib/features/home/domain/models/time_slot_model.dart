class TimeSlotResponse {
  final TimeSlotData? data;
  final String? status;

  TimeSlotResponse({this.data, this.status});

  factory TimeSlotResponse.fromMap(Map<String, dynamic> json) => TimeSlotResponse(
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
            : List<TimeSlot>.from(json["data"].map((x) => TimeSlot.fromMap(x))),
      );
}

class TimeSlot {
  final String? id;
  final String? slotName;
  final String? startTime;
  final String? endTime;

  TimeSlot({this.id, this.slotName, this.startTime, this.endTime});

  factory TimeSlot.fromMap(Map<String, dynamic> json) => TimeSlot(
        id: json["_id"],
        slotName: json["slotName"],
        startTime: json["startTime"],
        endTime: json["endTime"],
      );

  String get displayTime {
    final start = _fmt(startTime);
    final end = _fmt(endTime);
    if (start.isEmpty && end.isEmpty) return '';
    return '$start – $end';
  }

  static String _fmt(String? t) {
    if (t == null || t.isEmpty) return '';
    final parts = t.split(':');
    if (parts.length < 2) return t;
    int h = int.tryParse(parts[0]) ?? 0;
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    if (h > 12) h -= 12;
    if (h == 0) h = 12;
    return '$h:$m $period';
  }
}
