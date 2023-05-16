class Coin {
  int amount;
  String currency;
  String formatted;
  String symbol;

  Coin({this.amount, this.currency, this.formatted, this.symbol});

  Coin.fromJson(Map<String, dynamic> json) {
    amount = json['amount'];
    currency = json['currency'];
    formatted = json['formatted'];
    symbol = json['symbol'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['amount'] = amount;
    data['currency'] = currency;
    data['formatted'] = formatted;
    data['symbol'] = symbol;
    return data;
  }
}
