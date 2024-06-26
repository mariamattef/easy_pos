class ExchangeRateModel {
  int? id;
  double? currencyusd;
  double? currencyegp;
  ExchangeRateModel.fromJson(Map<String, dynamic> data) {
    id = data['id'];
    currencyusd = data['currencyusd'];
    currencyegp = data['currencyegp'];
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'currencyusd': currencyusd,
      'currencyegp': currencyegp,
    };
  }
}
