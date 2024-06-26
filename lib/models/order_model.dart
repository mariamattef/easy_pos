class OrderModel {
  int? id;
  String? label;
  double? totalPrice;
  double? discount;
  int? clientId;
  String? clientName;
  String? clientPhone;
  String? clientAddress;
  OrderModel({
    this.id,
    this.label,
    this.totalPrice,
    this.discount,
    this.clientId,
    this.clientName,
    this.clientPhone,
    this.clientAddress,
  });
  OrderModel.freomJson(Map<String, dynamic> data) {
    id = data['id'];
    label = data['label'];
    totalPrice = data['totalPrice'];
    discount = data['discount'];
    clientId = data['clientId'];
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'totalPrice': totalPrice,
      'discount': discount,
      'clientId': clientId,
    };
  }
}
