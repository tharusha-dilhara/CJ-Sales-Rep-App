import 'dart:convert';
import 'package:cj/services/auth/auth_service.dart';
import 'package:http/http.dart' as http;

class InvoiceService {
  final String baseUrl = "http://147.79.66.105/api/sales/invoice";

  Future<double> getTotalCashPaymentsBySalesRep(String salesRepId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/cash/$salesRepId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['totalCashAmount'].toDouble();
    } else {
      throw Exception('Failed to load cash payments');
    }
  }

  Future<double> getCreditInvoicesBySalesRep(String salesRepId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/credit/$salesRepId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['totalCreditAmount'].toDouble();
    } else {
      throw Exception('Failed to load credit invoices');
    }
  }

  Future<Map<String, double>> getCombinedTotalBySalesRep(
      String salesRepId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/combined-total/$salesRepId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return {
        'totalCashAmount': data['totalCashAmount'].toDouble(),
        'totalCreditAmount': data['totalCreditAmount'].toDouble(),
        'combinedTotal': data['combinedTotal'].toDouble(),
      };
    } else {
      throw Exception('Failed to load combined totals');
    }
  }
}
