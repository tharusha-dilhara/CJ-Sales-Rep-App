import 'dart:ffi';

import 'package:cj/services/auth/auth_service.dart';
import 'package:cj/services/pdf/invoicepdf.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:cj/models/invoice_model.dart';
import 'package:cj/services/invoice/invoice_service.dart';

class CreateinvoiceView extends StatefulWidget {
  const CreateinvoiceView({super.key});

  @override
  _CreateinvoiceViewState createState() => _CreateinvoiceViewState();
}

class _CreateinvoiceViewState extends State<CreateinvoiceView> {
  final List<InvoiceItem> _items = [];
  final TextEditingController _itemNameController = TextEditingController();
  final TextEditingController _qtyController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false; // Loading state variable
  List<String> _shopNames = [];
  List<Map<String, dynamic>> _itemsData = []; // Store items data
  List<String> _paymentMethods = [
    'cash',
    'credit',
  ]; // List of payment methods
  String? _selectedShopName;
  String? _selectedPaymentMethod; // Selected payment method
  String? _selectedItem; // Selected item from dropdown

  int? _availableQuantity; // New variable to store available stock quantity

  @override
  void initState() {
    super.initState();
    _fetchShopNames(); // Fetch shop names when the widget is initialized
    _fetchItemsData(); // Fetch items data when the widget is initialized
  }

  Future<void> _fetchShopNames() async {
    try {
      // Fetch the token
      final String? token = await AuthService.getToken();

      // Set up the headers
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      Map<String, String?> salesRepData = await AuthService.getSalesRepData();

      // Make the API call with headers
      final response = await http.get(
        Uri.parse(
            'http://147.79.66.105/api/sales/customer/customers/${salesRepData['id']}'),
        headers: headers,
      );

      // Check the response status
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _shopNames = List<String>.from(data);
        });
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load shop names.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _fetchItemsData() async {
    try {
      // Fetch the token
      final String? token = await AuthService.getToken();

      // Set up the headers
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      // Make the API call with headers
      final response = await http.get(
        Uri.parse(
            'http://147.79.66.105/api/sales/primaryStock/getItemsWithPositiveQuantity'),
        headers: headers,
      );

      // Check the response status
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          _itemsData = List<Map<String, dynamic>>.from(data);
        });
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to load items data.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Handle exceptions
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String generatediscountpresentage() {
    double discount = double.parse(_discountController.text);
    double price = double.parse(_priceController.text);
    double percentage = (discount / price) * 100;
    return percentage.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _itemNameController.dispose();
    _qtyController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _items.add(
          InvoiceItem(
            itemName: _itemNameController.text,
            qty: int.parse(_qtyController.text),
            price: _priceController.text,
            discount: generatediscountpresentage(),
          ),
        );
      });

      // Clear the input fields after adding the item
      _itemNameController.clear();
      _qtyController.clear();
      _priceController.clear();
      _discountController.clear();
    }
  }

  Future<void> _createInvoice() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    Map<String, String?> salesRepData = await AuthService.getSalesRepData();

    // Example data for the invoice
    final invoiceData = InvoiceModel(
      salesRepId: '${salesRepData['id']}',
      branchName: '${salesRepData['branchname']}',
      shopName: _selectedShopName ?? 'Unknown', // Use selected shop name
      items: _items,
      paymentMethod: _selectedPaymentMethod as String,
    );

    // Save salesRepId to SharedPreferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('salesRepId', invoiceData.salesRepId);

    // Call the API to create the invoice
    bool isSuccess = await InvoiceService.createInvoice(invoiceData);

    setState(() {
      _isLoading = false; // Stop loading
    });

    if (isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Invoice created successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      // createAndSharePdf(_items);
      GoRouter.of(context).goNamed('finishinvoiceView', extra: _items);
      // GoRouter.of(context).goNamed('invoice');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to create invoice.'),
          backgroundColor: Colors.red,
        ),
      );
      GoRouter.of(context).goNamed('invoice');
    }
  }

  void _showItemsModal() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          height: MediaQuery.of(context).size.height *
              0.6, // Adjust height as needed
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 10,
              ),
              Text(
                'Items List',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.deepPurple,
                          child: Text(
                            item.qty.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        title: Text(
                          item.itemName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price: Rs ${item.price}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Discount: ${item.discount}%',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            Text(
                              'Qty: ${item.qty}',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.delete,
                            color: Colors.redAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              _items.removeAt(index);
                            });
                            Navigator.pop(
                                context); // Close the modal after deletion
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(
                      context); // Close the modal when the button is pressed
                },
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateItemDetails(String itemName) {
    // Find the selected item in the _itemsData list
    final selectedItem = _itemsData.firstWhere(
      (item) => item['itemName'] == itemName,
      orElse: () => {},
    );

    // Set the available quantity for validation
    _availableQuantity = selectedItem['qty'] ?? 0;

    setState(() {
      _priceController.text = selectedItem['price'].toString();
      _qtyController.text = selectedItem['qty'].toString();
    });
  }

  Future<void> verfy() async {
    Map<String, String?> salesRepData = await AuthService.getSalesRepData();
    String? id = salesRepData['id'];
    bool iscredicle = await AuthService.verifySalesRep(id!);
    if (iscredicle) {
      print(true);
    } else {
      print(false);
      AuthService.applogout();
      GoRouter.of(context).pushReplacementNamed('login');
    }
  }

  @override
  Widget build(BuildContext context) {
    verfy();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10.0),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Shop Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              value: _selectedShopName,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedShopName = newValue;
                });
              },
              items: _shopNames.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              value: _selectedPaymentMethod,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue;
                });
              },
              items:
                  _paymentMethods.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 10.0),
            Divider(),
            const SizedBox(height: 10.0),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    value: _selectedItem,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedItem = newValue;
                      });
                      _itemNameController.text = newValue ?? '';
                      _updateItemDetails(newValue ?? '');
                    },
                    items: _itemsData.map<DropdownMenuItem<String>>((item) {
                      return DropdownMenuItem<String>(
                        value: item['itemName'],
                        child: Text(item['itemName']),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Quantity',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter quantity';
                      }
                      final qty = int.tryParse(value);
                      if (qty == null || qty <= 0) {
                        return 'Please enter a valid quantity';
                      }
                      if (qty > (_availableQuantity ?? 0)) {
                        return 'Quantity exceeds available stock';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: 'Price',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter price';
                      }
                      final price = double.tryParse(value);
                      if (price == null || price <= 0) {
                        return 'Please enter a valid price';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10.0),
                  TextFormField(
                    controller: _discountController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Discount',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter discount';
                      }
                      final discount = double.tryParse(value);
                      if (discount == null || discount < 0) {
                        return 'Please enter a valid discount';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: _addItem,
              icon: const Icon(Icons.add),
              label: const Text(
                'Add Item',
                style: TextStyle(fontSize: 24),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60.0),
                ),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shadowColor: Colors.blue.withOpacity(0.3),
                elevation: 10.0,
              ),
            ),
            const SizedBox(height: 10.0),
            ElevatedButton.icon(
              onPressed: _showItemsModal,
              icon: const Icon(Icons.list),
              label: const Text(
                'View Items',
                style: TextStyle(fontSize: 24),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 18.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(60.0),
                ),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shadowColor: Colors.green.withOpacity(0.3),
                elevation: 10.0,
              ),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _isLoading
                  ? null
                  : _createInvoice, // Disable the button if loading
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Set button color
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10), // Adjust padding
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                    ) // Show a progress indicator if loading
                  : const Text(
                      'Create Invoice',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
