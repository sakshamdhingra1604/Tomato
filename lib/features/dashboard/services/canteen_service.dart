import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';

class CanteenService {
  // Get all canteens
  Future<List<dynamic>> getVendors() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/vendors');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data['vendors'];
      } else {
        throw Exception(data['message'] ?? 'Failed to load canteens');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get menu items by cafeName (Uses custom get-menu/:cafeName route)
  Future<List<dynamic>> getMenuForCafe(String cafeName) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/menu/get-menu/${Uri.encodeComponent(cafeName)}');
    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data['menuItems'];
      } else {
        throw Exception(data['message'] ?? 'Failed to load menu for $cafeName');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
