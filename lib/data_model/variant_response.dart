// To parse this JSON VariantData, do
//
//     final variantResponse = variantResponseFromJson(jsonString);

import 'dart:convert';

VariantResponse variantResponseFromJson(String str) =>
    VariantResponse.fromJson(json.decode(str));

String variantResponseToJson(VariantResponse VariantData) =>
    json.encode(VariantData.toJson());

class VariantResponse {
  bool? result;
  VariantData? variantData;

  VariantResponse({
    this.result,
    this.variantData,
  });

  factory VariantResponse.fromJson(Map<String, dynamic> json) =>
      VariantResponse(
        result: json["result"],
        variantData: VariantData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "result": result,
        "data": variantData!.toJson(),
      };
}

class VariantData {
  String? price;
  // Per-unit rate for the active tier (sku / moq / bulk). Computed server-side.
  String? unitPrice;
  int? stock;
  var stockTxt;
  int? digital;
  String? variant;
  String? variation;
  int? maxLimit;
  int? inStock;
  String? image;
  // Minimum Order Quantity (step size for the qty stepper).
  int? minMoq;
  // Whether stock is tracked/limited (caps the Plus button).
  int? stockManage;

  VariantData({
    this.price,
    this.unitPrice,
    this.stock,
    this.stockTxt,
    this.digital,
    this.variant,
    this.variation,
    this.maxLimit,
    this.inStock,
    this.image,
    this.minMoq,
    this.stockManage,
  });

  factory VariantData.fromJson(Map<String, dynamic> json) => VariantData(
        price: json["price"],
        unitPrice: json["unit_price"]?.toString(),
        stock: int.parse(json["stock"].toString()),
        stockTxt: json["stock_txt"],
        digital: int.parse(json["digital"].toString()),
        variant: json["variant"],
        variation: json["variation"],
        maxLimit: int.parse(json["max_limit"].toString()),
        inStock: int.parse(json["in_stock"].toString()),
        image: json["image"],
        minMoq: json["min_moq"] == null
            ? null
            : int.tryParse(json["min_moq"].toString()),
        stockManage: json["stock_manage"] == null
            ? null
            : int.tryParse(json["stock_manage"].toString()),
      );

  Map<String, dynamic> toJson() => {
        "price": price,
        "unit_price": unitPrice,
        "stock": stock,
        "digital": digital,
        "variant": variant,
        "variation": variation,
        "max_limit": maxLimit,
        "in_stock": inStock,
        "image": image,
        "min_moq": minMoq,
        "stock_manage": stockManage,
      };
}
