class StockItem {
  final String itemName;
  final double qty;
  final String rate;


  StockItem({
    required this.itemName,
    required this.qty,
    required this.rate,

  });

  factory StockItem.fromJson(Map<String, dynamic> json) {
    return StockItem(
      itemName: json['itemName'] as String,
      qty: (json['qty'] as num).toDouble(),
      rate: json['rate'],
    );
  }

  Map<String, dynamic> toJson() => {
    'item_name': itemName,
    'qty': qty,
    'rate': rate
  };
}