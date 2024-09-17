import 'package:cj/components/RealTimeClock.dart';
import 'package:cj/components/customNavButton.dart';
import 'package:cj/services/auth/auth_service.dart';
import 'package:cj/services/pdf/invoicepdf.dart';
import 'package:cj/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert'; // For json decoding
import 'package:http/http.dart' as http; // For making HTTP requests

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  // Future to fetch the sales rep name
  Future<String?> getname() async {
    Map<String, String?> salesRepData = await AuthService.getSalesRepData();
    return salesRepData['name'];
  }

  String _companyName='';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchCompanyName();
  }

  Future<void> _fetchCompanyName() async {
    try {
      final response = await http.get(Uri.parse('http://147.79.66.105/api/poweredby'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(data);
        setState(() {
          _companyName = data.toString(); // Assuming the response is a plain string
        });
      } else {
        showSnackbar(context, 'Failed to load company name');
      }
    } catch (e) {
      showSnackbar(context, 'An error occurred: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F1F1),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService.applogout();
              context.pushReplacementNamed('login');
            },
          ),
        ],
      ),
      // Use FutureBuilder to handle async data fetching
      body: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.start, // Center content vertically
          crossAxisAlignment:
              CrossAxisAlignment.center, // Center content horizontally
          children: [
            // Add the RealTimeClock widget here

            const SizedBox(height: 20), // Add spacing between clock and name
            FutureBuilder<String?>(
              future: getname(),
              builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // Show a loading indicator while waiting for the data
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  // Handle any errors
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  // Handle case where data is null
                  return const Center(child: Text('Name not found'));
                } else {
                  // Display the name once data is fetched
                  return Center(
                    child: Text(
                      'Welcome, ${snapshot.data}!',
                      style: const TextStyle(fontSize: 19),
                    ),
                  );
                }
              },
            ),
            const SizedBox(
              height: 20,
            ),
            const RealTimeClock(),

            const SizedBox(
              height: 20,
            ),

            CustomListTile(
              leadingIcon: Icons.verified,
              title: 'Create Invoice',
              subtitle: 'Create new invoice',
              onTap: () {
                GoRouter.of(context).pushNamed('createInvoice');
              },
            ),
            const SizedBox(
              height: 10,
            ),
            CustomListTile(
              leadingIcon: Icons.verified,
              title: 'View Invoice',
              subtitle: 'View your invoice',
              onTap: () {
                GoRouter.of(context).pushNamed('invoice');
              },
            ),
            const SizedBox(
              height: 10,
            ),
            CustomListTile(
              leadingIcon: Icons.verified,
              title: 'Customers',
              subtitle: 'Manage customers',
              onTap: () {
                GoRouter.of(context).pushNamed('shop');
              },
            ),
            Expanded(
              child: Center(
                child: Text(
                  _companyName.isNotEmpty ? 'Powered by $_companyName' : 'Loading...',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
            
          ],
        ),
      ),
    );
  }
}
