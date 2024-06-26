import 'package:easy_pos/models/products_model.dart';

class OrderItemModel {
  int? orderId;
  int? productCount;
  int? productId;
  ProductModel? productModel;

  OrderItemModel({
    this.orderId,
    this.productCount,
    this.productId,
    this.productModel,
  });

  OrderItemModel.freomJson(Map<String, dynamic> json) {
    orderId = json['orderId'];
    productCount = json['productCount'];
    productId = json['productId'];
  }

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'productCount': productCount,
      'productId': productId,
    };
  }
}
