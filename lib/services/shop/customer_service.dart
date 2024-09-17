import 'dart:convert';
import 'package:cj/models/customer.dart';
import 'package:cj/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class CustomerService {
  final String baseUrl = 'http://147.79.66.105/api/sales/customer';

  Future<void> addCustomer(Customer customer) async {
    final String? token = await AuthService.getToken(); // Retrieve the token
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null)
        'Authorization': 'Bearer $token', // Add token to headers
    };
    final url = Uri.parse('$baseUrl/addNewCustomer');

    final response = await http.post(
      url,
      headers: headers,
      body: jsonEncode(customer.toJson()),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 201) {
      // If the server returns a Created (201) response, parse the JSON.
      final responseData = jsonDecode(response.body);
      print('Customer added successfully: ${responseData['data']}');
    } else if (response.statusCode == 400) {
      // Handle bad request (400) if needed
      final responseBody = jsonDecode(response.body);
      throw Exception(responseBody['message'] ??
          'Failed to add customer or customer already exists');
    } else if (response.statusCode == 500) {
      // If the server returns a Server Error (500), parse the JSON.
      final responseData = jsonDecode(response.body);
      throw Exception('Failed to add customer: ${responseData['message']}');
    } else {
      // Handle other status codes as needed.
      throw Exception(
          'Failed to add customer with status code: ${response.statusCode}');
    }
  }

  Future<List<Customer>> getAllCustomers(String salesRepId) async {
    final String? token = await AuthService.getToken(); // Retrieve the token
    final headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null)
        'Authorization': 'Bearer $token', // Add token to headers
    };
    final url = Uri.parse('$baseUrl/getAllCustomersF/$salesRepId');

    final response = await http.get(url, headers: headers);

    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      return responseData
          .map((customerJson) => Customer.fromJson(customerJson))
          .toList();
    } else if (response.statusCode == 404) {
      // Treat 404 as an empty list instead of throwing an exception
    return [];
    } else {
      throw Exception(
          'Failed to load customers with status code: ${response.statusCode}');
    }
  }
}
