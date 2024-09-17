import 'dart:convert';
import 'package:cj/models/StockItem.dart';
import 'package:cj/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;


class StockItemService {
  final String _baseUrl = 'http://147.79.66.105/api/stock';

  Future<List<StockItem>> fetchStockItems() async {
    final String? token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/getAllStockItems'),
      headers: token != null ? {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      } : {},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((item) => StockItem.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load stock items');
    }
  }
}
