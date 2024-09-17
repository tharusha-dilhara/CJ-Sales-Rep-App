import 'dart:convert';
import 'package:cj/models/AddStockRequest.dart';
import 'package:cj/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class StockService {
  final String apiUrl = 'http://147.79.66.105/api/sales/tempStock/addOrder';

  Future<void> addStock(AddStockRequest request) async {
    final String? token = await AuthService.getToken();
    print(request);
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        print('Stock added successfully');
      } else {
        print('Failed to add stock: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error occurred: $e');
    }
  }

  
}
