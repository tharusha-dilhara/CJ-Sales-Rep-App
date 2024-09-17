import 'dart:convert';
import 'package:cj/models/Invoice.dart';
import 'package:cj/models/invoice_model.dart';
import 'package:cj/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;
 // Import your AuthService here

class InvoiceService {
  static const String apiUrl = 'http://147.79.66.105/api/sales/invoice/createInvoice';

  static Future<bool> createInvoice(InvoiceModel invoice) async {
    try {
      // Get the token from AuthService
      final String? token = await AuthService.getToken();

      // Construct headers with or without the token
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      // Make the API request
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: headers,
        body: jsonEncode(invoice.toJson()),
      );

      if (response.statusCode == 201) {
        // Invoice creation was successful
        return true;
      } else {
        // Handle API error response
        print('Failed to create invoice: ${response.body}');
        return false;
      }
    } catch (e) {
      // Handle network or parsing errors
      print('Error creating invoice: $e');
      return false;
    }
  }


  static Future<List<Invoice>> fetchInvoices() async {
      // Get the token
      final String? token = await AuthService.getToken();
      Map<String, String?> salesRepData = await AuthService.getSalesRepData();

      // Construct headers with or without the token
      final headers = {
        'Content-Type': 'application/json; charset=UTF-8',
        if (token != null) 'Authorization': 'Bearer $token',
      };

      // Perform the GET request
      final response = await http.get(
        Uri.parse('http://147.79.66.105/api/sales/invoice/getInvoiceDate/${salesRepData['id']}'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        return jsonData.map((invoice) => Invoice.fromJson(invoice)).toList();
      } else {
        throw Exception('Failed to load invoices');
      }
    }


  
}
