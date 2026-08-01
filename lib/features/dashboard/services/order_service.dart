import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/config/api_config.dart';
import '../../auth/services/auth_service.dart';

class OrderService {
  final AuthService _authService = AuthService();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _authService.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Authentication token not found. Please log in.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Place a new order
  Future<Map<String, dynamic>> placeOrder({
    required String vendorId,
    required List<Map<String, dynamic>> items,
    required String deliveryLocation,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/orders');
    final headers = await _getHeaders();
    try {
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode({
          'vendorId': vendorId,
          'items': items,
          'deliveryLocation': deliveryLocation,
        }),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 201 && data['success'] == true) {
        return data['order'];
      } else {
        throw Exception(data['message'] ?? 'Failed to place order');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get user order history (customer or deliverer)
  Future<List<dynamic>> getUserOrders() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/orders/user');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data['orders'];
      } else {
        throw Exception(data['message'] ?? 'Failed to load order history');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get open delivery jobs (deliverer only)
  Future<List<dynamic>> getOpenJobs() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/orders/jobs');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data['jobs'];
      } else {
        throw Exception(data['message'] ?? 'Failed to load delivery jobs');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Claim order for delivery (deliverer only)
  Future<Map<String, dynamic>> claimJob(String orderId) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/orders/$orderId/assign');
    final headers = await _getHeaders();
    try {
      final response = await http.put(url, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to claim delivery job');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Update order status (vendor or deliverer)
  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String status) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/orders/$orderId/status');
    final headers = await _getHeaders();
    try {
      final response = await http.put(
        url,
        headers: headers,
        body: jsonEncode({'status': status}),
      );
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      } else {
        throw Exception(data['message'] ?? 'Failed to update order status');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get vendor orders (vendor only)
  Future<List<dynamic>> getVendorOrders() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/orders/vendor');
    final headers = await _getHeaders();
    try {
      final response = await http.get(url, headers: headers);
      final data = jsonDecode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return data['orders'];
      } else {
        throw Exception(data['message'] ?? 'Failed to load vendor orders');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
