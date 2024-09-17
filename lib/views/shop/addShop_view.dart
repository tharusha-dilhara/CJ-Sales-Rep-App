import 'package:cj/models/customer.dart';
import 'package:cj/services/auth/auth_service.dart';
import 'package:cj/services/shop/customer_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for shared preferences

class AddshopView extends StatefulWidget {
  const AddshopView({super.key});

  @override
  State<AddshopView> createState() => _AddshopViewState();
}

class _AddshopViewState extends State<AddshopView> {
  final _formKey = GlobalKey<FormState>();
  final _shopNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _berNumberController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _landNumberController = TextEditingController();
  late String _salesRepId;



  Future<void> verfy() async {
    Map<String, String?> salesRepData = await AuthService.getSalesRepData();
    String? id = salesRepData['id'];
    bool iscredicle = await AuthService.verifySalesRep(id!);
    if (iscredicle) {
      print(true);
    }else{
      print(false);
      AuthService.applogout();
       GoRouter.of(context).pushReplacementNamed('login');
    }
  }

  



  @override
  void initState() {
    super.initState();
    _loadSalesRepId();
  }

  Future<void> _loadSalesRepId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _salesRepId = prefs.getString('salesRepId') ?? '';
      print(
          'Sales Rep ID: $_salesRepId'); // Load Sales Rep ID from shared preferences
    });
  }


  

  void _addCustomer() async {
    if (_formKey.currentState?.validate() ?? false) {
      final customer = Customer(
        shopName: _shopNameController.text,
        salesRepId: _salesRepId, // Use Sales Rep ID from shared preferences
        ownerName: _ownerNameController.text,
        address: _addressController.text,
        berNumber: _berNumberController.text,
        mobileNumber: _mobileNumberController.text,
        landNumber: _landNumberController.text,
      );

      try {
        await CustomerService().addCustomer(customer);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Customer added successfully')),
        );
        // Clear the form fields after successful addition
        _formKey.currentState?.reset();
        _shopNameController.clear();
        _ownerNameController.clear();
        _addressController.clear();
        _berNumberController.clear();
        _mobileNumberController.clear();
        _landNumberController.clear();

        GoRouter.of(context).pushNamed('shop');
      } catch (e) {
        print('Error adding customer: $e'); // Print error for debugging
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add customer: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    verfy();
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Shop'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                TextFormField(
                  controller: _shopNameController,
                  decoration: const InputDecoration(
                    labelText: 'Shop Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter shop name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _ownerNameController,
                  decoration: const InputDecoration(
                    labelText: 'Owner Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter owner name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter address';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _berNumberController,
                  decoration: const InputDecoration(
                    labelText: 'BER Number',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter BER number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _mobileNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone, // Opens number pad
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter mobile number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _landNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Land Number',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone, // Opens number pad
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter land number';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                ElevatedButton(
                  onPressed: _addCustomer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          10), // Set border radius to zero
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
