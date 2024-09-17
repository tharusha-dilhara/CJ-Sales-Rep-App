import 'package:cj/components/customNavButton.dart';
import 'package:cj/services/auth/auth_service.dart';
import 'package:cj/services/pdf/pricelistpdf.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ViewpricelistView extends StatefulWidget {
  const ViewpricelistView({Key? key}) : super(key: key);

  @override
  _ViewpricelistViewState createState() => _ViewpricelistViewState();
}

class _ViewpricelistViewState extends State<ViewpricelistView> {
  List<dynamic> _items = [];
  List<dynamic> _filteredItems = [];
  bool _isLoading = true; // Loading indicator
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPricingItems();

    // Add a listener to the search controller to update the filtered list when the user types
    _searchController.addListener(() {
      filterItems();
    });
  }

  Future<void> fetchPricingItems() async {
    const url = 'http://147.79.66.105/api/sales/primaryStock/pricingitemS';

    try {
      // Retrieve the token
      final String? token = await AuthService.getToken();

      // Construct headers with or without the token
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      // Send the HTTP request with headers
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success']) {
          setState(() {
            _items = responseData['data'];
            _filteredItems = _items; // Initialize the filtered list
            _isLoading = false; // Loading completed
          });
        } else {
          // Handle the case where success is false
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(responseData['message'])),
          );
        }
      } else {
        // Handle HTTP error
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load data.')),
        );
      }
    } catch (e) {
      // Handle network or parsing error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Search function to filter items based on search query
  void filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = _items.where((item) {
        final itemName = item['itemName'].toLowerCase();
        return itemName.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        title: const Text('View Pricing List & stock'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
             CustomListTile(
              leadingIcon: Icons.share,
              title: 'Share price',
              subtitle: 'print and share price list',
              onTap: () {
                createAndSharePriceListPdf(_items);
              },
            ),
            SizedBox(height: 20,),
            // Search bar
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search items...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10,),
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator()) // Loading indicator
                  : _filteredItems.isEmpty
                      ? const Center(child: Text('No items found.'))
                      : ListView.builder(
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  vertical: 8.0, horizontal: 16.0),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.blueAccent,
                                  child: Text(
                                    item['qty'].toString(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                title: Text(item['itemName']),
                                subtitle: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Price: Rs ${item['price']}'),
                                    Text('qty: ${item['qty']}'),
                                  ],
                                ),
                                trailing: const Icon(Icons.arrow_forward),
                                onTap: () {
                                  // Handle item tap
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text(item['itemName']),
                                        content: Text(
                                            'Quantity: ${item['qty']}\nPrice: RS ${item['price']}'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context),
                                            child: const Text('Close'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller when not needed
    super.dispose();
  }
}

void main() {
  runApp(const MaterialApp(
    home: ViewpricelistView(),
  ));
}
