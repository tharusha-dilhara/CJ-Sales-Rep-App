class Invoice {
  final String id;
  final SalesRep salesRepId;
  final String branchname;
  final String shopName;
  final double amount;
  final int quantity;
  final List<Item> items;
  final String paymentMethod;
  final String customDate;
  final String customTime;

  Invoice({
    required this.id,
    required this.salesRepId,
    required this.branchname,
    required this.shopName,
    required this.amount,
    required this.quantity,
    required this.items,
    required this.paymentMethod,
    required this.customDate,
    required this.customTime,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['_id'],
      salesRepId: SalesRep.fromJson(json['salesRepId']),
      branchname: json['branchname'],
      shopName: json['shopName'],
      amount: json['amount'].toDouble(),
      quantity: json['quantity'],
      items: (json['items'] as List).map((i) => Item.fromJson(i)).toList(),
      paymentMethod: json['paymentMethod'],
      customDate: json['customDate'],
      customTime: json['customTime'],
    );
  }
}

class SalesRep {
  final String id;
  final String name;
  final String nic;
  final String address;
  final String dob;
  final String mobileNumber;
  final String branchname;
  final String email;

  SalesRep({
    required this.id,
    required this.name,
    required this.nic,
    required this.address,
    required this.dob,
    required this.mobileNumber,
    required this.branchname,
    required this.email,
  });

  factory SalesRep.fromJson(Map<String, dynamic> json) {
    return SalesRep(
      id: json['_id'],
      name: json['name'],
      nic: json['nic'],
      address: json['address'],
      dob: json['dob'],
      mobileNumber: json['mobileNumber'],
      branchname: json['branchname'],
      email: json['email'],
    );
  }
}

class Item {
  final String itemName;
  final int qty;
  final double price;
  final double discount;
  final String id;

  Item({
    required this.itemName,
    required this.qty,
    required this.price,
    required this.discount,
    required this.id,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemName: json['itemName'],
      qty: json['qty'],
      price: json['price'].toDouble(),
      discount: json['discount'].toDouble(),
      id: json['_id'],
    );
  }
}
