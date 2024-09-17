import 'dart:convert';
import 'package:cj/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CreditView extends StatefulWidget {
  const CreditView({super.key});

  @override
  State<CreditView> createState() => _CreditViewState();
}

class _CreditViewState extends State<CreditView> {
  late Future<List<CreditInvoice>> _creditInvoices;

  @override
  void initState() {
    super.initState();
    _creditInvoices = fetchCreditInvoices();
  }

  Future<List<CreditInvoice>> fetchCreditInvoices() async {
    final String? token = await AuthService.getToken();
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final salesRepData = await AuthService.getSalesRepData();
    final salesRepId = salesRepData['id'];

    final response = await http.get(
      Uri.parse("http://147.79.66.105/api/sales/invoice/creditInvoices/${salesRepId}"),
      headers: headers,
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'];
      return data.map((invoice) => CreditInvoice.fromJson(invoice)).toList();
    } else {
      throw Exception('Failed to load credit invoices');
    }
  }

  Future<void> updatePaymentMethod(String invoiceId) async {
    final String? token = await AuthService.getToken();
    final salesRepData = await AuthService.getSalesRepData();
    final salesRepId = salesRepData['id'];
    
    if (salesRepId == null || token == null) {
      // Handle the error: missing salesRepId or token
      print('Missing salesRepId or token');
      return;
    }

    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    };

    final url = 'http://147.79.66.105/api/sales/invoice/updatePaymentMethod/$salesRepId/$invoiceId';
    
    final response = await http.put(
      Uri.parse(url),
      headers: headers,
    );

    if (response.statusCode == 200) {
      // Successfully updated payment method
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment method updated successfully')),
      );
      // Optionally, refresh the list of credit invoices
      setState(() {
        _creditInvoices = fetchCreditInvoices();
      });
    } else {
      // Handle the error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update payment method: ${response.reasonPhrase}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Credit Invoices'),
        centerTitle: true,
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<List<CreditInvoice>>(
          future: _creditInvoices,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('No credit invoices found'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No credit invoices found'));
            } else {
              final invoices = snapshot.data!;
              return ListView.builder(
                itemCount: invoices.length,
                itemBuilder: (context, index) {
                  final invoice = invoices[index];
                  return Card(
                    elevation: 6,
                    margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      leading: Icon(Icons.receipt, size: 50),
                      title: Text(
                        invoice.shopName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Amount: Rs ${invoice.amount.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color.fromARGB(255, 136, 135, 135),
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            invoice.customDate,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blueGrey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Qty: ${invoice.quantity}',
                            style: const TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      trailing: ElevatedButton(
                        onPressed: () {
                          updatePaymentMethod(invoice.id);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        child: const Text(
                          'Approve',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class CreditInvoice {
  final String id;
  final String salesRepId;
  final String branchName;
  final String shopName;
  final double amount;
  final int quantity;
  final List<Item> items;
  final String paymentMethod;
  final String customDate;
  final String customTime;

  CreditInvoice({
    required this.id,
    required this.salesRepId,
    required this.branchName,
    required this.shopName,
    required this.amount,
    required this.quantity,
    required this.items,
    required this.paymentMethod,
    required this.customDate,
    required this.customTime,
  });

  factory CreditInvoice.fromJson(Map<String, dynamic> json) {
    return CreditInvoice(
      id: json['_id'],
      salesRepId: json['salesRepId'],
      branchName: json['branchname'],
      shopName: json['shopName'],
      amount: json['amount'].toDouble(),
      quantity: json['quantity'],
      items: (json['items'] as List).map((item) => Item.fromJson(item)).toList(),
      paymentMethod: json['paymentMethod'],
      customDate: json['customDate'],
      customTime: json['customTime'],
    );
  }
}

class Item {
  final String itemName;
  final int qty;
  final double price;
  final double discount;

  Item({
    required this.itemName,
    required this.qty,
    required this.price,
    required this.discount,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemName: json['itemName'],
      qty: json['qty'],
      price: json['price'].toDouble(),
      discount: json['discount'].toDouble(),
    );
  }
}
