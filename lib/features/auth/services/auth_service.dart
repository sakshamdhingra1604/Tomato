import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/config/api_config.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _roleKey = 'user_role';
  static const String _nameKey = 'user_name';
  static const String _emailKey = 'user_email';
  static const String _vendorIdKey = 'vendor_id';
  static const String _authTypeKey = 'auth_type'; // 'user' or 'vendor'

  // User Sign Up
  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
          'role': role,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 201 && responseData['success'] == true) {
        await _saveUserSession(
          token: responseData['token'],
          role: responseData['user']['role'],
          name: responseData['user']['name'],
          email: responseData['user']['email'],
        );
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // User Login
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        await _saveUserSession(
          token: responseData['token'],
          role: responseData['user']['role'],
          name: responseData['user']['name'],
          email: responseData['user']['email'],
        );
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Vendor Login
  Future<Map<String, dynamic>> vendorLogin({
    required String vendorId,
    required String password,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/vendor/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'vendorId': vendorId,
          'password': password,
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        await _saveVendorSession(
          token: responseData['token'],
          vendorId: responseData['vendor']['vendorId'],
          name: responseData['vendor']['name'],
        );
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Vendor login failed');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Save session details for students / deliverers
  Future<void> _saveUserSession({
    required String token,
    required String role,
    required String name,
    required String email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_roleKey, role);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_emailKey, email);
    await prefs.setString(_authTypeKey, 'user');
    await prefs.remove(_vendorIdKey);
  }

  // Save session details for vendors
  Future<void> _saveVendorSession({
    required String token,
    required String vendorId,
    required String name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    await prefs.setString(_vendorIdKey, vendorId);
    await prefs.setString(_nameKey, name);
    await prefs.setString(_authTypeKey, 'vendor');
    await prefs.remove(_roleKey);
    await prefs.remove(_emailKey);
  }

  // Log out and clear session keys
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_roleKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_vendorIdKey);
    await prefs.remove(_authTypeKey);
  }

  // Retrieve current active JWT
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Retrieve user role (student, deliverer)
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_roleKey);
  }

  // Retrieve vendor ID
  Future<String?> getVendorId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_vendorIdKey);
  }

  // Retrieve authentication type ('user' or 'vendor')
  Future<String?> getAuthType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTypeKey);
  }

  // Check if session exists
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // Get Profile details from backend
  Future<Map<String, dynamic>> getProfile() async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/profile');
    final token = await getToken();
    
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final user = responseData['user'];
        await _saveUserSession(
          token: token ?? '',
          role: user['role'] ?? 'student',
          name: user['name'] ?? '',
          email: user['email'] ?? '',
        );
        // Also save additional student details
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('college_name', user['college'] ?? '');
        await prefs.setString('roll_no', user['rollNo'] ?? '');
        await prefs.setString('year', user['year'] ?? '');
        await prefs.setString('branch', user['branch'] ?? '');
        await prefs.setString('block', user['block'] ?? '');
        await prefs.setString('class_room', user['classRoom'] ?? '');
        
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  // Update Profile details on backend
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String college,
    required String rollNo,
    required String year,
    required String branch,
    String? block,
    String? classRoom,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/api/auth/profile');
    final token = await getToken();
    
    try {
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': name,
          'college': college,
          'rollNo': rollNo,
          'year': year,
          'branch': branch,
          'block': block ?? '',
          'classRoom': classRoom ?? '',
        }),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final user = responseData['user'];
        await _saveUserSession(
          token: token ?? '',
          role: user['role'] ?? 'student',
          name: user['name'] ?? '',
          email: user['email'] ?? '',
        );
        // Save additional student details locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('college_name', user['college'] ?? '');
        await prefs.setString('roll_no', user['rollNo'] ?? '');
        await prefs.setString('year', user['year'] ?? '');
        await prefs.setString('branch', user['branch'] ?? '');
        await prefs.setString('block', user['block'] ?? '');
        await prefs.setString('class_room', user['classRoom'] ?? '');

        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }
}
