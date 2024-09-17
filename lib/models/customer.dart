class Customer {
  final String shopName;
  final String salesRepId;
  final String ownerName;
  final String address;
  final String berNumber;
  final String mobileNumber;
  final String landNumber;

  Customer({
    required this.shopName,
    required this.salesRepId,
    required this.ownerName,
    required this.address,
    required this.berNumber,
    required this.mobileNumber,
    required this.landNumber,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      shopName: json['shopName'] ?? '',
      salesRepId: json['salesRepid'] ?? '',
      ownerName: json['ownerName'] ?? '',
      address: json['address'] ?? '',
      berNumber: json['berNumber'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      landNumber: json['landNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shopName': shopName,
      'salesRepid': salesRepId,
      'ownerName': ownerName,
      'address': address,
      'berNumber': berNumber,
      'mobileNumber': mobileNumber,
      'landNumber': landNumber,
    };
  }
}
