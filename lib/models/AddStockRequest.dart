import 'package:cj/models/StockItem.dart';


class AddStockRequest {
  final String verification;
  final List<StockItem> items;

  AddStockRequest({
    required this.verification,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'verification': verification,
    'items': items.map((item) => item.toJson()).toList(),
  };
}