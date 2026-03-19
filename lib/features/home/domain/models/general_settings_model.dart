import 'dart:convert';

class GeneralSettingsResponse {
  final List<GeneralSettings>? data;
  final String? status;

  GeneralSettingsResponse({this.data, this.status});

  factory GeneralSettingsResponse.fromJson(String str) =>
      GeneralSettingsResponse.fromMap(json.decode(str));

  factory GeneralSettingsResponse.fromMap(Map<String, dynamic> json) =>
      GeneralSettingsResponse(
        data: json["data"] == null
            ? []
            : List<GeneralSettings>.from(
                json["data"]!.map((x) => GeneralSettings.fromMap(x))),
        status: json["status"],
      );
}

class GeneralSettings {
  final String? id;
  final num? deliveryCharge;
  final num? vat;
  final num? tax;
  final num? handlingCharge;
  final num? deliveryThreshold;
  final num? packingTime;
  final num? businessDeliveryCharge;
  final bool? showMainBanners;
  final bool? showSliderBanners;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  GeneralSettings({
    this.id,
    this.deliveryCharge,
    this.vat,
    this.tax,
    this.handlingCharge,
    this.deliveryThreshold,
    this.packingTime,
    this.businessDeliveryCharge,
    this.showMainBanners,
    this.showSliderBanners,
    this.createdAt,
    this.updatedAt,
  });

  factory GeneralSettings.fromMap(Map<String, dynamic> json) => GeneralSettings(
        id: json["_id"],
        deliveryCharge: json["deliveryCharge"],
        vat: json["vat"],
        tax: json["tax"],
        handlingCharge: json["handlingCharge"],
        deliveryThreshold: json["deliveryThreshold"],
        packingTime: json["packingTime"],
        businessDeliveryCharge: json["businessDeliveryCharge"],
        showMainBanners: json["showMainBanners"],
        showSliderBanners: json["showSliderBanners"],
        createdAt: json["createdAt"] == null
            ? null
            : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null
            ? null
            : DateTime.parse(json["updatedAt"]),
      );
}
