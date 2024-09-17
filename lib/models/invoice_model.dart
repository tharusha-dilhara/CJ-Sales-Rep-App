class InvoiceModel {
  final String salesRepId;
  final String branchName;
  final String shopName;
  final List<InvoiceItem> items;
  final String paymentMethod;

  InvoiceModel({
    required this.salesRepId,
    required this.branchName,
    required this.shopName,
    required this.items,
    required this.paymentMethod,
  });

  Map<String, dynamic> toJson() {
    return {
      'salesRepId': salesRepId,
      'branchname': branchName,
      'shopName': shopName,
      'items': items.map((item) => item.toJson()).toList(),
      'paymentMethod': paymentMethod,
    };
  }
}

class InvoiceItem {
  final String itemName;
  final int qty;
  final String price;
  final String discount;

  InvoiceItem({
    required this.itemName,
    required this.qty,
    required this.price,
    required this.discount,
  });

  Map<String, dynamic> toJson() {
    return {
      'itemName': itemName,
      'qty': qty,
      'price': price,
      'discount': discount,
    };
  }
}
