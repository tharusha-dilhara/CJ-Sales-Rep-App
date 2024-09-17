import 'package:cj/components/customNavButton.dart';
import 'package:cj/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class StockView extends StatefulWidget {
  const StockView({super.key});

  @override
  _StockViewState createState() => _StockViewState();
}

class _StockViewState extends State<StockView> {
  List<dynamic> stocks = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchStockData();
  }

  Future<void> fetchStockData() async {
    final url = 'http://147.79.66.105/api/sales/tempStock/getPendingStocks';

    // Retrieve token
    final String? token = await AuthService.getToken();

    // Construct headers with or without the token
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    try {
      // Pass headers to the GET request
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        if (jsonResponse['success']) {
          setState(() {
            stocks = jsonResponse['data'];
            isLoading = false;
            hasError = false;
          });
        } else {
          setState(() {
            hasError = true;
            isLoading = false;
          });
        }
      } else {
        setState(() {
          hasError = true;
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }

  Widget buildStockList() {
    if (stocks.isEmpty) {
      return ListView(
        children: [
          SizedBox(height: 50),
          Center(
            child: Text(
              'No stock data available.',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: stocks.length,
      itemBuilder: (context, index) {
        final stock = stocks[index];
        final items = stock['items'] as List<dynamic>;

        return Card(
          color: Colors.white, // Change card color to white
          margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Stock Order Id: ${stock['stock_order_index']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text('Verification: ${stock['verification']}'),
                SizedBox(height: 8.0),
                Text('Custom Date: ${stock['customDate']}'),
                SizedBox(height: 8.0),
                Text('Custom Time: ${stock['customTime']}'),
                SizedBox(height: 8.0),
                Text('Items: ${items.length}'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        title: Text('Stock'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            CustomListTile(
              leadingIcon: Icons.verified,
              title: 'Add Stock',
              subtitle: 'Add new stock',
              onTap: () {
                GoRouter.of(context).pushNamed('addstock');
              },
            ),
            SizedBox(height: 10),
            CustomListTile(
              leadingIcon: Icons.verified,
              title: 'View Pricing List & Stock',
              subtitle: 'View prices and stocks',
              onTap: () {
                GoRouter.of(context).pushNamed('viewpricelist');
              },
            ),
            SizedBox(height:20),
            Divider(),
            Text("Pending Stock Orders"),
            SizedBox(height:10),
            Expanded(
              child: RefreshIndicator(
                onRefresh: fetchStockData, // This will trigger the data refresh
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : hasError
                        ? ListView(
                            children: [
                              Center(child: Text('Failed to load stock data.')),
                            ],
                          )
                        : buildStockList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
