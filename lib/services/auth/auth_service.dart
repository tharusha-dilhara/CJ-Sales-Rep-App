import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _baseUrl = 'http://147.79.66.105/api/sales/salesrep';

  static Future<String?> applogin(String name, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/loginSalesRep'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'name': name,
        'password': password,
      }),
    );

    print(response.body);

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body);

      // Store salesRep data in SharedPreferences
      await storeSalesRepData(
        responseBody['salesRep']['_id'],
        responseBody['salesRep']['name'],
        responseBody['salesRep']['nic'],
        responseBody['salesRep']['branchname'],
        responseBody['salesRep']['mobileNumber'],
      );

      return responseBody['accessToken'];
    } else {
      return null;
    }
  }

  // Method to store salesRep data
  static Future<void> storeSalesRepData(String id, String name, String nic,String branchname,String mobileNumber) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('salesRepId', id);
    await prefs.setString('salesRepName', name);
    await prefs.setString('salesRepNic', nic);
    await prefs.setString('branchname', branchname);
    await prefs.setString('mobileNumber', mobileNumber);
  }

  // Method to retrieve salesRep data
  static Future<Map<String, String?>> getSalesRepData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return {
      'id': prefs.getString('salesRepId'),
      'name': prefs.getString('salesRepName'),
      'nic': prefs.getString('salesRepNic'),
      'branchname': prefs.getString('branchname'),
      'mobileNumber': prefs.getString('mobileNumber'),
    };
  }

  static Future<void> storeToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('jwt_token', token);
  }

  static Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<void> applogout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Remove the JWT token and salesRep data from SharedPreferences
    await prefs.remove('jwt_token');
    await prefs.remove('salesRepId');
    await prefs.remove('salesRepName');
    await prefs.remove('salesRepNic');
    await prefs.remove('branchname');
    await prefs.remove('mobileNumber');
  }


  static Future<bool> verifySalesRep(String id) async {
  final String url = 'http://147.79.66.105/api/sales/salesrep/verifySalesRep/$id';

  try {
    final response = await http.get(Uri.parse(url));


    if (response.statusCode == 200) {

      // Assuming the response body is either "true" or "false"
      return true;
    } else {
      // Handle other status codes or errors
      return false;
    }
  } catch (e) {
    // Handle any exceptions
    print('Error: $e');
    return false;
  }
}
}
