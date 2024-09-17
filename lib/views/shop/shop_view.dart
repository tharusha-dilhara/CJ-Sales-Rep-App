import 'package:cj/services/shop/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cj/models/customer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopView extends StatefulWidget {
  const ShopView({super.key});

  @override
  State<ShopView> createState() => _ShopViewState();
}

class _ShopViewState extends State<ShopView> {
  late Future<List<Customer>> _customersFuture = Future.value([]);
  final CustomerService _customerService = CustomerService();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? salesRepId = prefs.getString('salesRepId');

    if (salesRepId != null && salesRepId.isNotEmpty) {
      setState(() {
        _customersFuture = _customerService.getAllCustomers(salesRepId);
        print('SalesRep ID: $salesRepId');
      });
    } else {
      // Handle the case where the salesRepId is not available
      setState(() {
        _customersFuture = Future.error('Sales Rep ID not found.');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shop'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: () {
                GoRouter.of(context).pushNamed('addshop');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(10), // Set border radius to zero
                ), // Set the background color to black
              ),
              child: const Text(
                'Add Shop',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18, // Set the text color to white
                  fontWeight: FontWeight.bold, // Make the text bold
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadCustomers, // Trigger a refresh when pulled down
                child: FutureBuilder<List<Customer>>(
                  future: _customersFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(child: Text('No shops data available.'));
                    }

                    final customers = snapshot.data!;

                    return ListView.builder(
                      itemCount: customers.length,
                      itemBuilder: (context, index) {
                        final customer = customers[index];
                        return Card(
                          child: ListTile(
                            title: Text(customer.shopName),
                            subtitle: Text(customer.address),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
