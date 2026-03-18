import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/auth/services/auth_service.dart';

class ApiService {
  // Use 10.0.2.2 for Android emulator, localhost for others
  static String get baseUrl {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5000/api';
      }
      return 'http://localhost:5000/api';
    } catch (e) {
      // Fallback for Web
      return 'http://localhost:5000/api';
    }
  }

  static Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> _handleRequest(Future<http.Response> Function(Map<String, String> headers) requestFunc) async {
    final headers = await _getHeaders();
    var response = await requestFunc(headers);

    if (response.statusCode == 401) {
      final refreshSuccess = await AuthService.refreshToken();
      if (refreshSuccess) {
        final newHeaders = await _getHeaders();
        response = await requestFunc(newHeaders);
      }
    }
    return response;
  }

  static Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    return _handleRequest((headers) async {
      final url = Uri.parse('$baseUrl$endpoint');
      return http.post(url, headers: headers, body: jsonEncode(body));
    });
  }

  static Future<http.Response> get(String endpoint) async {
    return _handleRequest((headers) async {
      final url = Uri.parse('$baseUrl$endpoint');
      return http.get(url, headers: headers);
    });
  }
  
  static Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    return _handleRequest((headers) async {
      final url = Uri.parse('$baseUrl$endpoint');
      return http.put(url, headers: headers, body: jsonEncode(body));
    });
  }

  static Future<http.Response> delete(String endpoint) async {
    return _handleRequest((headers) async {
      final url = Uri.parse('$baseUrl$endpoint');
      return http.delete(url, headers: headers);
    });
  }
}
