import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      // Save token
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      await prefs.setString('refresh_token', data['refreshToken']);
      return data;
    } else {
      throw Exception(data['message'] ?? 'Login failed');
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await ApiService.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });

    final data = jsonDecode(response.body);

    if (response.statusCode == 201 && data['success'] == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
      await prefs.setString('refresh_token', data['refreshToken']);
      return data;
    } else {
      throw Exception(data['message'] ?? 'Registration failed');
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('refresh_token');
  }

  static Future<bool> refreshToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    
    if (refreshToken == null) return false;

    // Use raw http to avoid infinite loops with ApiService interceptor
    final url = Uri.parse('${ApiService.baseUrl}/auth/refresh');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          await prefs.setString('auth_token', data['token']);
          await prefs.setString('refresh_token', data['refreshToken']);
          return true;
        }
      }
    } catch (_) {}
    
    // If refresh fails, log out completely
    await logout();
    return false;
  }

  static Future<Map<String, dynamic>> getProfile() async {
    final response = await ApiService.get('/auth/me');
    final data = jsonDecode(response.body);

    if (response.statusCode == 200 && data['success'] == true) {
      return data['user'];
    } else {
      throw Exception(data['message'] ?? 'Failed to fetch profile');
    }
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token') != null;
  }
}
